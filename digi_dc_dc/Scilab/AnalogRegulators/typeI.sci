function [regulator,fp0,wp0]= typeI(plant,f)
    //Function to calculate the Type I (Integrator) that provides the crossover frequency
    
    //Definition of the Laplace variable
    s=poly(0,'s');
    
    //Get the plant mag and phase response at fc
    [frqc,response]=repfreq(plant,fc)
    [magDb,phiplant]=dbphi(response)
    magfc=abs(response)
    //Calculate the phase boost

    
    //calculate the gain (position of the cross over frequency for the integrator)
    fp0=1/magfc*fc
    wp0=2*%pi*fp0;
    //Transfer function regulator
    num=wp0;
    den=s;
    regulator=syslin('c',-num,den)
    
    
   
endfunction
