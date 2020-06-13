//Implement type II with op-amp from Designing control loops for linear and switching power supplies Cristphe basso (section 5.2))
function [R1,C1,implemented]=implementTypeIopamp(regulator,wp0,fc,R1)


//Definition of the Laplace variable
    s=poly(0,'s');
    

C1=1/(wp0*R1);


//Verification of the bode plot
implemented=syslin('c',-1,R1*C1*s);
scf();

bode([regulator;implemented],fc/10e3,fc*10,['Ideal';'Implemented'])
title('Type I regulator implemented');
endfunction
