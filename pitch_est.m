function [p] = pitch_est(s,Fs,Nfw,Ntw,dNf,dNt)
%PITCH_EST estimate pitch for localized time-freq regions using GCT

Nf = size(s,1);
Nt = size(s,2);
Nfft = 2*(size(s,1)-1);
Nfft_gct = 2^nextpow2(max(Nfw,Ntw));

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
    disp([num2str(ii/tests,3),'% done']);
	idx11 = (ii-1)*dNt+1;
    idx12 = (ii-1)*dNt+Ntw;
    % frequency
    for jj=1:fests
        idx21 = (jj-1)*dNf+1;
        idx22 = (jj-1)*dNf+Nfw;
        % GCT
%         sg = gradient(s);
        se = s(idx21:idx22,idx11:idx12);
        sw = w.*se;
        S = fft2(sw,Nfft_gct,Nfft_gct);
        S = fftshift(S);
        mask1 = abs(S)>max(abs(S(:)))/3;
        % gradient
%         [Sgradx,Sgrady] = gradient(S);
%         Sgrad = sqrt(Sgradx.^2+Sgrady.^2);
%         mask2 = abs(Sgrad)>max(abs(Sgrad(:)))/3;
        % laplacian
%         SL = del2(S);
%         mask3 = abs(SL)<min(abs(SL(:)))/3;
        % apply masks
%         mask = (mask1 | mask2 | mask3);
%         mask = (mask1.*mask2.*mask3);
        mask = mask1.*maskC;
%         Smasked = S.*mask;
        [~,maxIdx] = max(abs(S(:)));
        [maxIdx1,maxIdx2] = ind2sub(size(S),maxIdx);
        ws = norm([maxIdx1,maxIdx2]-[Nfft_gct/2,Nfft_gct/2]);
%         if sum(mask(:)) == 0
%             fest(jj,ii) = 0;
%         else
%             fest(jj,ii)= (1/Nfft_gct)*2*pi*Fs/ws;
%         end
        fest(jj,ii)= (1/Nfft_gct)*2*pi*Fs/ws;
%         figure; 
%         subplot(1,3,1)
%         imshow(mask)
%         subplot(1,3,2); hold on;
%         imagesc((-63:64),(-63:64),abs(S));
%         scatter(maxIdx2-Nfft_gct/2,maxIdx1-Nfft_gct/2,10,'ro','filled');
%         xlim([-64 64]); ylim([-64 64]);
%         subplot(1,3,3);
%         mesh((-63:64),(-63:64),abs(S));
%         close all;
    end
end

p = fest;

end