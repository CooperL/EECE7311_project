clear; clc; close all
%% load audio file
filepath = 'speech_samples/separate/';
file = [filepath,'fem_01.wav'];
Nfft = 512;
[y,s,ts,dt,dw,Fs,tspec,noverlap] = preprocess(file,Nfft);
plot_s(ts,abs(s));
df = 1/Nfft; % in matlab normalized (w/pi)
%%
% load('plane_wave_tp_3_wsp_15_tp_12_wsp_7.mat');
% s = zeros(257,1000)+randn(257,1000);
%% process spectrogram
% take gradient and log
% filter design
s_one = s(1:(Nfft/2),:);
%%
Nfilt = 21;
x = linspace(-1,1,Nfilt);
fc_hp = 0.0893;
[f1,f2] = freqspace(Nfilt,'meshgrid');
Hd_hp = abs(sqrt((f1.^2+f2.^2)) > fc_hp);
figure; mesh(Hd_hp);
h_hp = fsamp2(Hd_hp);
freqz2(h_hp);
s_hp = conv2(abs(s_one),h_hp,'same'); % abs()
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
[freq_ests,angle_ests,phase_ests] = carrier_params(s_hp,Nfw,Ntw,dNf,dNt);
figure; plot(median(freq_ests));
%%
o = ones(size(freq_ests,1),size(freq_ests,2)/2);
freq_ests = [pi/10*o,pi/20*o];
%% estimate gains single speaker
fc_lp = 2*fc_hp;
Hd_lp = abs(sqrt((f1.^2+f2.^2)) < fc_lp);
% figure; mesh(Hd_lp);
h_lp = fsamp2(Hd_lp);
% freqz2(h_lp);
s_est = est_spec_single(s_one,s_hp,freq_ests,angle_ests,phase_ests,h_lp,Nfw,Ntw,dNf,dNt);
%% re-synthesize
s_est_sym = [s_est; flip(s_est,1)];
%%
y_out = synthesize_from_spec(s_est_sym,Fs,Nfft,tspec);