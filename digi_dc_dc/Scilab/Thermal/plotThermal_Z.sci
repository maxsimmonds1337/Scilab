//Function to plot the thermal impedance of a Mosfet in various modes 
// param is a string 'nn' both axis in linear,'ln', x in linear y in log 'll' both in log
function []=plotThermal_Z(Zth,end_time,param)
    
//verify time in linear
time_lin=linspace(0,end_time,10000);

step_res=csim('step',time_lin,Zth);

scf()
plot2d(param,time_lin,step_res,2);
xlabel('time (s)')
ylabel('ºC/W')
endfunction
