//Function to calculate a PID regulator from a Transfer function a crossover frecuency and phase margin

function [Kp,Kd,Ki,Tz,Tuz,Gcz,p_m,fcross,g_m,f_pi]=PID_regulator(fc,pm,fs,H,Gcompensate)

//H is the sensor that gets the variable to regulate, resisitive sensor in voltage mode
//fc crossover frequency pm phase margin in degrees Gcompensate the transfer function to compensate
//fs sampling freq

//stacksize('max')
//Uncompensated loop gain
Tuz=H*Gcompensate

//Cross-over pulsation
wc=2*%pi*fc;

wp=2*fs; //pole due to the discrete nature

//wcp=2*fs*tan(wc/fs*1/2); //cross over frequency in P domain as defined in page 127
//wcp=10.3e3
//fcp=wcp/(2*%pi); //To evaluate the gain and phase



//Evaluation of tuz at the desired crossover frequency 
response=repfreq(Tuz,fc);

m=abs(response); //magnitude in natural units
[mdB,p]=dbphi(response);// p is phase in degrees note that it has a wrap at 180 degree

//This prewarp is the one that makes problems
//if(real(response)<0) then
//
if(and([real(response)<0,imag(response)>0])) then
    pto180=180-p
    p=-180-pto180 //Unwrapping the phase
    
    
end


p=p*%pi/180;
pmu=%pi+p;//phase margin uncompensated is the  phase margin you will have if you just escale Tuz so mag at wc is 0




//Check that the phase margin is achievable with PID at given crossover frequency

wp=2*fs; //pole due to the discrete nature

wcp=2*fs*tan(wc/fs*1/2); //cross over frequency in P domain as defined in page 127

pw= atan(wcp/wp) //phase effect 
maxpm= pmu +%pi/2 - pw;//Maximum phase margin
pm=pm/180*%pi; // pm expressed in rad


if pm>maxpm then
    disp('Phase boost needed at fc above 90 deg (max achieved by PID)')
    abort//exit function
    elseif(pm<pmu)
    disp('No phase boost needed use PI')
    abort //exit function
end

////// Very careful
//pmu=max(pmu,0)

wPD=wcp/tan(pm-pmu+pw)//pulsation of the zero for the phase boost 
//according to 4.29 (pag 128) pag 133 includes unwrapping in this calculation i have done it in line 27

 //The gain at that frequency is chosen so the open-loop gain is 0 dB
 Gpd_0=1/m*sqrt(1+(wcp/wp)^2)/sqrt(1+(wcp/wPD)^2)

//Zero of the PI chosen so frequency is 1/20 of the crossover frequeuency
wPI=2*%pi*fc/20;
Gpi_inf=1; //PI gain at infinity 1 so it does not affect

//Paralell PID Gains from page 125
Kp=Gpi_inf*Gpd_0*(1+wPI/wPD-2*wPI/wp)
Ki=2*Gpi_inf*Gpd_0*wPI/wp;
Kd=1/2*Gpi_inf*Gpd_0*(1-wPI/wp)*(wp/wPD-1);

//Paralell PID regulator transfer function
z=poly(0,'z') //definition of Z
tfPID=Kp+Ki/(1-z^-1)+Kd*(1-z^-1);
Gcz=syslin(1/fs,tfPID) //PID system

Tz=Gcz*Tuz//Open-loop gain

//Representations of the frequency responses
frq=1e0:1:fs/2;
scf()
subplot(1,2,1)
bode(Gcz,frq,'PID transfer')

subplot(1,2,2)
bode([Tz; Tuz],frq,['Compensated','Uncompensated'])



//Phase and gain margins
[fcross,p_m,f_pi,g_m]=margins(Tz,frq)


endfunction
    
