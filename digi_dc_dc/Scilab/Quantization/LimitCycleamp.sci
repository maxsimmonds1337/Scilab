function [Kp_limit,Ki_limit,Vlimit,Gcz_l]=LimitCycleamp(Kp,Ki,Nbitsection,H,nq,Vfs,Nadc,margin,fs)
    //This function scales Kp and Ki so the limit cycle has an amplitude of Amp_limit, the gain of the feedback resistor is set by H and the number of sections is needed
    //In digital the limit cycle will be limitid to 1 bit error limited ot (+-nq) fs is the sampling freq
    V_limit_ad=nq*Vfs/(2^Nadc);
    Vlimit=1/H*V_limit_ad
    
    KiKp=Kp+Ki
    KiKpmax=1/Nbitsection*1/V_limit_ad //This is the limit so the limit cycle is in one section    
    //This aproach limits all the gains
    Kscale=KiKpmax/KiKp;
    Kscale=Kscale*margin
    Kp_limit=Kp*Kscale;
    Ki_limit=Ki*Kscale;
    
    //Paralell PID regulator transfer function
z=poly(0,'z') //definition of Z
tfPI=Kp_limit+Ki_limit/(1-z^-1);
Gcz_l=syslin(1/fs,tfPI) //PID system

endfunction


function [Kp_limit,Ki_limit,Vlimit,Gcz_l]=LimitCycleamp2(Kp,Ki,Nbitsection,H,nq,Vfs,Nadc,margin,fs,Duty_steady)
    //This function scales Kp and Ki so the limit cycle has an amplitude of Amp_limit, the gain of the feedback resistor is set by H and the number of sections is needed
    //In digital the limit cycle will be limitid to 1 bit error limited ot (+-nq) fs is the sampling freq
    V_limit_ad=nq*Vfs/(2^Nadc);
    Vlimit=1/H*V_limit_ad
    
    KiKp=Kp+Ki// with an error of one the new Duty cycle will be the steady plus Kp + Ki
    Duty_total=Duty_steady*1/Nbitsection; //The duty cycle expressed as a fraction of the whole current
    KiKpmax=Duty_steady*1/Nbitsection*1/V_limit_ad //This is the limit so the limit cycle is in one section    
    //This aproach limits all the gains
    Kscale=KiKpmax/KiKp;
    Kscale=Kscale*margin
    Kp_limit=Kp*Kscale;
    Ki_limit=Ki*Kscale;
    
    //Paralell PID regulator transfer function
z=poly(0,'z') //definition of Z
tfPI=Kp_limit+Ki_limit/(1-z^-1);
Gcz_l=syslin(1/fs,tfPI) //PID system

endfunction

function [Kp_limit,Ki_limit,Vlimit,Gcz_l]=LimitCycleamp3(Kp,Ki,Nbitsection,H,nq,Vfs,Nadc,margin,fs,Duty_steady)
    //This function scales Ki so the limit cycle has an amplitude of Amp_limit, the gain of the feedback resistor is set by H and the number of sections is needed
    //In digital the limit cycle will be limitid to 1 bit error limited ot (+-nq) fs is the sampling freq
    V_limit_ad=nq*Vfs/(2^Nadc);
    Vlimit=1/H*V_limit_ad
    
    KiKp=Kp+Ki// with an error of one the new Duty cycle will be the steady plus Kp + Ki
    Duty_total=Duty_steady*1/Nbitsection; //The duty cycle expressed as a fraction of the whole current
    KiKpmax=Duty_steady*1/Nbitsection*1/V_limit_ad //This is the limit so the limit cycle is in one section    
    //This aproach limits all the gains
    Kimax=KiKpmax-Kp;
    Kscale=Kimax/Ki
    Kscale=Kscale*margin
    Kp_limit=Kp
    Ki_limit=Ki*Kscale;
    
    //Paralell PID regulator transfer function
z=poly(0,'z') //definition of Z
tfPI=Kp_limit+Ki_limit/(1-z^-1);
Gcz_l=syslin(1/fs,tfPI) //PID system

endfunction
