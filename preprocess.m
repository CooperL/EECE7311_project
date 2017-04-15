function [y,s,Fs] = preprocess(filename,N)
%PREPROCESS get audio file and highpass filter spectrogram

[y,Fs] = audioread(filename,[1,N]);
Nw = Fs*32e-3;
noverlap = Nw-Fs*1e-3;
Nfft = 512;
s = spectrogram(y,hamming(Nw),noverlap,Nfft);
% figure;
% spectrogram(y,hamming(Nw),noverlap,Nfft,Fs,'yaxis')
end

