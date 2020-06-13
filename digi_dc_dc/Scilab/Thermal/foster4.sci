//Function of 4 order Foster Network
//The coefficient vector will be of the form [R1 C1 R2 C2 R3 C3 R4 C4]
function [y]=foster4(x,c)
    //we extract the coefficients
    R1=c(1);
    C1=c(2);
    R2=c(3);
    C2=c(4);
    R3=c(5);
    C3=c(6);
    R4=c(7);
    C4=c(8);
    
    tau1=R1*C1;
    tau2=R2*C2;
    tau3=R3*C3;
    tau4=R4*C4;
    
    //calculate the function
    y=R1*(1-exp(-x/tau1))+R2*(1-exp(-x/tau2))+...
    R3*(1-exp(-x/tau3))+R4*(1-exp(-x/tau4));
end

