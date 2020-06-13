R1 = 200e3; 
R2 = 8.06e6;
C1 = 100e-9;
C3 = 1e-9;

s = poly(0, 's')
z=poly(0,'z');

H = syslin('c', (1 + (C1*R2)*s), ( (C3+C1)*R1*s+R1*C1*C3*R2*s^2 ) ) // math model of regulator

H_ss = tf2ss(H) // convert to ss

H_z = cls2dls(H_ss,0.00001) // bilinear transform

disp(H)
disp(H_z)
subplot(1,2,1)
bode(H_ss)

subplot(1,2,2)
bode(H_z, [-10000, 10000])
