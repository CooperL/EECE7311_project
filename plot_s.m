function [] = plot_s(t,s,freqEst)
%PLOT_S custom spectrogram plot

Nf = size(s,1);
f = linspace(0,1,Nf);
figure;
imagesc(t,f,mag2db(abs(s)));
colorbar;
xlabel('time (s)');
ylabel('frequency \omega/\pi');
set(gca,'Ydir','normal');

end

