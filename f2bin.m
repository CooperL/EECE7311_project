function bin = f2bin(f,Nfft)
%F2BIN matlab normalized frequency to FFT bin number
Nfft2 = (Nfft+1)/2;
bin = round(Nfft2*f);
end

