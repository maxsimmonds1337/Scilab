//Function that fits the thermal impedance response of 4 order Foster Network
//The data will be a table with tow rows first row is time second temperature
function [c]=fitfoster4(data)
    //we extract the coefficients
//Initial values
c0=[1;1;1;1;1;1;1;1];
[copt, err] = datafit(myerror, data, c0);

//We extract the time to work with it
time=data(1,:);
Zdata=data(2,:);
//Check that the thing is OK
time_test=logspace(log10(time(1)),log10(time($)))
Zfitted=foster4(time_test,copt);
scf(1)
plot2d('ln',time_test,Zfitted,2);
plot2d('ln',time,Zdata,-1);
legend('Fitted','Data','in_upper_left')
c=copt;//return the data
endfunction

//Error function as defined by the datafit example
function e = myerror(c, z)
  x = z(1); y = z(2);
  e = y - foster4(x, c);
endfunction 
