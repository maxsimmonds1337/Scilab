//Function to calculate a PI regulator from a Transfer function a crossover frecuency and phase margin

function [Kp,Kd,Ki,Tz,Tuz,Gcz,p_mo,fcross,g_m,f_pi]=PI_regulator(fc,pm,fs,H,Gcompensate)

//H is the sensor that gets the variable to regulate, resisitive sensor in voltage mode
//fc crossover frequency pm phase margin in degrees Gcompensate the transfer function to compensate
//fs sampling freq

//stacksize('max')
//Uncompensated loop gain
Tuz=H*Gcompensate


//Cross-over pulsation
wc=2*%pi*fc;

//Check that the phase margin is achievable with PI at given crossover frequency

wp=2*fs; //pole due to the discrete nature

wcp=2*fs*tan(wc/fs*1/2); //cross over frequency in P domain as defined in page 127
//wcp=10.3e3
fcp=wcp/(2*%pi); //To evaluate the gain and phase



//Evaluation of tuz at the desired crossover frequency
response=repfreq(Tuz,fcp);
m=abs(response); //magnitude in natural units
//m=1.23
//From Dragan example


[mdB,p]=dbphi(response);// p is phase in degrees note that it has a wrap at 180 degree
//p=-108


//This prewarp is the one that makes problems
//if(real(response)<0) then
//
if(and([real(response)<0,imag(response)>0])) then
    pto180=180-p
    p=-180-pto180 //Unwrapping the phase


end


p=p*%pi/180;
pmu=%pi+p;//phase margin uncompensated is the  phase margin you will have if you just escale Tuz so mag at wc is 0



//Pag 135

//pw= atan(wcp/wp) //phase effect  prewarp p133
minpm= pmu -atan(wp/wcp);//Minimum phase margin
pm=pm/180*%pi; // pm expressed in rad


if pm>pmu then
    disp('Phase boost needed at fc needs PID')
    abort;//exit function
    elseif(pm<minpm)
    disp('Too low phase margin for PI')
    abort; //exit function
end

////// Very careful
//pmu=max(pmu,0)





//Zero of the to achieve the phase desired
wPI=wcp*tan(pmu-pm);
Gpi_inf=1/m*1/sqrt(1+(wPI/wcp)^2); //PI gain so the cross over is OK


//Paralell PID Gains from page 125
Kp=Gpi_inf*(1-wPI/wp)
Ki=2*Gpi_inf*wPI/wp;
Kd=0;

//Paralell PID regulator transfer function
z=poly(0,'z') //definition of Z
tfPI=Kp+Ki/(1-z^-1);
Gcz=syslin(1/fs,tfPI) //PID system

Tz=Gcz*Tuz//Open-loop gain


//Representations of the frequency responses
frq=1e0:1:fs/2;
scf()
//subplot(1,2,1)
bode(Gcz,frq,'PID transfer')

scf()
//subplot(1,2,2)
bode([Tz; Tuz],frq,['Compensated','Uncompensated'])



//Phase and gain margins
[fcross,p_mo,f_pi,g_m]=margins(Tz,frq)


endfunction


//function [Kp,Kd,Ki,Tz,Tuz,Gcz,p_m,fcross,g_m,f_pi]=PI_regulator_limit(fc,fs,H,Gcompensate)

//H is the sensor that gets the variable to regulate, resisitive sensor in voltage mode
//fc crossover frequency pm phase margin in degrees Gcompensate the transfer function to compensate
//fs sampling freq
//This is an example with the limit cycle approach p

//stacksize('max')
//Uncompensated loop gain
//Tuz=H*Gcompensate


//Evaluation of the function to compensate at  DC
//Evaluation of tuz at the desired crossover frequency
//response=repfreq(Tuz,1e-3); //To avoid singularities
//m=abs(response); //magnitude in natural units
//Tu_0=m;

// No limit condition  pag 180 Maksimovic
//Ki=1/Tu_0;
//Condition is stricly less than so for security  resons I will multiply it by 0.8
//Ki=0.8*Ki;

//Cross-over pulsation
//wc=2*%pi*fc;

//Check that the phase margin is achievable with PI at given crossover frequency

//wp=2*fs; //pole due to the discrete nature

//wcp=2*fs*tan(wc/fs*1/2); //cross over frequency in P domain as defined in page 127

//fcp=wcp/(2*%pi); //To evaluate the gain and phase



//Evaluation of tuz at the desired crossover frequency
//response=repfreq(Tuz,fcp);
//m=abs(response); //magnitude in natural units




//[mdB,p]=dbphi(response);// p is phase in degrees note that it has a wrap at 180 degree



//This prewarp is the one that makes problems
//if(real(response)<0) then
//
//if(and([real(response)<0,imag(response)>0])) then
  //  pto180=180-p
  //  p=-180-pto180 //Unwrapping the phase


//end


//p=p*%pi/180;
//pmu=%pi+p;//phase margin uncompensated is the  phase margin you will have if you just escale Tuz so mag at wc is 0



//Pag 135

//pw= atan(wcp/wp) //phase effect  prewarp p133
//minpm= pmu -atan(wp/wcp);//Minimum phase margin
//pm=pm/180*%pi; // pm expressed in rad


//if pm>pmu then
 //   disp('Phase boost needed at fc needs PID')
 // abort;//exit function
 //   elseif(pm<minpm)
 //  disp('Too low phase margin for PI')
 //   abort; //exit function
//end

////// Very careful
//pmu=max(pmu,0)





//Zero position to achieve the desired Kpi
//a=m*Ki/2*wp;

//if(a/wcp>1) then //avoid gettin a complex value later
    //m_max=wcp/wp*2/Ki;
    //disp('Chose a wc so m is')
  //  pause
  //  abort
//end

//wPI=a/sqrt(1-(a/wcp)^2);
//Gpi_inf=1/m*1/sqrt(1+(wPI/wcp)^2); //PI gain so the cross over is OK


//Paralell PID Gains from page 125
//Kp=Gpi_inf*(1-wPI/wp)
//Ki_2=2*Gpi_inf*wPI/wp;
//Kd=0;


//Paralell PID regulator transfer function
//z=poly(0,'z') //definition of Z
//tfPI=Kp+Ki/(1-z^-1);
//Gcz=syslin(1/fs,tfPI) //PID system

//Tz=Gcz*Tuz//Open-loop gain


//Representations of the frequency responses
//frq=1e0:1:fs/2;
//scf()
//subplot(1,2,1)
//bode(Gcz,frq,'PID transfer')

//scf()
//subplot(1,2,2)
//bode([Tz; Tuz],frq,['Compensated','Uncompensated'])



//Phase and gain margins
//[fcross,p_mo,f_pi,g_m]=margins(Tz,frq)


//endfunction
