function [regulator,fz1,fp1,fp0]= typeII(plant,fc,pm)
    //Function to calculate the Type II (Integrator, zero, pole) that can provide the phase margin (pm) at the desired crossover frequecncy(fc))
    
    //Definition of the Laplace variable
    s=poly(0,'s');
    
    //Get the plant mag and phase response at fc
    [frqc,response]=repfreq(plant,fc)
    [magDb,phiplant]=dbphi(response)
    magfc=abs(response)
    //Calculate the phase boost

    phaseboost=pm-phiplant-90;
   
    if(phaseboost>90)
        disp('Phase boost not enough go to Type III')
        break;
    end
 
 /*
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
    end
   */
    [regulator,fz1,fp1,fp0]= calctypeII(magfc,fc,phaseboost)     
endfunction
