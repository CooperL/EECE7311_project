function y = synthesize_from_spec(s,Fs,Nfft,tspec)
%SYNTHESIZE_FROM_SPEC Summary of this function goes here
%   Detailed explanation goes here

N1 = size(s,1);
N2 = size(s,2);
Nout = tspec(end)*Fs+Nfft;
y = zeros(1,Nout);

for ii=1:length(tspec)
    disp(['iter: ',num2str(ii)]);
    idx1 = round((tspec(ii)-tspec(1))*Fs+1);
    idx2 = idx1+Nfft-1;
    y(idx1:idx2) = ifft(s(:,ii))'+y(idx1:idx2);
end

end

