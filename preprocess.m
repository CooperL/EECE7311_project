function [y,s,ts,dt,dw,Fs] = preprocess(filename,Nfft)
%PREPROCESS get audio file and highpass filter spectrogram

dt = 1e-3; % window shift
dw = 32e-3; % window length
[y,Fs] = audioread(filename);
Nw = Fs*dw; % number of samples per window
noverlap = Nw-Fs*dt; % number of overlapped samples
Nfft = 512;
s = spectrogram(y,hamming(Nw),noverlap,Nfft);
<<<<<<< HEAD
% figure;
% spectrogram(y,hamming(Nw),noverlap,Nfft,Fs,'yaxis')
=======
numw = size(s,2);
ts = (0:numw)*dt;
>>>>>>> b601933dfc11dd666c6f62cf8774b5bd99f3c5f9
end

