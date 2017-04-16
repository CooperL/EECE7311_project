clear; clc; close all
%% chirp
Fs = 8000;
chirp1 = chirp(0:1/Fs:1,1,1,Fs/3);
audiowrite('chirp1.wav',chirp1,Fs);
%% square chirp
Fs = 8000;
D = 0:1/Fs:1;          % pulse delay times
t = 0:1/Fs:1;          % signal evaluation time
f1=1;
f2=Fs/3;
a=(f2-f1)/(t(end)-t(1));
f=f1+a*t;
sq_chirp = square(2*pi*f.*t);
audiowrite('sq_chirp.wav',sq_chirp,Fs);
%% delta chirp
Fs = 8000;
f0 = 40;
f1 = 2000;
T1 = Fs/f0;
T2 = Fs/f1;
T = linspace(T1,T2);
pulse_chirp = [];
for i=1:length(T)
    pulse_chirp = [pulse_chirp,discrete_delta(0:(T(i)-1))];
end
audiowrite('pulse_chirp.wav',pulse_chirp,Fs);
%% plane wave
Fs = 8000;
dt = 1e-3;
M = 257;
N = 1/dt;
[n,m] = meshgrid(0:N-1,0:M-1);
theta = pi/16;
ws = pi/10;

phi = n*sin(theta)+m*cos(theta);
s = cos(ws*phi);
figure; imagesc(s);
save('plane_wave_tp_16_wsp_10.mat','s');
%% two plane waves
Fs = 8000;
dt = 1e-3;
M = 257;
N = 1/dt;
[n,m] = meshgrid(0:N-1,0:M-1);
theta1 = pi/16;
ws1 = pi/10;
theta2 = pi/4;
ws2 = pi/20;

phi1 = n*cos(theta1)+m*sin(theta1);
phi2 = n*cos(theta2)+m*sin(theta2);
s1 = cos(ws1*phi1);
s2 = cos(ws2*phi2);
s = [s1,s2];
figure; imagesc(s);
save('plane_wave_tp_16_wsp_10_tp_4_wsp_20.mat','s');
%% zeros