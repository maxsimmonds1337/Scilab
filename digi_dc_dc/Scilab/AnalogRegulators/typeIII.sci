function [regulator,fz12,fp12,fp0]= typeIII(plant,fc,pm)
    //Function to calculate the Type III (Integrator, double zero, double pole) that can provide the phase margin (pm) at the desired crossover frequecncy(fc))
    //Zeros andd poles are coincident in frequency
    //Definition of the Laplace variable
    s=poly(0,'s');
    
    //Get the plant mag and phase response at fc
    [frqc,response]=repfreq(plant,fc)
    [magDb,phiplant]=dbphi(response)
    pause
    magfc=abs(response)
    //Calculate the phase boost

    phaseboost=pm-phiplant-90;
   
    if(phaseboost<90)
        disp('Phase boost below 90 consider going to Type II')
    end
    if ((phaseboost>180) | ((real(response)<0) & (imag(response)>0))) then
        disp('Too much phase boost reduce fc')
        break
    end
    
    //Move phase boost to radians
    phaseboost=phaseboost*%pi/180
    
    //position of the poles
    fp12=fc/(tan(%pi/4-phaseboost/4))
    
    //position of the zeros
    fz12=fc^2/fp12
    
    //calculate the gain (position of the cross over frequency for the integrator)
    fp0=1/magfc*(fz12)^2/fc

    //Transfer function regulator
    num=(1+s/(2*%pi*fz12))*(1+s/(2*%pi*fz12))
    den=s/(2*%pi*fp0)*(1+s/(2*%pi*fp12))*(1+s/(2*%pi*fp12))
    regulator=syslin('c',num,den)
    
endfunction
