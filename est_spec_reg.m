function s_est = est_spec_reg(s,s_hp,freq_ests,angle_ests,phase_ests,h_lp,Nfw,Ntw,dNf,dNt)
%EST_GAINS1 estimate gain parameters for single speaker
Z = numel(angle_ests);

Nf = size(s,1);
Nt = size(s,2);
Nfft_gct = 512;

w = hamming(Nfw)*hamming(Ntw)';

tests = floor((Nt-Ntw)/dNt);
fests = floor((Nf-Nfw)/dNf);
beta = cell(fests,tests);
s_est = zeros(size(s));

for ii=1:tests
    disp([num2str(100*ii/tests,3),'% done']);
    idx11 = (ii-1)*dNt+1;
    idx12 = (ii-1)*dNt+Ntw;
    % frequency
    for jj=1:fests
        idx21 = (jj-1)*dNf+1;
        idx22 = (jj-1)*dNf+Nfw;
        [n,w] = meshgrid(idx11:idx12,idx21:idx22);
        Kw = length(phase_ests{jj,ii});
        a = zeros(Nfw,Ntw,Kw);
        A = zeros(Nfw*Ntw,Kw);
        phi = zeros(Nfw,Ntw,Kw);
        se = s(idx21:idx22,idx11:idx12);
        se_hp = s_hp(idx21:idx22,idx11:idx12);
        for k=1:Kw
            theta = angle_ests(jj,ii);
            phi(:,:,k) = k*freq_ests(jj,ii)*(n*cos(theta)+w*sin(theta))+phase_ests{jj,ii}(k);
            a(:,:,k) = conv2(se_hp.*cos(phi(:,:,k)),h_lp,'same');
%             a(:,:,k) = se_hp.*cos(phi(:,:,k));
            A(:,k) = reshape(a(:,:,k),Nfw*Ntw,1);
%             if(ii>(3/4)*tests)
%                 disp('stop');
%             end
        end
        bmat = se - sum(a.*cos(phi),3);
        b = reshape(bmat,Nfw*Ntw,1);
        beta{jj,ii} = pinv(A'*A)*A'*b;
        
        % restimate spectrogram
        s_ql3 = zeros(Nfw,Ntw,Kw);
        for k=1:Kw
            s_ql3(:,:,k) = beta{jj,ii}(k)*a(:,:,k)+a(:,:,k).*cos(phi(:,:,k));
        end
        s_ql = sum(s_ql3,3);
        s_est(idx21:idx22,idx11:idx12) = s_est(idx21:idx22,idx11:idx12)+s_ql;
    end
%     if(ii == tests/2 && jj == fests)
%         figure;
%         imagesc(s_est);
%         close(gcf);
%     end
end
        
end

