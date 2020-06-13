
// function for extracting the discrete model from the State  mateixes A1,0 b1,0 c1,0 and input vector of a converters
//It will propagate the Matrixes through the pulses of a trailing edge PWM and devolve the transfer functions discrete and continous
//Taken from "Digital control of high frequency PWM converters" p.14
// It will assume a leading edge modulator
//This function is assuming that the sampling and the control action takes place each n_sub samples subsampling=n_sub


function [Gvuz,Gvus,Giuz,Gius]=leadingPWM(A1,A0,b1,b0,c1,c0,V,D,tctrl,Fs,n_sub,mod)

    //Outputs are the discrete Model Wz and the continous model Ws
    // steady state duty cycle D
    //, delay between sample and latch of the duty cyce tcntrl and switching frquency Fs
    //Mod indicates the transfer function to plot 1 for control to output voltage, 2 control to current voltage and 3 both

    //Transformation of Parameters


    Ts=1/Fs;

    Dprime=1-D;
    td=tctrl+Dprime*Ts; //Luca defines the delay time sampling in S1 and propagating until the raisng edge


    //Continous case
    //Steady state operating point - continous
    X=-((D*A1+Dprime*A0)^-1)*(D*b1+Dprime*b0)*V;

    //Dynamic model continous
    A=D*A1+Dprime*A0;
    F=(A1-A0)*X+(b1-b0)*V;
    c=D*c1+Dprime*c0;


   // Definition of the continous system
   sys=syslin('c',A,F,c(2,:))
   Gvus=ss2tf(sys); //Lets call it vu u control input as the book
   sys=syslin('c',A,F,c(1,:))
   Gius=ss2tf(sys);

    //Definition of the discrete system page 93
    A1i=A1^-1;
    A0i=A0^-1;
    Xdowna=(eye(A1)-expm(A1*D*Ts)*expm(A0*Dprime*Ts))^-1;
    Xdownb=(-expm(A1*D*Ts)*A0i*(eye(A0) -expm(A0*Dprime*Ts)))*b0; //eye(A0) is an identity matrix with the same size
    Xdownc=-A1i*(eye(A1)-expm(A1*D*Ts))*b1;
    Xdown=Xdowna*(Xdownb+Xdownc)*V; //States at the falling edge of the steady state duty

    //States at the leading edge derived from the falling edge (pag 89)
    //Luca's book

    Xup=expm(A0*Dprime*Ts)*Xdown-A0i*(eye(A0)-expm(A0*Dprime*Ts))*b0*V;

    Phi=expm(A1*(td-Dprime*Ts))*(expm(A0*(Dprime*Ts))*expm(A1*(D*Ts)))^(n_sub-1)*expm(A0*(Dprime*Ts))*expm(A1*(Ts-td)); //Evolution of the states in n_sub swiching cycle


    gam_n=-1*((A0-A1)*Xup + (b0-b1)*V)*Ts; // Influece of the input at the last up transition instant

    gam_delay=zeros(gam_n); //initially the zero same size of gam_n

    for i=0:n_sub-1
    new_gam_delay=(expm(A1*D*Ts)*expm(A0*Dprime*Ts))^(i)*expm(A1*(Ts-td))*gam_n //  The influence of the input is propagated n_sub times
    gam_delay=gam_delay+new_gam_delay;
    end

    gam=gam_delay;

    delta=c1; //observation matrix sample taken in state 1 with switch closed


    //Definition of the discrete state space model
     sysz=syslin(n_sub*Ts,Phi,gam,delta(2,:)); //in Scilabs this is called Sampled
     Gvuz=ss2tf(sysz)// control to output voltage response
    sysz=syslin(n_sub*Ts,Phi,gam,delta(1,:)); //in Scilabs this is called Sampled
     Giuz=ss2tf(sysz)// control to inductor current response

     //Representations of the frequency responses
     frq=1e0:1:Fs/(2*n_sub); //To avoid the Nyquist Frequency
        if(or([mod==1,mod==3])) then
           scf();
           subplot(1,2,1);
           bode(Gvuz,frq,'Gvd Discrete');
           subplot(1,2,2);
           bode(Gvus,frq,'Gvd Continous');
        end
        if(or([mod==2,mod==3])) then
           scf();
           subplot(1,2,1);
           bode(Giuz,frq,'Gid Discrete');
           subplot(1,2,2);
           bode(Gius,frq,'Gid Continous');
        end


end
