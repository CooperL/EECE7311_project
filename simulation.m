clear; clc; close all
%% load audio files
filestr1 = 'speech_samples/OSR_us_000_00'; filestr2 = '_8k.wav';
filenum1 = 10;
filenum2 = 11;
file1 = [filestr1,num2str(filenum1),filestr2];
file2 = [filestr1,num2str(filenum2),filestr2];
N = 10000;
[y1,s1,Fs] = preprocess(file1,N);
[y2,s2,~] = preprocess(file2,N);
y1 = y1(1:N); y2 = y2(1:N); 
%% estimate pitch
freqwidth = 875; % Hz
timewidth = 100e-3; % s
freqjump = 140; % Hz
timejump = 5e-3; % s

p1 = pitch_est(s1,Fs,freqwidth,timewidth,freqjump,timejump);
%%
p1m = mean(p1,1);