
//Function to analyze an implemented type II regulator with an op-amp
//It allows to put different resitor and verify it is correctly implemented
//It performs too an analysis with the tolerances
//Montecarlo is the number of run for a montecarlo analysis
function [in_circuit,var_analysis]=AnalyzeTypeIIopamp(regulator,implemented,R1,tolR1,R2,tolR2,C1,tolC1,C2,tolC2,fc,montecarlo_run)


//Definition of the Laplace variable
    s=poly(0,'s');

//Verification of the bode plot

num=R2/R1*(1+(s*R2*C1));
den=(s*R2*C1)*(1+s*R2*C2);
in_circuit=syslin('c',num,den);
scf();
bode([regulator;implemented;in_circuit],fc/10e3,fc*10,['ideal','implemented','in circuit']);
//Variation analysis by montecarlo
rand('seed',1); //seed of the random number generator;
montecarlo=[];
test_leg=[];
for(i=1:montecarlo_run)
    //We generate the different R and C
    R1r=R1+tolR1*R1*rand();
    R2r=R2+tolR2*R2*rand();
    C1r=C1+tolC1*C1*rand();
    C2r=C2+tolC2*C2*rand();
    
    num_r=R2r/R1r*(1+(s*R2r*C1r));
    den_r=(s*R2r*C1r)*(1+s*R2r*C2r);
    montecarlo=[montecarlo;syslin('c',num_r,den_r)];
    test_leg=[test_leg,'test '+string(i)]
end
var_analysis=montecarlo;
scf()
bode([in_circuit;montecarlo],fc/10e3,fc*10);

endfunction
