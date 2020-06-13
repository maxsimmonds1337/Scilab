
//Function to calculate the poles of zeros of a type II regulator from the phase boost and gain
//phase boost in degrees and magfc in natural units
function [regulator,fz1,fp1,fp0]= calctypeII(magfc,fc,phaseboost)
    //Definition of the Laplace variable
    s=poly(0,'s');
     //Move phase boost to radians
    phaseboost=phaseboost*%pi/180
    //position of the pole
    fp1=(tan(phaseboost) + sqrt(((tan(phaseboost))^2+1)))*fc
    //position of the zero
    fz1=fc^2/fp1
    
    //calculate the gain (position of the cross over frequency for the integrator)
    fp0=1/magfc*fz1

    //Transfer function regulator
    num=(1+s/(2*%pi*fz1))
    den=s/(2*%pi*fp0)*(1+s/(2*%pi*fp1))
    regulator=syslin('c',num,den)
    
    
    if(fp1<fz1)
        disp('No phase boost needed');
        break;
    end
    endfunction
