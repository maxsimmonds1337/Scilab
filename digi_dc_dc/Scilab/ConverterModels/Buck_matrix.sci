// function for extracting the discrete model for a Buck converter
//Taken from "Digital control of high frequency PWM converters" p.14
// It will generate the Matrixes

function [A1,A0,b1,b0,c1,c0,V]=Buck_matrix(L,rl,C,rc,Vg,D,Vload,Iload,Rload)
    //Outputs are the matrixes and the input vector
    //iput parameters are inductance L, inductance parasisitc resistor rl, capacitor C, resistance in capacitor rC, input voltage Vg,
    //Voltage on load Vload, current Iload, load Resistance Rload,



    //Definition of state Matrixes taken from insert 3.4

    //Input vector
    V=[Vg;Iload;Vload];

    rpar=rc/(1+rc/Rload); //Combination of the ESR of cap and Rload

    //States with closed Switch
    A1=[-1/L*(rpar+rl) -1/L*1/(1+rc/Rload); 1/C*1/(1+rc/Rload) -1/C*1/(Rload+rc)];
    b1=[1/L rpar/L -1/L*1/(1+rc/Rload); 0 -1/C*1/(1+rc/Rload) 1/C*1/(Rload+rc)];
    c1=[1 0; rpar 1/(1+rc/Rload)];

    //States with open switch (in the buck they do not change excpet b wich neglects the Vg input influence)
    A0=A1;
    c0=c1;
    b0=[0 rpar/L -1/L*1/(1+rc/Rload); 0 -1/C*1/(1+rc/Rload) 1/C*1/(Rload+rc)];

  endfunction
