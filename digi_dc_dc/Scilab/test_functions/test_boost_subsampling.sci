

//Test the functions for  the Buck

//REactive elements and switching frequency
L=1e-6;
rl=5e-3;
rc=10e-3; //Parasitic element values are needed, but not very important
C=200e-6;

f_switch=1e6;
tctrl=400*1e-9;

Po=9;
Vo=9;
Io=Po/Vo; //The model requires the output current
Rl=Vo/Io;

Vin=1.8; //Input voltage range

// Worst case in terms of delay will be having the minimum voltage, the longest
//Duty

D=(Vo-Vin)/Vo;

n_sub=[1 2 3 4];
magGvuz=[];
phaseGvuz=[];

magGiuz=[];
phaseGiuz=[];
legenda=[];



//New function

for(i=1:length(n_sub))
[Gvuz_new,Gvus_new,Giuz_new,Gius_new]=Boost_ss_model_2f(L,rl,C,rc,max(Vin),D,Vo,0*Io,Rl,tctrl,f_switch,n_sub(i),3);


end
