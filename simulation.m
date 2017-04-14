clear; clc; close all
%% load audio file
filepath = 'speech_samples/separate/';
file = [filepath,'male_01.wav'];
N = 10000;
[y,s,ts,Fs] = preprocess(file);
plot_s(ts,s);
%% estimate pitch
freqwidth = 875; % Hz
timewidth = 20e-3; % s
freqjump = 140; % Hz
timejump = 5e-3; % s

p1 = pitch_est(s1,Fs,freqwidth,timewidth,freqjump,timejump);