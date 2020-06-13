// function for extracting the discrete model for a Boost converter
//Taken from "Digital control of high frequency PWM converters" p.14
// It will assume a trailing edge modulator
//It will be based in two functions first the one that calculates the matrixes, then the PWM modulator
function [Gvuz,Gvus,Giuz,Gius]=Boost_ss_model_2f(L,rl,C,rc,Vg,D,Vload,Iload,Rload,tctrl,Fs,n_sub,mod)
    //Outputs are the discrete Model Wz and the continous model Ws
    //iput parameters are inductance L, inductance parasisitc resistor rl, capacitor C, resistance in capacitor rC, input oltage Vg, steady state duty cycle D
    //Voltage on load Vload, current Iload, load Resistance Rload, delay between sample and latch of the duty cyce tcntrl and switching frquency Fs
    //n_sub is the number of switching cycles between samples
    //Mod indicates the transfer function to plot 1 for control to output voltage, 2 control to current voltage and 3 both


    //Get the Matrixes
    [A1,A0,b1,b0,c1,c0,V]=Boost_matrix(L,rl,C,rc,Vg,D,Vload,Iload,Rload)

    //Propagate the states using the modulator
    [Gvuz,Gvus,Giuz,Gius]=trailingPWM(A1,A0,b1,b0,c1,c0,V,D,tctrl,Fs,n_sub,mod)


    endfunction
