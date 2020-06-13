//function to scale, round and codify the PID coefficients

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
        
    //If one of the Kp or Kd is a power of 2 the lines will be vertical or horizontal
    scf()
    mesh(n_p,n_d,errors*100)
    xlabel("n_p")
    ylabel("n_d")
    //graphical representation
    scf()
    //contour(n_p,n_d,errors,[0.5*ec 0.75*ec ec 2*ec 10*ec])
    contour(n_p,n_d,errors.*100,10)
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
