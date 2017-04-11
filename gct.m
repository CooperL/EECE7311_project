function [gct] = gct(s,freqwidth,timewidth,Fs)
%Compute Grating Compression Transform (GCT)

Nfft = 2*(size(s,1)-1);
Nf = round(freqwidth*Nfft/Fs);


end

