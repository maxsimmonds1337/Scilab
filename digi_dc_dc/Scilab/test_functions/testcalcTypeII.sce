
//Script to test the calculation of the type II based on Bassos book sec 4.2.9
mag=10^(-18/20);
boost=68;
fc=5e3;

//Result must be fp=25.7e3, fp0=7.8e3, fz=972
[regulator,fz1,fp1,fp0]= calctypeII(mag,fc,boost)
bode(regulator,fc/103,fc*100,0.1)
