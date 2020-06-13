library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; 
package PID_conf is
----parameters for the size of the ADC
CONSTANT  n_bits_adc : integer :=8;
----parameters for the size of the DPWM
CONSTANT n_bits_pwm_t : integer :=9;
CONSTANT n_reset_pwm_t : integer :=512;
CONSTANT n_delay_PID_t : integer :=146;
CONSTANT n_delay_ADC_t : integer :=1;
----parameters for size of operands, come from PID_reg_scales
CONSTANT n_kp_t : integer:=4;
CONSTANT q_qp_t : integer :=0;
CONSTANT n_ki_t : integer :=6;
CONSTANT q_ki_t : integer :=-9;
CONSTANT n_kd_t : integer :=3;
CONSTANT q_kd_t : integer :=4;
CONSTANT n_up_t : integer :=13;
CONSTANT q_up_t : integer :=0;
CONSTANT n_up_r_t : integer :=22;
CONSTANT n_ud_t : integer :=13;
CONSTANT q_ud_t : integer :=4;
CONSTANT n_ud_r_t : integer :=26;
CONSTANT n_error_t : integer :=9;
CONSTANT n_upd_t : integer :=27;
CONSTANT n_upid_t : integer :=28;
CONSTANT q_upid_t : integer :=-9;
CONSTANT n_wi_t : integer :=15;
CONSTANT n_wi_r_t : integer :=15;
----PID coefficients
CONSTANT KP : signed (n_kp_t-1 downto 0):="0101";
CONSTANT KI : signed (n_ki_t-1 downto 0):="010111";
CONSTANT KD : signed (n_kd_t-1 downto 0):="0100";
----Reference section
CONSTANT reference_t : signed (n_error_t-1 downto 0):="010100100";
end PID_conf;
