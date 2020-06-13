////Boost Parameters
Lboost=20e-6
rl=1e-3; //parasitic resitance of inductor
Cboost=1000e-6
rc=1e-3;//parasitic resitance of capacitor
Vin=9

Pout=10; //Power demand
Vo=2*Vin //Vo will represent the battery. Following fig 3.17 of corradini book
Rl=1 //Rl will model the output impedance of the battery
Iload=Pout/Vo; //This will model the current demand

D=1-Vin/Vo; //for a boost steady state duty cycle
fsw=100e3
Tsw=1/fsw

//Control time is the time between you get a sample an it is applied
//I will split it in the time between you get the sample and the MSOFET turns-on and then the steady state duty cycle
//Thsi will be the time you will have available to calculate the new duty cycle each time you get a sample.
t_sample=1e-6

t_Delay=1e-6; //This is the time between the sample is taken and the new duty cycle calculated
//get the model
[Gvuz,Gvus,Giuz,Gius]=Boost_ss_model_2f(Lboost,rl,Cboost,rc,Vin,D,Vo,Iload,Rl,t_Delay,fsw,1,3);
//1 n_sub the subsampling ratio and 3 is to get the graphs of Current and voltage transfer function
//Gvuz and Giz are respectively the discrete transfer function 7he one with s are the continuous
//Loop design

H_i=1; //feedback gain for current adjust it to your design
H_v=1; //feedback gain for voltage

plantI=Giuz*H_i; //This the plant to control for the current

//Tune a digital PI for the current loop
fcI=fsw/10; ///Cutoof freq 1/10 fo the fsw
pmI=60 //phase margin
[Kp_i,Kd_i,Ki_i,T_iz,Tiz_u,Ciz,p_mi,fcrossi,g_mi,f_pii]=PI_regulator(fcI,pmI,fsw,1,plantI)
//Open loop chain for the current
T_i=Ciz*plantI;

//The reference to this loop will be the one that you will change
//You will have one coming from the voltage control loop
//or one coming from the MPPT control


//I will follow for the voltage control loop
//Following the multiloop approach in Corradini's book
//Ciz is the current controller the duty cycle command acts over the voltage transfer function Gvuz
//it is divided by (1+Tiz) because the current loop is closed


plantV=H_v*Gvuz*Ciz/(1+T_i)

//Tune a digital PI for the current loop
fcV=fcI/10; ///Cutoof freq 1/10 of th cut-off frequency of the current voltage loop
pmV=60 //phase margin
[Kp_v,Kd_v,Ki_v,T_vz,Tvz,Cvz,p_mv,fcrossv,g_mv,f_piv]=PI_regulator(fcV,pmV,fsw,1,plantV)

//Both current and voltage loops have been designed now they have to be adapeted to the microcontroller  implementation
Vadc=3.3; //ADC reference Voltage
N_adc=8; // Number of bits of the ADC
N_PWM=8; //number of bits of PWM

//Error at fc and DC
e_0=0.1; //Maximum error at DC
e_c=0.01; //macimum error at cut-off frequency
//Adaptation of the current loops
[Kp_i_r,Ki_i_r,Kd_i_r,Gc_i_r,Gc_i,lambda_i,pm_r_i,gm_r_i,fcross_r_i]=PIDround(Kp_i,Ki_i,Kd_i,Vadc,N_adc,N_PWM,fsw,e_0,e_c,fcI,plantI)
//Lambda_i will be the scaling due to the binary quantization
//Ti_r is the Gc_r/lambda*plantI;
T_ir=Gc_i_r/lambda_i*plantI;
//Voltage plant under Tz_r quantization

plantV_r=H_v*Gvuz*Gc_i_r/lambda_i/(1+T_ir);

//Now we round the voltage loop
[Kp_v_r,Ki_v_r,Kd_v_r,Gc_v_r,Gc_v,lambda_v,pm_r_v,gm_r_v,fcross_r_v]=PIDround(Kp_v,Ki_v,Kd_v,Vadc,N_adc,N_PWM,fsw,e_0,e_c,fcV,plantV_r);

//The quantized values are in the Kp_v_r,Ki_v_r, Kp_i_r, Ki_i_t
//the number you have to put in the microcontroller is in the xq field. The rest are for VHDL implementation
//Xq is calculated as Kp_xx_r.w*2^Kp_xx_r.q It may give you an indication on how to represent the bits.
