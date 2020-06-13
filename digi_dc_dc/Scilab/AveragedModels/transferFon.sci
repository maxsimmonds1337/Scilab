//Function to obtaint the transfer functions form a converter using the canonical model
// Pag 253 Maksimovic

//Hv is the control to output voltage transfer function, Hi the control to inductor current
//Vg input voltage, vo output voltage, Rl load, L and C reactives 
//converterType is a string "buck","boost","buckboost"
//Note for the buck boost take into account that the voltage is negative (assume that is a Flyback with 1:1 ratio)
function [Hv,Hi,Zo,Zin,Gvg]=transferFon(Vg,Vo,Rl,L,C,Ts,converterType)

//stacksize('max')
//Definition of the Laplace variable for the transfer function
s=poly(0,"s");
//Average duty cycles Voff an Ion Equivalen L
select converterType
case "buck" then 
    D=Vo/Vg;
    Dprime=1-D;
    Kcrit=Dprime;
    M=D;
    Leq=L;
    e=Vo/D^2;
    j=Vo/Rl;
    wz=1e9; //Pulsation of the right half zero, it does not exist
  case "boost" then
    D=1-Vg/Vo;
    Dprime=1-D;
    Kcrit=Dprime.^2*D;
    M=1/Dprime;
    Leq=L/(Dprime.^2);
    wz=Rl/Leq; //Pulsation of the right half zero
    e=Vo*(1-s/wz);//With the right half zero
    j=Vo/(Dprime.^2*Rl);
    wc=(Rl*C/2)^-1; //pulsation of the zero for the current function
  else //In buckboost case
    D=(Vo/Vg)/(1+(Vo/Vg));
    Dprime=1-D;
    Kcrit=Dprime.^2;
    M=D/Dprime;
    Leq=L/(Dprime.^2);
     e=Vo/D^2*(1-s*D*Leq/Rl);//With the right half zero
     wz=Rl/(D*Leq);
     j=Vo/(Dprime.^2*Rl);
     wc=(Rl*C)^-1*(1+D); //pulsation of the zero for the current function
  end

//Parameter to decide whether the converter is in continous or discontinous conduction mode
K=2*L/Rl*1/Ts;

 if K<Kcrit then //Check if the converter is in DCM
       disp('Converter in DCM')
       abort
   end

//Definition of the resonace and quality factor

   wo=(Leq*C)^-(1/2);
   Ro=(Leq/C)^(1/2);
   Qo=Rl/Ro;
   
   wc=(Rl*C)^-1;
   Zeq=1/(s/wc+1)*Rl*((s/wo)^2+1/Qo*1/wo*s+1); //impedance of the filter i do not know what is used for
   
   Hv=e*M*1/((s/wo)^2+1/Qo*1/wo*s+1);
   //Function transfers
   
   
   Hibuck=e*M/Rl*(s/wc+1)*1/((s/wo)^2+1/Qo*1/wo*s+1);
   Hiboost=2*Vo/Dprime^2*1/Rl*(s/wc+1)*1/((s/wo)^2+1/Qo*1/wo*s+1);
   Hibuckboost=(1+D)/D*Vo/Dprime^2*1/Rl*(s/wc+1)*1/((s/wo)^2+1/Qo*1/wo*s+1);
   
   select converterType
case "buck" then 
    Hi=Hibuck;
case 'boost'
    Hi=Hiboost;
else
    Hi=Hibuckboost,
end

    
    
   
   Zo=Leq*s*1/((s/wo)^2+1/Qo*1/wo*s+1);//output impedance
   Zin=1/M^2*Rl*((s/wo)^2+1/Qo*1/wo*s+1)/(1+s/wc); //Input impedance
   Gvg=M*1/((s/wo)^2+1/Qo*1/wo*s+1);//Line transfer

   Hv=syslin('c',Hv);
   Hi=syslin('c',Hi); //Transfer function definitions
   Zo=syslin('c',Zo);
   Zin=syslin('c',Zin);
   Gvg=syslin('c',Gvg)

endfunction
