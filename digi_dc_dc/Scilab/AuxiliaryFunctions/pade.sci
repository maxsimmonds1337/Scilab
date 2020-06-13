//Funtio to generate the transfer fucntion of a delay by a pade approxiamtion. 
//Tehory is described in 3rd TEMPUS-INTCOM Symposium, September 9-14, 2000, Veszprém, Hungary. 1
//SOME REMARKS ON PADÉ-APPROXIMATIONS
//M.Vajta
function [delay_s]=pade(delay,s)
//Uses a R3,4 approx
num=840-360*s*delay+60*(s*delay)^2-(s*delay)^3;
den=840+480*s*delay+120*(s*delay)^2+16*(s*delay)^3+(s*delay)^4;

delay_s=syslin('c',num,den);

endfunction
