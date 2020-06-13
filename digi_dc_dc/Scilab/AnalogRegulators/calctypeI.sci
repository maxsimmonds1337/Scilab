
//Function to calculate the poles of zeros of a type II regulator from the phase boost and gain
//phase boost in degrees and magfc in natural units
function [regulator,fp0]= calctypeI(magfc,fc)
    //Definition of the Laplace variable
    s=poly(0,'s');
     
    
    ///calculate the gain (position of the cross over frequency for the integrator)
    fp0=1/magfc*fc
    wp0=2*%pi*fp0;
    //Transfer function regulator
    num=wp0;
    den=s;
    regulator=syslin('c',-num,den)
    
    endfunction
