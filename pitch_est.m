function [p] = pitch_est(s,Fs,Nfw,Ntw,dNf,dNt)
%PITCH_EST estimate pitch for localized time-freq regions using GCT

Nf = size(s,1);
Nt = size(s,2);
Nfft = 2*(size(s,1)-1);
Nfft_gct = 512;

w = hamming(Nfw)*hamming(Ntw)';

tests = floor((Nt-Ntw)/dNt);
fests = floor((Nf-Nfw)/dNf);
fest = zeros(fests,tests);
[f1,f2] = freqspace(Nfft_gct,'meshgrid');
fchz = 100;
fc = hz2f(fchz,Fs);
maskC = sqrt(f1.^2+f2.^2)>fc;
% time
for ii=1:tests
    disp([num2str(100*ii/tests,3),'% done']);
	idx11 = (ii-1)*dNt+1;
    idx12 = (ii-1)*dNt+Ntw;
    % frequency
    for jj=1:fests
        idx21 = (jj-1)*dNf+1;
        idx22 = (jj-1)*dNf+Nfw;
        % GCT
        se = s(idx21:idx22,idx11:idx12);
        sw = w.*se;
        S = fft2(sw,Nfft_gct,Nfft_gct);
        [~,maxIdx] = max(abs(S(:)));
        [maxIdx1,maxIdx2] = ind2sub(size(S),maxIdx);
        f = bin2f([maxIdx1,maxIdx2],Nfft_gct);
        ws = norm(f);
        fest(jj,ii)= ws*(3/2);
    end
end

p = median(fest);

end