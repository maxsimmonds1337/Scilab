//Function to write the configuration in a VHD file
//to implement the designed regulator
function [status]=write_configuration(NbitsADC,NbitsPWM,NresetPWM,n_clk_PID,n_clk_ADC,Vref_coded,Kp_r,Ki_r,Kd_r,up,up_r,ui,ud,ud_r,err,upd,upid,wi,wi_r)

// open a file as text with write property
[fd_w,status] = mopen('PID_conf.vhd', 'wt');

//if(status~0)// check if the file was corretly opened
//   abort
//else
    // Write the header
    r = mputl('library IEEE;', fd_w);
    r = mputl('use IEEE.STD_LOGIC_1164.all;', fd_w);
    r = mputl('use ieee.numeric_std.all; ', fd_w);
    r = mputl('package PID_conf is', fd_w);
    
    //write the parameters for the ADC
    string2write='----parameters for the size of the ADC';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT  n_bits_adc : integer :='+string(NbitsADC)+';';
    r = mputl(string2write, fd_w);
    //write the parameters for the DPWM
    string2write='----parameters for the size of the DPWM';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_bits_pwm_t : integer :='+string(NbitsPWM)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_reset_pwm_t : integer :='+string(NresetPWM)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_delay_PID_t : integer :='+string(n_clk_PID)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_delay_ADC_t : integer :='+string(n_clk_ADC)+';';;
    r = mputl(string2write, fd_w);
    
    //write the parameters for the line sizes
    string2write='----parameters for size of operands, come from PID_reg_scales';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_kp_t : integer:='+string(Kp_r.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT q_qp_t : integer :='+string(Kp_r.q)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_ki_t : integer :='+string(Ki_r.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT q_ki_t : integer :='+string(Ki_r.q)+';';
    r = mputl(string2write, fd_w);
    
    string2write='CONSTANT n_kd_t : integer :='+string(Kd_r.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT q_kd_t : integer :='+string(Kd_r.q)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_up_t : integer :='+string(up.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT q_up_t : integer :='+string(up.q)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_up_r_t : integer :='+string(up_r.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_ud_t : integer :='+string(ud.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT q_ud_t : integer :='+string(ud.q)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_ud_r_t : integer :='+string(ud_r.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_error_t : integer :=' +string(err.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_upd_t : integer :='+string(upd.n)+';';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT n_upid_t : integer :='+string(upid.n)+';';
    r = mputl(string2write, fd_w);
     string2write='CONSTANT q_upid_t : integer :='+string(upid.q)+';';
    r = mputl(string2write, fd_w);
     string2write='CONSTANT n_wi_t : integer :='+string(wi.n)+';';
    r = mputl(string2write, fd_w);
     string2write='CONSTANT n_wi_r_t : integer :='+string(wi_r.n)+';';
    r = mputl(string2write, fd_w);

    //Write the PID constants
    string2write='----PID coefficients';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT KP : signed (n_kp_t-1 downto 0):=""'+Kp_r.s+'"";';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT KI : signed (n_ki_t-1 downto 0):=""'+Ki_r.s+'"";';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT KD : signed (n_kd_t-1 downto 0):=""'+Kd_r.s+'"";';
    r = mputl(string2write, fd_w);
    
    //Write the reference
    string2write='----Reference section';
    r = mputl(string2write, fd_w);
    string2write='CONSTANT reference_t : signed (n_error_t-1 downto 0):=""'+Vref_coded.s+'"";';
    r = mputl(string2write, fd_w);
    
    //finish the file
    r = mputl('end PID_conf;', fd_w);
    
    //close the file
    mclose(fd_w)
    
//end
//return
endfunction 
