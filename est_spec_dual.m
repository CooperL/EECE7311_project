function [s_est] = est_spec_dual(s1,s2,s_hp,freq_ests,angle_ests,phase_ests,h_lp,Nfw,Ntw,dNf,dNt)
%EST_GAINS1 estimate gain parameters for single speaker
freq_ests1 = freq_ests{1};
freq_ests2 = freq_ests{2};
angle_ests1 = angle_ests{1};
angle_ests2 = angle_ests{2};
phase_ests1 = phase_ests{1};
phase_ests2 = phase_ests{2};

Nf = size(s1,1);
Nt = size(s1,2);

tests = floor((Nt-Ntw)/dNt);
fests = floor((Nf-Nfw)/dNf);
beta1 = cell(fests,tests);
beta2 = cell(fests,tests);
s_est = cell(2,1);
s_est{1} = zeros(size(s1));
s_est{2} = zeros(size(s1));

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
        se1 = s1(idx21:idx22,idx11:idx12);
        se2 = s2(idx21:idx22,idx11:idx12);
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
        bmat1 = se1 - sum(a1.*cos(phi1),3);
        bmat2 = se2 - sum(a2.*cos(phi2),3);
        b1 = reshape(bmat1,Nfw*Ntw,1);
        b2 = reshape(bmat2,Nfw*Ntw,1);
        b = [b1;b2];
        % make Ax's same size
%         d = max(Kw1,Kw2);
%         A1 = [A1,zeros(size(A1,1),d-Kw1)];
%         A2 = [A2,zeros(size(A2,1),d-Kw2)];
        A = zeros(size(A1,1)+size(A2,1),size(A1,2)+size(A2,2));
        A(1:size(A1,1),1:size(A1,2)) = A1;
        A((size(A1,1)+1):end,(size(A1,2)+1):end) = A2;
        At = pinv(A'*A)*A';
        B = At*b;
        beta1{jj,ii} = B(1:size(A1,2));
        beta2{jj,ii} = B((size(A1,2)+1):end);
        
        % restimate spectrogram
        % speaker 1
        s_ql3_1 = zeros(Nfw,Ntw,Kw1);
        for k=1:Kw1
            s_ql3_1(:,:,k) = beta1{jj,ii}(k)*a1(:,:,k)+a1(:,:,k).*cos(phi1(:,:,k));
        end
        s_ql1 = sum(s_ql3_1,3);
        s_est{1}(idx21:idx22,idx11:idx12) = s_est{1}(idx21:idx22,idx11:idx12)+s_ql1;
        
        % speaker 2
        s_ql3_2 = zeros(Nfw,Ntw,Kw2);
        for k=1:Kw2
            s_ql3_2(:,:,k) = beta2{jj,ii}(k)*a2(:,:,k)+a2(:,:,k).*cos(phi2(:,:,k));
        end
        s_ql2 = sum(s_ql3_2,3);
        s_est{2}(idx21:idx22,idx11:idx12) = s_est{2}(idx21:idx22,idx11:idx12)+s_ql2;
    end
%     if(ii == tests/2 && jj == fests)
%         figure;
%         imagesc(s_est);
%         close(gcf);
%     end
end
        
end

