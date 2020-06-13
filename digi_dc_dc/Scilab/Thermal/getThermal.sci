//Function to retrieve the Cauer thermal impedance model from the step response 
//in the mosfet datasheet
function [Zcauer,Zinter]=getThermal(data)
    //Now in a single function
[copt]=fitfoster4(data)

//We get the model in S
Zth=foster4_s(copt);

//We transform the model to Cauer
[Zcauer,Zinter]=foster2cauer(Zth)

//verify time in linear
time_lin=linspace(0,10e-3,1000);
Zrespose=foster4(time_lin,copt); //Evaluation of the function
step_res=csim('step',time_lin,Zth);
step_res_cauer=csim('step',time_lin,Zcauer);
scf(2)
plot(time_lin,Zrespose,time_lin,step_res,time_lin,step_res_cauer);
legend('Function','Linear Model Foster','Linear Model Cauer','in_upper_left')


//Comparison with the data
time_test=logspace(log10(data(1,1)),log10(data(1,$)))
step_res2=csim('step',time_test,Zth);
step_res_cauer2=csim('step',time_test,Zcauer);
scf(4)
plot2d('ln',time_test,step_res2,2);
plot2d('ln',time_test,step_res_cauer2,3);
plot2d('ln',data(1,:),data(2,:),-1);
legend('Foster','Cauer','Data','in_upper_left')
endfunction
