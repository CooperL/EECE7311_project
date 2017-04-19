clear; clc; close all
%% load audio file
filepath = 'speech_samples/separate/';
file = [filepath,'fem_01.wav'];
Nfft = 512;
[y,s,ts,dt,dw,Fs,tspecs,noverlap] = preprocess(file,Nfft);
plot_s(ts,abs(s));
df = 1/Nfft; % in matlab normalized (w/pi)
%%
load('plane_wave_tp_3_wsp_25_tp_12_wsp_30.mat');
tspec{1} = tspecs(1:size(s_1,2));
load('plane_wave_tp_16_wsp_40_tp_4_wsp_30.mat');
tspec{2} = tspecs(1:size(s_2,2));
s = s_1+s_2;
% s = zeros(257,1000)+randn(257,1000);
%% process spectrogram
% take gradient and log
% filter design
s_one = s(1:(Nfft/2),:);
s_one1 = s_1(1:(Nfft/2),:);
s_one2 = s_2(1:(Nfft/2),:);
Nfilt = 21;
x = linspace(-1,1,Nfilt);
fc_hp = 0.0893;
[f1,f2] = freqspace(Nfilt,'meshgrid');
Hd_hp = abs(sqrt((f1.^2+f2.^2)) > fc_hp);
figure; mesh(Hd_hp);
h_hp = fsamp2(Hd_hp);
freqz2(h_hp);
% s_hp = conv2(abs(s_one),h_hp,'same');
s_hp1 = conv2(abs(s_one1),h_hp,'same');
s_hp2 = conv2(abs(s_one2),h_hp,'same');
s_hp = s_hp1+s_hp2;
figure; imagesc(abs(s_hp));
%% estimate pitch
% define window and jump sizes
freqwidth = hz2f(875,Fs); % Hz
timewidth = 100e-3; % s
freqjump = hz2f(140,Fs); % Hz
timejump = 5e-3; % s
% calculate window/jump in samples
Nfw = f2bin(freqwidth,Nfft); % number of FFT bins in window
Ntw = timewidth/dt; % number of time slices in window
dNf = f2bin(freqjump,Nfft); % number of freq bins to jump
dNt = timejump/dt; % number of time slices to jump
% speaker 1
[freq_ests{1},angle_ests{1},phase_ests{1}] = carrier_params(s_hp1,Nfw,Ntw,dNf,dNt);
figure; plot(median(freq_ests{1}));
% speaker 2
[freq_ests{2},angle_ests{2},phase_ests{2}] = carrier_params(s_hp2,Nfw,Ntw,dNf,dNt);
figure; plot(median(freq_ests{2}));
%% manual freq estimates
% o = ones(size(freq_ests{1},1),size(freq_ests{1},2)/2);
% freq_ests{1} = [pi/10*o,pi/20*o];
% freq_ests{2} = [pi/15*o,pi/7*o];
%% estimate gains dual speaker
fc_lp = 2*fc_hp;
Hd_lp = abs(sqrt((f1.^2+f2.^2)) < fc_lp);
h_lp = fsamp2(Hd_lp);
s_est = est_spec_dual(s_one1,s_one2,s_hp,freq_ests,angle_ests,phase_ests,h_lp,Nfw,Ntw,dNf,dNt);
figure; 
subplot(1,2,1); 
imagesc(abs(s_est{1})); 
subplot(1,2,2); 
imagesc(abs(s_est{2}));
%% re-synthesize
s_est_sym = [s_est; flip(s_est,1)];
%%
y_out = synthesize_from_spec(s_est_sym,Fs,Nfft,tspec);