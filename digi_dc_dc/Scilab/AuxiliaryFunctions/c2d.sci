//Continuous to discrete transformation using the Bilinear transform
function[Gz]=c2d (Gs,Tsample)
    //Gs continous system defined by the transfer fucntion in s
    z=poly(0,'z')
    bt=2/Tsample*(1-z^-1)/(1+z^-1) //definition of the bilinear transform (pag 121)
     Gz=horner(Gs,bt)
     Gz=syslin(Tsample,Gz)
     
endfunction
