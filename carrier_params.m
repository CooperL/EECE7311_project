function [p,params] = carrier_params(s,Fs,Nfw,Ntw,dNf,dNt)
%carrier parameter estimate for localized time-freq regions using GCT

Nf = size(s,1);
Nt = size(s,2);
Nfft = 2*(size(s,1)-1);
Nfft_gct = 512;

w = hamming(Nfw)*hamming(Ntw)';

tests = floor((Nt-Ntw)/dNt);
fests = floor((Nf-Nfw)/dNf);
fest = zeros(fests,tests);
params = cell(fests,tests);

% PITCH ESTIMATION
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
        
        % CARRIER PARAMS
        if f(1)~=0 && f(2) ~= 0
            K = min(floor(1/f(1)),floor(1/f(2)));
        else
            K = 0;
        end
        curr_params = zeros(1,K);
        for i=1:K
            curr_params(i) = abs(S(i*maxIdx1,maxIdx2));
        end
        params{jj,ii} = curr_params;
%         figure; imagesc(abs(S));
    end
end
thresh = 0.3;
sd = std(fest);
p = median(fest);
p(sd>thresh) = 0;
end