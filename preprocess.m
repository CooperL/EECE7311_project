function [y,s,ts,dt,dw,Fs,tspec,noverlap] = preprocess(filename,Nfft)
%PREPROCESS get audio file and highpass filter spectrogram

dt = 1e-3; % window shift
dw = 32e-3; % window length
[y,Fs] = audioread(filename);
Nw = Fs*dw; % number of samples per window
noverlap = Nw-Fs*dt; % number of overlapped samples
% t is time instances where spec. computed
[s,~,tspec] = spectrogram(y,hamming(Nw),noverlap,Nfft,Fs,'twosided');
% figure;
% spectrogram(y,hamming(Nw),noverlap,Nfft,Fs,'yaxis')
numw = size(s,2);
ts = (0:numw)*dt;
end

