//Function to get the scalings of the intermediate signals in a PID regulator
//According to rules for addition and multiplication stated in AppendixB
function [up,up_r,ui,ud,ud_r,err,upd,upid,wi,wi_r]= PID_reg_scales_3(Kp_r,Ki_r,Kd_r,Nbitsadc,Nbitspwm)
    //up, ui, ud ,wi,wd are structures with n number of bits and q scale of
    //the signals that contain the proportional  integral
    // and differential parts of the controller represented in pag.224
    //Ki_r,Kp_r,Kd_r are the output of the function PIDround

    //Definition from the error and the scale from ADC
    err.n=Nbitsadc+1;
    err.q=0;
    
    //Defintion of the common scale for the final sumation
    qcommon=min([Kp_r.q,Ki_r.q,Kd_r.q]);
    //Definiton of the upid line,
    //scale will be qcommon
    upid.q=qcommon;
    upid.n=Nbitspwm+1-qcommon; //In that scale the PWM or upid will limit the duty command 
    
    //up will be an integer multiple of the error,therefore 
    //its number of lines and scale will follow multiplication rules
    //lnght sum of the length scale the sum o the scales
    
    
    up.q=Kp_r.q+err.q; //scale will be the sum
    up.n=Kp_r.n+err.n;// number of bits will be the sum
    
    //Scaling of the differential error lines
    //wd are the ones that perform ths substraction of the errors (the diferential)
    //it scales is the same as the ADC
    //Wd is the diference between actual and past error
    wd.q=err.q;
    wd.n=err.n+1; // this will mean that from one sample to another the error is the same value but opposite sign,
                    // which is not possible
  
   //ud is the diferential error scaled so multiplication rules apply
    ud.q=wd.q+Kd_r.q;
    ud.n=wd.n+Kd_r.n;
    
    //Scaling of up and ud to the common scale
    //Check if upid number of bits is enough to accomodate the expansion of the sum of up and ud
   shift_ud_udr=-qcommon+ud.q; //How many bits must I extend ud so is in the qcommon scale
   shift_up_upr=-qcommon+up.q; //How many bits must I extend up so is in the qcommon scale
    max_up_ud=max([up.n+shift_ud_udr,ud.n+shift_ud_udr]);
    
    //if(max_up_ud>upid.n) then
        //disp('Not enough number of bits in the PWM');
        //abort;
        //end
   up_r.n=up.n+shift_up_upr; // Bits for the re escaled up_r
   ud_r.n=ud.n+shift_ud_udr;// Bits for the re escaled ud_r
    
    //Definiton of the upd part
    upd.n=max([up_r.n,ud_r.n])+1;
    upd.q=qcommon;
    
    upid.n=max(Nbitspwm+1-qcommon,upd.n+1); //In that scale the PWM or upid will limit the duty command 
    //set by upid and PD
    
    
    //Scaling of the integral part 
    //multiplication of the error time Ki_r
    wi.q=err.q+Ki_r.q;
    wi.n=err.n+Ki_r.n;
    //Re escaling of the integral part to qcommon
    shift_wi_wir=-qcommon+wi.q;
    wi_r.q=qcommon;
    wi_r.n=wi.n+shift_wi_wir;
    
    //ui and ui1 has one bit less than as upid, this are the ones that saturate
    ui.n=upid.n-1;
    ui.q=qcommon;
    
    return
endfunction
