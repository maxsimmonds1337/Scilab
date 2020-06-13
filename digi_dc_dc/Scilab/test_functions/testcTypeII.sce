//Test script for the typeII functions
//Definition from Basso's book sec 4.2.9
//Script to test the calculation of the type II based on Bassos book sec 4.2.9
mag=10^(-18/20);
boost=68;
fc=5e3;

//Result must be fp=25.7e3, fp0=7.8e3, fz=972
[regulator,fz1,fp1,fp0]= calctypeII(mag,fc,boost)



//Definition of the poles
wz=2*%pi*fz1;
wp0=2*%pi*fp0;
wp=2*%pi*fp1;
//Defintion of the type II regulator to implement
s=poly(0,'s');
//regulator=syslin('c',-(1+s/wz),s/wp0*(1+s/wp));

[R2_id,C1_id,C2_id,implemented]=implementTypeIIopamp(regulator,fz1,fp1,fp0,10e3,1e3);



R1=1e3;
R2=8.9e3;
C1=19e-9;
C2=722e-12;

//[in_circuit]=AnalyzeTypeIIopamp(regulator,implemented,R1,0.1,R2,0.1,C1,0.1,C2,0.1,10e3,100)
