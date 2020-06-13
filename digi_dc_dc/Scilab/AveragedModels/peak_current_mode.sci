// function For the peak current mode control
// Based on "A Unified Model for Current-Programmed Converters"
// Paper and Ph.D Thesis by Dong Tan, Middlebrook adviser
//converterType is a string "buck","boost","buckboost"

function [Fm_s,Fm,M1,M2,Mc,Gvc_s,Gvc_simple,Zo,Zin,Gvg]=peak_current_mode(Vg,Vo,Rl,L,C,Ts,Kc,converterType)
exec ('transferFon.sci',-1);
//stacksize('max')
//Definition of the Laplace variable for the transfer function
s=poly(0,"s");
Zo=1;
Zin=1;
//Definition of Voff and Ion according to fig 3.
//Ion is the sum of the currents through the switches (in a buck the average current through the indutcor))
//Voff is the sum of voltages across the switches (in the Buck Vg)
//It is defined from the input and output voltage check reference 23




//Average duty cycles Voff an Ion
select converterType
  case "buck" then 
    
    
    Voff=Vg; 
    D=Vo/Vg;
    Dprime=1-D;
    Ion=D*Voff/Rl;
    M=D;
    Leq=L;
  case "boost" then
    Voff=Vo;
    D=1-Vg/Vo;
    Dprime=1-D;
    Ion=(Vo/Rl)/Dprime; //Using eq 2.3
    M=1/Dprime;
    

  else //In buckboost case
    Voff=Vg+Vo;
    D=(Vo/Vg)/(1+(Vo/Vg));
    Dprime=1-D;
    Ion=(Vo/Rl)/Dprime; //Using eq 2.3
    M=D/Dprime;
    
  end


if(D<0) then 
    disp('Impossible transformation')
    abort;
end


ws=2*%pi/Ts; //Switching angular frequency

//Parameters in the canonical small signal model 


  
  //Modulator model
  //Current up-slope m1
  M1=Dprime*Voff/L;
  M2=D*Voff/L;
  //Compensating ramp expressed as a fraction of the downslope

  Mc=Kc*M2; 
  
  Dprime_min=0.5/(1+(Mc/M1)); //This is de minimum dprime that guarantees avoiding subharmonic oscillations.
   // If mc is very big it operates in voltage mode and dprime can be almost 0 if no 
   //compensating ramp is used Mc is 0 and the maximum duty cycle is 0.5
   //Fm should be positive and finite so the current loop gain is finite in order to have a finite 
   //positive Fm Dprime>Dprime_min
   
  //Check if Dprime<Dprime_min

  
   
   // Modulator model
   K=D*Dprime*Ts/(2*L); //Eq 8f Influence of Voff in the duty
   
   
   Fm=2*L/(Ts*Voff)*1/(Dprime/Dprime_min-1);

   if Fm<0 then
       disp('Fm negative')
       abort
   end
   
   //Critical inductance (determines the boundary between DCM and CCM)
   R=Voff/Ion;
   Lc=D*Dprime*Ts/2*R
   //Definition fo function Tc open loop current gain
   
   
   wo=(L*C)^-(1/2);
   Ro=(L/C)^(1/2);
   Qo=Rl/Ro;
   
 
   
   //Frequency of the zero 3.10 in the thesis
   wload=(Rl*C)^-1;
   
   
   
  
   
  select converterType
  case "buck" then 
    bet=0;
  case "boost" then
    bet=1;
  else //In buckboost case
    bet=1;
   end
   
   
   //Gain of the inner voltage loop  eq 3.8 Ph.D thesis
   //
   Tv_o=bet*K*Fm*Voff;
   //Correction due to the this effect
   k_vo=(1+Tv_o)^(1/2);
   
   
   //Poles in the Voltage loop
   w1=wo*k_vo;
   Q1=Qo*k_vo;
  
   
   //Expression in eq 3.9
   Tc_o=Fm*Voff/Rl*1/(1+Tv_o);//DC gain of the current loop
   
   
   Kconv=2*L/Rl*1/Ts;
   select converterType
  case "buck" then 
    Kcrit=Dprime;
    Tc_o3=Kconv/Kcrit*R/Rl*1/(Dprime_min^-1-Dprime^-1); //Alternative expression of the DC gain of the current loop eq 3.12-3.15 are expressions for all the converter
  case "boost" then
    Kcrit=Dprime.^2*D;
    Tc_o3=Kconv/Kcrit*D/Dprime*(1+R/Rl)*1/(Dprime_min^-1-1); //Alternative expression of the DC gain of the current loop eq 3.12-3.15 are expressions for all the converters
  else //In buckboost case
    Kcrit=Dprime.^2;
    Tc_o3=Kconv/Kcrit*D/Dprime*(1+R/(D*Rl))*1/(Dprime_min^-1-1);//Alternative expression of the DC gain of the current loop eq 3.12-3.15 are expressions for all the converter
   end
   
   
     if Kconv<Kcrit then //Checi if the converter is in DCM
       disp('Converter in DCM')
       abort
   end
   
   Tc=Tc_o3*(s/wload+1)/((s/w1)^2+1/Q1*s/w1+1);
   Tc=syslin('c',Tc); //transfer function
   
   
   //Sampling effect (this is the Ridley term)
   Den=(Dprime/Dprime_min-1);
   Den=max([Den,1e-9]);//avoid dividing by zero
   Qs=2/Den*1/%pi;
 
   wsa=(ws/2); //Half the switching freq
   
   wp=(wsa)/Qs; //Eq.26 is equivalent to the previous expression
   wc=(wsa)*Qs; //Eq.26 is equivalent to the previous expression
   //wp=%pi/4*ws*(Dprime_min/Dprime-1);
   //Ideal closed loop transfer function to asses 
   
   Tc_prime_cl=(1+1/Qs*s/wsa+(s/wsa)^2)^-1;
   Tc_prime_cl=syslin('c',Tc_prime_cl) //transfer function
   
   //Including the sampling effect
   Tc_sampling= Tc*1/(1+s/wp);
   Tc_sampling=syslin('c',Tc_sampling) //transfer function
   
   //Modulation factor Fm including the sample effect
   Fm_s=Fm*1/(1+s/wp);
   Fm_s=syslin('c',Fm_s);
   //frequ=[1:6*1/Ts];
   frequ=linspace(1,6*1/Ts,10e3); //10e3 freq points
   //bode([Tc_prime_cl],frequ)
   scf 
    bode([Tc;Tc_sampling;Fm_s],frequ,['Open current loop closed without sampling effect';'Open current loop closed with sampling effect';'Fm_s'])
    xtitle( 'Open loop current Tc' ) ;
    //Closed current loop functions
    
    Tc_sampling_cl=Tc_sampling/(1+Tc_sampling);
    Tc_sampling_cl=syslin('c',Tc_sampling_cl) //transfer function
    scf 
    bode([Tc_prime_cl;Tc_sampling_cl],frequ, ['Ideal current loop closed';'Current loop closed'])
   xtitle( 'Closed loop current Tc' ) ;
   
    //Inclusion of the current loop on the small signal mode of the converter

    [Hv,Hi,Zo_noloop,Zin_noloop]=transferFon(Vg,Vo,Rl,L,C,Ts,converterType)
    Gvc_s=Fm_s*Hv/(1+Fm_s*(Hi));
    Gvc_no=Fm*Hv/(1+Fm*(Hi));
    Gvc_s=syslin('c',Gvc_s);
    Gvc_no=syslin('c',Gvc_no);
    
    
        //This functions come from the approximations of the Phd Thesis
    
    // Voltage tranfer functions
    select converterType
  case "buck" then 
    Gvc_o=Rl/(1+1/Tc_o3); //Table 5.1
    wz=1e9*ws; //Buck does not have a right half plane zero
    wl=wload*(1+1/Tc_o3);
  case "boost" then
     Rpar=Rl*R/(Rl+R)
     Gvc_o=Dprime*Rpar/(1+1/Tc_o3);
     
    wl=(Rpar*C)^-1*(1+1/Tc_o3);
    wz=R*Dprime^2/L; //Location of the zero from Maksimovic
  else //In buckboost case
      Rpar=Rl*(R/D)/(Rl+(R/D));
      Gvc_o=Dprime*Rpar/(1+1/Tc_o3);
      wz=R/D*Dprime^2/L;
      wl=(Rpar*C)^-1*(1+1/Tc_o3);
   end
    
    Gvc_simple=Gvc_o*1/(1+s/wl)*1/((s/wsa)^2+1/Qs*s/wsa+1)*(1-s/wz);
    Gvc_simple=syslin('c',Gvc_simple);
    scf();
   bode([Gvc_s;Gvc_no;Gvc_simple;Hv],frequ,['Gvc';'Gvc no sampling';'Gvc analytical';'Gvd in voltage mode'])
    //bode([Gvc_s;Gvc_no;Gvc_simple],frequ,['Gvc';'Gvc no sampling';'Gvc analytical'])
   xtitle( 'Control to voltage transfer function Gvc' ) ;
    

    
    //This functions come from the approximations of the Phd Thesis
    
    //Line rejection transfer functions
    
    select converterType
  case "buck" then 
    Gvg_o=D*1/(1+Tc_o3)*(1-Dprime_min*Dprime/(Dprime_min-Dprime)); //Eq 5.16
    
  case "boost" then
    Gvg_o=1/Dprime*1/(1+R/Rl)*1/(1+Tc_o3);
    
  else //In buckboost case
      Rbb=R/D;
      Gvg_o=D/Dprime*1/(1+Rbb/Rl)*1/(1+Tc_o3)*(1+(1-Dprime_min*Dprime/(Dprime_min-Dprime)));
      
   end
    
    
    
    Gvg=Gvg_o*1/((s/wsa)^2+1/Qs*s/wsa+1)*1/(1+s/wl);
    Gvg=syslin('c',Gvg)
    scf()
    bode(Gvg,frequ,'Gvg');
    xtitle( 'Line rejection transfer function Gvg' ) ;
   
    //Impedance transfer functions
    //Output impedance 
    Zo_o=Rl*Tc_o3; //5.18
   select converterType
      case "buck" then 
        Zo_o=Rl*Tc_o3; //5.18
    
      case "boost" then
        Zo_o=R/(1+(1+(R/Rl)/Tc_o3)); //Table 5.3
      else //In buckboost case
          
          Zo_o=Rbb/(1+(1+(Rbb/Rl)/Tc_o3));;
      end
   
        Zo=(Zo_o*Rl)/(Zo_o+Rl)*1/((s/wsa)^2+1/Qs*s/wsa+1)*1/(1+s/wl);
        Zo=syslin('c',Zo)
        scf()
        bode(Zo,frequ,'Zo');
        xtitle( 'Output impedance Zo' ) ;
    
    //Input impedance 5.20
    
    
        select converterType
      case "buck" then 
        Zi_o=Rl/M^2*(1+Tc_o3)/(1-Rl/R*Tc_o3);
    
      case "boost" then
        Zi_o=Rl/M^2*(1+Tc_o3)/(1-Rl/R*Tv_o)*(1+Tv_o); //Table 5.4
      else //In buckboost case
          Zi_o=Rl/M^2*(1+Tc_o3)*(1+Tv_o)/(1-(Dprime/D+Rbb*Rl)*Tv_o);
       end
    
        Zin=Zi_o*(1+s/wl)/(1+s/wload)*((s/wsa)^2+1/Qs*s/wsa+1);
    
    
        Zin=syslin('c',Zin)
        scf()
        bode(Zin,frequ,'Zin');
        xtitle( 'Input impedance Zin' ) ;

endfunction
