 //Script for thermal model from Manus Thesis and Thermal Modeling of Power electronic Systems

//Load the data is based on Manus thesis
load('thermal.sav')

//According to Thermal Modeling of Power electronic Systems
//The thermal impedance is a step response

//Datafit example
//http://www.matrixlab-examples.com/curve-fit.html
/*
//Initial values
c0=[1;1;1;1;1;1;1;1];
[copt, err] = datafit(myerror, data2, c0);

//Check that the thing is OK
time_test=logspace(log10(time(1)),log10(time($)))
Zfitted=foster4(time_test,copt);
scf(1)
plot2d('ln',time_test,Zfitted,2);
plot2d('ln',time,Zdata,-1);
legend('Fitted','Data','in_upper_left')
*/
//Now in a single function
[copt]=fitfoster4(data2)

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
scf(3)
bode([Zth;Zcauer],1e-2,1e4)
legend('Thermal Impedance Foster','Thermal Impedance Cauer','in_lower_left')


//Comparison with the data
time_test=logspace(log10(data2(1,1)),log10(data2(1,$)))
step_res2=csim('step',time_test,Zth);
step_res_cauer2=csim('step',time_test,Zcauer);
scf(4)
plot2d('ln',time_test,step_res2,2);
plot2d('ln',time_test,step_res_cauer2,3);
plot2d('ln',data2(1,:),data2(2,:),-1);
legend('Foster','Cauer','Data','in_upper_left')
