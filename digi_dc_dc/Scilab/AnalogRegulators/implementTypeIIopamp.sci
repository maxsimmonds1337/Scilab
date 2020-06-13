//Implement type II with op-amp from Designing control loops for linear and switching power supplies Cristophe basso (section 5.2)) and 4..2.9
function [R2,C1,C2,implemented]=implementTypeIIopamp(regulator,fz1,fp1,fp0,fc,R1)


//Definition of the Laplace variable
    s=poly(0,'s');
    
G0=fp0/fz1; //Calculation of G0
R2=R1*fp1/(fp1-fz1)*G0*sqrt((fc/fp1)^2+1)/sqrt((fz1/fc)^2+1)

C1=1/(2*%pi*R2*fz1);
C2=C1/(2*%pi*R2*C1*fp1-1);

//Verification of the bode plot
num=1*(1+(s*R2*C1));
den=(s*R1*(C1+C2))*(1+s*R2*C2*C1/(C1+C2));
implemented=syslin('c',num,den);
scf()
bode([regulator;implemented],fc/10e3,fc*10,['Ideal','Implemented'])
endfunction
