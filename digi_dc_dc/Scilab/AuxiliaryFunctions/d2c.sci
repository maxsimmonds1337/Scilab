//Discrete to continouopus transformation using the Bilinear transform
function[Gs]=d2c (Gz,Tsample)
    //Gz continous system defined by the transfer fucntion in s
    s=poly(0,'s')
    k=2/Tsample;
    bt=-(s/k+1)/(s/k-1) //definition of the bilinear transform derived (pag 121)
     Gs=horner(Gz,bt)
     Gs=syslin('c',Gs)
     
endfunction
