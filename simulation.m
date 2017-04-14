clear; clc; close all
%% load audio file
filepath = 'speech_samples/separate/';
file = [filepath,'male_01.wav'];
Nfft = 512;
[y,s,ts,dt,dw,Fs] = preprocess(file,Nfft);
plot_s(ts,s);
df = 1/Nfft; % in matlab normalized (w/pi)
%% estimate pitch
% define window and jump sizes
freqwidth = 875; % Hz
timewidth = 20e-3; % s
freqjump = 140; % Hz
timejump = 5e-3; % s
% calculate window/jump in samples
Nfw = round(freqwidth*Nfft/Fs);
Ntw = round(timewidth*Fs);


% p1 = pitch_est(s,Fs,freqwidth,timewidth,freqjump,timejump);