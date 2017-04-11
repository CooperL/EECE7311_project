function [p] = pitch_est(s,Fs,freqwidth,timewidth,freqjump,timejump)
%PITCH_EST estimate pitch for localized time-freq regions using GCT

Nf = size(s,1);
Nt = size(s,2);
Nfft = 2*(size(s,1)-1);
Nfw = round(freqwidth*Nfft/Fs);
% ensure divisible by 4
Ntw = round(timewidth*Fs); Nt = Nt-mod(Nt,4);

Nfjump = round(freqjump*Nfft/Fs);
Ntjump = round(timejump*Fs);

w = hamming(Nfw)*hamming(Ntw)';

tests = floor((Nt-Ntw)/Ntjump);
fests = floor((Nf-Nfw)/Nfjump);
fest = zeros(fests,tests);
[f1,f2] = freqspace(Nfft,'meshgrid');
fc = 100/(Fs/2)*pi;
maskC = sqrt(f1.^2+f2.^2)>fc;
% time
for ii=1:tests
	idx11 = (ii-1)*Ntjump+1;
    idx12 = (ii-1)*Ntjump+Ntw;
    % frequency
    for jj=1:fests
        idx21 = (jj-1)*Nfjump+1;
        idx22 = (jj-1)*Nfjump+Nfw;
        % GCT
        sg = gradient(s);
        se = s(idx21:idx22,idx11:idx12);
        sw = w.*abs(se);
        S = fft2(sw,Nfft,Nfft);
        S = fftshift(S);
        mask1 = abs(S)>max(abs(S(:)))/3;
        % gradient
        [Sgradx,Sgrady] = gradient(S);
        Sgrad = sqrt(Sgradx.^2+Sgrady.^2);
        mask2 = abs(Sgrad)>max(abs(Sgrad(:)))/3;
        % laplacian
        SL = del2(S);
        mask3 = abs(SL)<min(abs(SL(:)))/3;
        % apply masks
%         mask = (mask1 | mask2 | mask3);
%         mask = (mask1.*mask2.*mask3);
        mask = mask1.*maskC;
        Smasked = S.*mask;
        [~,maxIdx] = max(abs(Smasked(:)));
        [maxIdx1,maxIdx2] = ind2sub(size(S),maxIdx);
        ws = norm([maxIdx1,maxIdx2]-[Nfft/2,Nfft/2]);
        if sum(mask(:)) == 0
            fest(jj,ii) = 0;
        else
            fest(jj,ii)= (1/Nfft)*2*pi*Fs/ws;
        end
%         figure; 
%         subplot(2,3,1);
%         imshow(mask1);
%         subplot(2,3,2);
%         imshow(mask2);
%         subplot(2,3,3);
%         imshow(mask3);        
%         subplot(2,3,4)
%         imshow(mask)
%         subplot(2,3,5); hold on;
%         image((-255:256),(-255:256),abs(Smasked));
%         scatter(maxIdx2-Nfft/2,maxIdx1-Nfft/2,10,'ro','filled');
%         xlim([-256 256]); ylim([-256 256]);
%         subplot(2,3,6);
%         mesh((-255:256),(-255:256),abs(Smasked));
%         close all;
    end
end

p = fest;

end

