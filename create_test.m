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