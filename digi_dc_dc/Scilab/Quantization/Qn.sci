//Function to round a quantity According to pag.295
function [xq,dx,cod]=Qn(x,n)
    //x quantity to round,
    //n number of bits,outputs are xk the x quantized and codified and dx the error
    //cod is a structure where everything is stored
    //cod.w is the significand
    //cod.q is the scale
    //cod.n is the number of bits
    //cod.s is the digital word

    if (x==0) then
        x1=x;
        xq=0;
        q=1;
        wd=0;
        s=['0'+dec2bin(wd,n-1)]; //
    else

            x1=x;
            neg=x<0; //check if signal is negative
            x=abs(x);
           
            E=floor(log2(x)); //close representation in base 2 as an integer power
            F=2^(log2(x)-E); //Part that it is not can be reprsented as a power of 2
            q=E-(n-2);//q is the scale, the lowest power of 2 necessary to represent the quantity
            //Equation B.10 explains why starts in n-2 the binaray weight of upper bit without the sign 
            wd=round(F*2^(n-2));// significand
            if(wd==1 & (n-3>0))// not really sure but this fixes the problem with the powers of 2
             wd=round(F*2^(n-3));
            q=q+1;
            end;

        if(neg)
            xq=-wd*2^q
            s=['1'+dec2bin(-wd+2^(n-1),n-1)] // In b2c negatives numbers are expresed by adding one
            wd=-wd;
        else
            xq=wd*2^q
            s=['0'+dec2bin(wd,n-1)] //
            wd=wd;
        end;
    end
    //error
    dx=xq-x1;
    //output of the data
    cod.xq=xq;
    cod.w=wd;
    cod.q=q;
    cod.n=n;
    cod.s=s;
    cod.dx=dx;
    return
endfunction
