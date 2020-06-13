function [Vo,D_quantiz_out,Vref_quantiz,Ki_max]=limit_cycle(Vg,Vref,H,Nbitspwm,Vadc,Nbitsadc,Ki)
    //Function to check if duty cycle conditions appear in a buck converter
    //Variation of the output voltage agaisn tvariation of duty cycle in the 
    //in the vicinity ot the steady state duty cycle
    deltaMdeltad=1; //in the case of the buck is 1
    
    //Quantization of the output voltage
    qu=1/2^Nbitspwm;// Quantization of the duty cycle
    qvo_dpwm=deltaMdeltad*Vg*qu;
    
    //Quantization of the ADC
    qvs_ADC=Vadc*1/2^Nbitsadc;
    

    //Resolution no limit cycle condition (5.23)
    Res_condition = H*qvo_dpwm<qvs_ADC; //A variation of the output voltage 
    //seen in the sensor H due to minimum step in PWM should be smaller
    //than a step in the ADC
    
    //Integral no limit cycle condition (5.35)
    Gvd_0=deltaMdeltad*Vg; //Gain of the converter at frequency 0
    //Gvd_0=1;
     //A step due to the integral gain should be smaller than a step in the AD
    int_condition=Gvd_0*Ki*H<1;
    Ki_max=1/(H*Gvd_0);
    //Resolution no limit cycle condition
    
    
    Vref_quantiz=floor(Vref/Vadc*(2^Nbitsadc-1))//Value of the reference in the digital domain
    
    D_quantiz=0:1:2^Nbitspwm-1; //All the possible duty cycles
    Vs_D_quantiz=H*Vg*D_quantiz*qu; //All the possible output voltage values seen in the sensor
    Vs_D_quantiz_ADC=floor(min(Vs_D_quantiz,Vadc)/Vadc*(2^Nbitsadc-1)); //All the outpt voltages expressed in the digital domain
    error_quantiz=Vref_quantiz-Vs_D_quantiz_ADC;
    index_error_0=find(error_quantiz==0); //find the duty cycles that will lead to a zero error
    Vo=Vs_D_quantiz(index_error_0)/H;//If there is more than one duty cycle that leads to zero error this means that ther will be no limit cycles
    //The converter will find error 0 in a"wide" so the duty command will not change
    D_quantiz_out=D_quantiz(index_error_0);
    if(~Res_condition)
        disp('Increase PWM resolution  or decrease AD resolution')
        abort
    elseif(~int_condition)
        disp('Reduce integral gain Ki (you do not compromise much fc and phase margin)')
        abort
    end
   
endfunction
