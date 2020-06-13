function [Zvcs,Zvcz,Zos,Duty]=S3Rplant3(N_sections,I_SA,Iload,Cbus,Ts)
    //Function to get the plant of a S3R plant it is a current source interfacing a capacitor
    //The numner of sections is include so the control is normalized to 1
    //It includes the delay of the PWM modulaition
    
 s=poly(0,"s"); //definition of the S variable


//Determination of the permanently connected sections
I_max=N_sections*I_SA;

//Number of section necessary to supply the load
N_sections_load=I_max/Iload;

//Number of sections permantly connected
N_sections_perm=floor(N_sections_load)

//Duty cycle of the PWM applied
Duty= N_sections_load-N_sections_perm


//Delay by the duty cycle
del=Ts*Duty
// pade_delay=1-del*s//+1/2*(del*s)^2-1/6*(del*s)^3
pade_delay=pade(del,s);
 
//Changes only take place at the fallin edge of the PWM modulated current as in discrete converters 
denZvcs=Cbus*s
numZvcs=I_SA
//Zvcs=1/(Cbus*s)*I_SA*pade_delay;
Zvcs=syslin('c',numZvcs,denZvcs);
//We introduce the delay
Zvcs=Zvcs*pade_delay;
Zos=1/(Cbus*s);
Zos=syslin('c',Zos);


//c2d is a function of mine that uses bilinear tranformatio. In the future use impulse invariant

Zvcz=c2d(Zvcs,Ts);//Discretization using bilinear transform

fnyquist=0.5*1/Ts
frq_disc=1e0:1:fnyquist;
frq_cont=1e0:1:f_SD;


scf()
subplot(1,2,1)
bode(Zvcz,frq_disc,'Discrete')
subplot(1,2,2)
bode(Zvcs,frq_cont,'Continous')

endfunction



function [Zvcs,Zvcz]=S3Rplant(I_SA,Cbus,Ts,f_SD)
    //Function to get the plant of a S3R plant it is a current source interfacing a capacitor
 s=poly(0,"s"); //definition of the S variable

 
Zvcs=1/(Cbus*s)*I_SA;
Zvcs=syslin('c',Zvcs);

//c2d is a function of mine that uses bilinear tranformatio. In the future use impulse invariant

Zvcz=c2d(Zvcs,Ts);//Discretization using bilinear transform

fnyquist=0.5*1/Ts
frq_disc=1e0:1:fnyquist;
frq_cont=1e0:1:f_SD;


scf()
subplot(1,2,1)
bode(Zvcz,frq_disc,'Discrete')
subplot(1,2,2)
bode(Zvcs,frq_cont,'Continous')

endfunction


function [Zvcs,Zvcz,Zos]=S3Rplant2(N_sections,I_SA,Cbus,Ts,f_SD)
    //Function to get the plant of a S3R plant it is a current source interfacing a capacitor
    //The numner of sections is include so the control is normalized to 1
 s=poly(0,"s"); //definition of the S variable

 
Zvcs=1/(Cbus*s)*I_SA*N_sections;
Zvcs=syslin('c',Zvcs);

Zos=1/(Cbus*s);
Zos=syslin('c',Zos);


//c2d is a function of mine that uses bilinear tranformatio. In the future use impulse invariant

Zvcz=c2d(Zvcs,Ts);//Discretization using bilinear transform

fnyquist=0.5*1/Ts
frq_disc=1e0:1:fnyquist;
frq_cont=1e0:1:f_SD;


scf()
subplot(1,2,1)
bode(Zvcz,frq_disc,'Discrete')
subplot(1,2,2)
bode(Zvcs,frq_cont,'Continous')

endfunction

