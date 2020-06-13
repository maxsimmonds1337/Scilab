//function to scale, round and codify teh PID coefficients, function will be modified so integrator has no pole at origin

function [Kp_r,Ki_r,Kd_r,Gc_r,Gc_r_NL,Gc,lambda,pm_r,gm_r,fcross_r]=PIDround_NL(Kp,Ki,Kd,Vadc,NbitsADC,NbitsPWM,N_pole,fs,eo,ec,fc,plant)
    //Inputs are the coeffiencts as the output of PID_regulator, Vadc scale of the adc
    //NbitsADC number of bts in the ADC, NbitsPWM number of bits in the PWM and the sampling/switching frequency
    //ec precision required at crossover frequency (fc) eo precission required at DC
    //Plant is the plant to control 
    //Outputs are the rounded coefficients, the rounded Gain of the controller, the Gain of the controller, lambda is the scaling introduced by the ADC and the PWM, and finally the gain and phase margins after the rounding
    //N_pole are the number of bits to represent integrators pole at origin,
    
    Nr=2^NbitsPWM;
    Nadc=2^NbitsADC;
    
    lambda=(Vadc/Nadc)*Nr; //scale of the coeffcients due to ADC and PWM

    //Scaling of the coefficients
    Ki_s=lambda*Ki;
    Kp_s=lambda*Kp;
    Kd_s=lambda*Kd;
    //Scaled PID transfer function
    z=poly(0,'z') //definition of Z
    tfPID=Kp_s+Ki_s/(1-z^-1)+Kd_s*(1-z^-1);
    Gc=syslin(1/fs,tfPID) //PID system
    
    //The DC error will depend only on the quantization of Ki_s
   
    for(n_i=2:10) //we will assume a maximum of 10 bits
        [ki_r,dki,Ki_r]=Qn(Ki_s,n_i)
        rel_error=abs(dki/ki_r);
        if(rel_error<eo)
            break
        end
    end
    
    //The error at fc will depend on kd and kp a graphical approach will be used
    n_d=2:1:10; //Bits to quantify Kd_s
    n_p=2:1:10; //Bits to quantify Kp_s
    errors=zeros(length(n_d),length(n_d));
    for (ip=1:length(n_p))
        [kp_r,dkp,Kp_r]=Qn(Kp_s,n_p(ip));
        
        for (id=1:length(n_d))
            [kd_r,dkd,Kd_r]=Qn(Kd_s,n_d(id));
            tfPIDr=kp_r+ki_r/(1-z^-1)+kd_r*(1-z^-1);
            Gc_r=syslin(1/fs,tfPIDr) //PID system with rounded coefficients
            tfPIDerr=dkp+dki/(1-z^-1)+dkd*(1-z^-1);
            Gc_err=syslin(1/fs,tfPIDerr); //PID system of the error
            response_r=repfreq(Gc_r,fc); //response of quantized
            response_err=repfreq(Gc_err,fc);//response of the error
            
            errors(ip,id)=abs(response_err/response_r);
        end
    end
    
    //graphical representation
    scf()
    contour(n_p,n_d,errors,[0.5*ec 0.75*ec ec 2*ec 10*ec])
    xlabel("n_p")
    ylabel("n_d")
    
    //Select the definitive number of bits
    disp("Number of bits for Kp_r:")
    n_p_def=input('kpr')
    disp("Number of bits for Kd_r:")
    n_d_def=input('kdr')
    
    //Definitive quantization
    
    [kd_r,dkd,Kd_r]=Qn(Kd_s,n_d_def);
    [kp_r,dkp,Kp_r]=Qn(Kp_s,n_p_def);
     tfPIDr=kp_r+ki_r/(1-z^-1)+kd_r*(1-z^-1);
     Gc_r=syslin(1/fs,tfPIDr) //PID system with rounded coefficients
     
     k_Pole=((2^N_pole-1)/2^N_pole);
     tfPIDr_nl=kp_r+ki_r/(1-k_Pole*z^-1)+kd_r*(1-z^-1);
     Gc_r_NL=syslin(1/fs,tfPIDr_nl) //PID system with rounded coefficients and integrator moved from the unit circle
     //pause
     Tz=Gc/lambda*plant;
     Tz_r=Gc_r/lambda*plant; //Open loop gain for comparison
     Tz_r_nl=Gc_r_NL/lambda*plant; //Open loop gain for comparison
     
     frq=1e0:10:fs/2;
     scf()
     bode([Gc;Gc_r;Gc_r_NL],frq,['PID transfer'; 'PID rounded Transfer';'PID rounded NL Transfer'])
     scf()
     bode([Tz;Tz_r;Tz_r_nl],frq,['Open loop gain'; 'Open loop gain rounded';'Open loop gain rounded NL'])
     [pm_r,fcross_r]=p_margin(Tz_r_nl) //Phase margin obtained
    [gm_r,f_pi]=g_margin(Tz_r_nl)//Gain margin

    //Pole Zero representation
    scf()
    subplot(1,2,1)
    plzr([tfPIDr])
    subplot(1,2,2)
    plzr([tfPIDr_nl])



return
endfunction


//function to scale, round and codify teh PID coefficients

function [Kp_r,Ki_r,Kd_r,Gc_r,Gc,lambda,pm_r,gm_r,fcross_r]=PIDround(Kp,Ki,Kd,Vadc,NbitsADC,NbitsPWM,fs,eo,ec,fc,plant)
    //Inputs are the coeffiencts as the output of PID_regulator, Vadc scale of the adc
    //NbitsADC number of bts in the ADC, NbitsPWM number of bits in the PWM and the sampling/switching frequency
    //ec precision required at crossover frequency (fc) eo precission required at DC
    //Plant is the plant to control 
    //Outputs are the rounded coefficients, the rounded Gain of the controller, the Gain of the controller, lambda is the scaling introduced by the ADC and the PWM, and finally the gain and phase margins after the rounding
    
    Nr=2^NbitsPWM;
    Nadc=2^NbitsADC;
    
    lambda=(Vadc/Nadc)*Nr; //scale of the coeffcients due to ADC and PWM

    //Scaling of the coefficients
    Ki_s=lambda*Ki;
    Kp_s=lambda*Kp;
    Kd_s=lambda*Kd;
    //Scaled PID transfer function
    z=poly(0,'z') //definition of Z
    tfPID=Kp_s+Ki_s/(1-z^-1)+Kd_s*(1-z^-1);
    Gc=syslin(1/fs,tfPID) //PID system
    
    //The DC error will depend only on the quantization of Ki_s
   
    for(n_i=2:10) //we will assume a maximum of 10 bits
        [ki_r,dki,Ki_r]=Qn(Ki_s,n_i)
        rel_error=abs(dki/ki_r);
        if(rel_error<eo)
            break
        end
    end
    
    if(Kd>0) //If we have a PID
        //The error at fc will depend on kd and kp a graphical approach will be used
        n_d=2:1:10; //Bits to quantify Kd_s
    //if(Kd==0)
      //  n_d=ones(n_d);// In case of PI nd+0 and unse only 1 bit to represent it
        //end
        n_p=2:1:10; //Bits to quantify Kp_s
        errors=zeros(length(n_d),length(n_d));
        for (ip=1:length(n_p))
        [kp_r,dkp,Kp_r]=Qn(Kp_s,n_p(ip));
        
            for (id=1:length(n_d))
            [kd_r,dkd,Kd_r]=Qn(Kd_s,n_d(id));
            tfPIDr=kp_r+ki_r/(1-z^-1)+kd_r*(1-z^-1);
            Gc_r=syslin(1/fs,tfPIDr) //PID system with rounded coefficients
            tfPIDerr=dkp+dki/(1-z^-1)+dkd*(1-z^-1);
            Gc_err=syslin(1/fs,tfPIDerr); //PID system of the error
            response_r=repfreq(Gc_r,fc); //response of quantized
            response_err=repfreq(Gc_err,fc);//response of the error
            
            errors(ip,id)=abs(response_err/response_r);
            end
        end
    else //it is a PI controller
        for(n_p=2:10) //we will assume a maximum of 10 bits
        [kp_r,dkp,Kp_r]=Qn(Kp_s,n_p)
        rel_error=abs(dkp/kp_r);
        if(rel_error<ec)
            break
        end
        end
    
    
    end

    if(Kd>0)
    //graphical representation
    scf()
    //contour(n_p,n_d,errors,[0.5*ec 0.75*ec ec 2*ec 10*ec])
    contour(n_p,n_d,errors,5)
    xlabel("n_p")
    ylabel("n_d")
    
    //Select the definitive number of bits
    disp("Number of bits for Kp_r:")
    n_p_def=input('kpr')
    
    disp("Number of bits for Kd_r:")
    n_d_def=input('kdr')
    
    
    
    else
    n_p_def=n_p;// if PI take the number before
    n_d_def=1;
    end
    //Definitive quantization
    [kd_r,dkd,Kd_r]=Qn(Kd_s,n_d_def);
    [kp_r,dkp,Kp_r]=Qn(Kp_s,n_p_def);
     tfPIDr=kp_r+ki_r/(1-z^-1)+kd_r*(1-z^-1);
     Gc_r=syslin(1/fs,tfPIDr) //PID system with rounded coefficients
     Tz=Gc/lambda*plant;
     Tz_r=Gc_r/lambda*plant; //Open loop gain for comparison
     
     frq=1e0:10:fs/2;
     scf()
     bode([Gc;Gc_r],frq,['PID transfer'; 'PID rounded Transfer'])
     scf()
     bode([Tz;Tz_r],frq,['Open loop gain'; 'Open loop gain rounded'])
     [pm_r,fcross_r]=p_margin(Tz_r) //Phase margin obtained
    [gm_r,f_pi]=g_margin(Tz_r)//Gain margin

    //Pole Zero representation
    scf()
    plzr([tfPIDr])



return
endfunction





//Function to round a quantity According to pag.295
function [xq,dx,cod]=Qn(x,n)
    //x quantity to round,
    //n number of bits,outputs are xk the x quantized and codified and dx the error
    //cod is a structure where everything is stored
    //cod.w is the significand
    //cod.q is the scale
    //cod.n is the number of bits
    //cod.s is the digital word
    
    if (x==0) then
        x1=x;
        xq=0;
        q=1;
        wd=0;
        s=['0'+dec2bin(wd,n-1)]; // 
    else
    
            x1=x;
            x=abs(x);
            neg=x<0; //check if signal is negative
            E=floor(log2(x)); //close representation in base 2 as an integer power
            F=2^(log2(x)-E); //Part that it is not can be reprsented as a power of 2
            q=E-(n-2);//q is the scale, the lowest power of 2 necessary to represent the quantity
            //Equation B.10 explains why starts in n-2
            wd=round(F*2^(n-2));// significand
            if(wd==1)
             wd=round(F*2^(n-3));
            q=q+1;
        end;
    
        if(neg)
            xq=-wd*2^q
            s=['1'+dec2bin(-wd+2^(n-1),n-1)] // In b2c negatives numbers are expresed by adding one
            wd=-wd;
        else
            xq=wd*2^q
            s=['0'+dec2bin(wd,n-1)] // 
            wd=wd;
        end;
    end
    //error 
    dx=xq-x1;
    //output of the data
    cod.xq=xq;
    cod.w=wd;
    cod.q=q;
    cod.n=n;
    cod.s=s;
    cod.dx=dx;
    return
endfunction

