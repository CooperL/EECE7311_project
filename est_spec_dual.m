function s_est = est_spec_dual(s,s_hp,freq_ests,angle_ests,phase_ests,h_lp,Nfw,Ntw,dNf,dNt)
%EST_GAINS1 estimate gain parameters for single speaker
freq_ests1 = freq_ests{1};
freq_ests2 = freq_ests{2};
angle_ests1 = angle_ests{1};
angle_ests2 = angle_ests{2};
phase_ests1 = phase_ests{1};
phase_ests2 = phase_ests{2};

Nf = size(s,1);
Nt = size(s,2);

w = hamming(Nfw)*hamming(Ntw)';

tests = floor((Nt-Ntw)/dNt);
fests = floor((Nf-Nfw)/dNf);
beta = cell(fests,tests);
s_est = cell(2,1);
s_est{1} = zeros(size(s));
s_est{2} = zeros(size(s));

for ii=1:tests
    disp([num2str(100*ii/tests,3),'% done']);
    idx11 = (ii-1)*dNt+1;
    idx12 = (ii-1)*dNt+Ntw;
    % frequency
    for jj=1:fests
        idx21 = (jj-1)*dNf+1;
        idx22 = (jj-1)*dNf+Nfw;
        [n,w] = meshgrid(idx11:idx12,idx21:idx22);
        % speaker 1
        Kw1 = length(phase_ests1{jj,ii});
        a1 = zeros(Nfw,Ntw,Kw1);
        A1 = zeros(Nfw*Ntw,Kw1);
        phi1 = zeros(Nfw,Ntw,Kw1);
        % speaker 2
        Kw2 = length(phase_ests2{jj,ii});
        a2 = zeros(Nfw,Ntw,Kw2);
        A2 = zeros(Nfw*Ntw,Kw2);
        phi2 = zeros(Nfw,Ntw,Kw2);
        % extract local T-F region
        se = s(idx21:idx22,idx11:idx12);
        se_hp = s_hp(idx21:idx22,idx11:idx12);
        % speaker 1 demodulate
        for k=1:Kw1
            theta = angle_ests1(jj,ii);
            phi1(:,:,k) = k*freq_ests1(jj,ii)*(n*cos(theta)+w*sin(theta))+phase_ests1{jj,ii}(k);
            a1(:,:,k) = conv2(se_hp.*cos(phi1(:,:,k)),h_lp,'same');
%             a(:,:,k) = se_hp.*cos(phi(:,:,k));
            A1(:,k) = reshape(a1(:,:,k),Nfw*Ntw,1);
%             if(ii>(3/4)*tests)
%                 disp('stop');
%             end
        end
        % speaker 2 demodulate
        for k=1:Kw2
            theta = angle_ests2(jj,ii);
            phi2(:,:,k) = k*freq_ests2(jj,ii)*(n*cos(theta)+w*sin(theta))+phase_ests2{jj,ii}(k);
            a2(:,:,k) = conv2(se_hp.*cos(phi2(:,:,k)),h_lp,'same');
%             a(:,:,k) = se_hp.*cos(phi(:,:,k));
            A2(:,k) = reshape(a2(:,:,k),Nfw*Ntw,1);
%             if(ii>(3/4)*tests)
%                 disp('stop');
%             end
        end        
        bmat1 = se - sum(a1.*cos(phi1),3);
        bmat2 = se - sum(a2.*cos(phi2),3);
        b1 = reshape(bmat1,Nfw*Ntw,1);
        b2 = reshape(bmat2,Nfw*Ntw,1);
        b = [b1;b2];
        A = [A1,A2];
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

