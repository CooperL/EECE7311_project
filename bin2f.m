function f = bin2f(bin,Nfft)
%BIN2F FFT bin number to matalb normalized f (w/pi)
Nfft2 = (Nfft+1)/2;
f = bin/Nfft2;
end

