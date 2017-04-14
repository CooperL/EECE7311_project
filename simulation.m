clear; clc; close all
%% load audio file
filepath = 'speech_samples/separate/';
file = [filepath,'male_01.wav'];
Nfft = 512;
[y,s,ts,dt,dw,Fs] = preprocess('pulse_chirp.wav',Nfft);
plot_s(ts,abs(s));
df = 1/Nfft; % in matlab normalized (w/pi)
%% process spectrogram
% take gradient and log
% filter design
Nfilt = 21;
x = linspace(-1,1,Nfilt);
fc = 0.0893;
[f1,f2] = freqspace(Nfilt,'meshgrid');
Hd = abs(sqrt((f1.^2+f2.^2)) > fc);
figure; mesh(Hd);
h = fsamp2(Hd);
freqz2(h);
sfilt = conv2(abs(s),h,'same');
figure; imagesc(sfilt);
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
p = pitch_est(sg,Fs,Nfw,Ntw,dNf,dNt);