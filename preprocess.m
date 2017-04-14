function [y,s,ts,Fs] = preprocess(filename)
%PREPROCESS get audio file and highpass filter spectrogram

dt = 1e-3; % window shift
dw = 32e-3; % window length
[y,Fs] = audioread(filename);
Nw = Fs*dw; % number of samples per window
noverlap = Nw-Fs*dt; % number of overlapped samples
Nfft = 512;
s = spectrogram(y,hamming(Nw),noverlap,Nfft);
numw = size(s,2);
ts = (0:numw)*dt;
end

