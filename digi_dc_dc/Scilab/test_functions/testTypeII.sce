//Test script for the typeII functions
//Definition from Basso's book sec 4.2.9
fz=972;
fp0=7.8e3;
fp=25.7e3;

//Definition of the poles
wz=2*%pi*fz;
wp0=2*%pi*fp0;
wp=2*%pi*fp;
//Defintion of the type II regulator to implement
s=poly(0,'s');
regulator=syslin('c',-(1+s/wz),s/wp0*(1+s/wp));

[R2_id,C1_id,C2_id,implemented]=implementTypeIIopamp(regulator,fz,fp,fp0,10e3,1e3);



R1=1e3;
R2=8.9e3;
C1=19e-9;
C2=722e-12;

[in_circuit]=AnalyzeTypeIIopamp(regulator,implemented,R1,0.1,R2,0.1,C1,0.1,C2,0.1,10e3,100)
