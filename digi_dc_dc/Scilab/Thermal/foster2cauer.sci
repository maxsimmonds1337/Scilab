//Function that takes a Foster like impedance awith 4 elements and transforms 
//it in a Cauer network taken from Temes book, Manus thesis and "
//Combination of Thermal Subsystems Modeled by Rapid Circuit Transformation"
//Zinter are the impedance of the individual elements of the Cauer network
//
function [Zcauer,Zinter]=foster2cauer(Zth)
    s=poly(0,'s'); //Laplace variable
    my_inf=1e40; //Big value to eval the functions
    //Extract the polynoms
    num_zth=Zth(2);
    den_zth=Zth(3);
   //The result will be stored here
   Zinter=[];
   rem=Zth; //define the variable
   while(rem<>0)
      
       [new_el,rem]=remainder(rem,s,my_inf);//extrac it
       Zinter=[Zinter,new_el]
       
   end
   //Verify it the two last elements are of the same kind
   //This can happen if the remainder is vey small but bigger than eps so it pass clean
   
   //get the number of elements
   [m,n]=size(Zinter);
   num_Zinter=Zinter(2);
   den_Zinter=Zinter(3);
   if(num_Zinter($)<>1) then
   Yend=den_Zinter($-1)+1/num_Zinter($);//This is the final impedance
    else
    Zend=num_Zinter($-1)+1/(den_Zinter($));
    Yend=1/Zend;
    end
   Ynew=Yend;//In the first step this is the final

   for(i=n-2:-1:1)//We follow the vector from end to start
    if (num_Zinter(i)<>1) then //this one ends in resistor
    Ynew=1/(num_Zinter(i)+1/Ynew);
    else //This one ends in capacitor
    Ynew=den_Zinter(i)+Ynew;
    end //if
   end//for
    Zcauer=1/Ynew;
    //We put it into linear system
    Zcauer=syslin('c',Zcauer)
endfunction

//Function that gets an impedance and if num is the same order than denominator 
//it returns a resistor if num has smaller order than denominator it gives a capacitor
function [element_z,rem]=remainder(Z,s,infinity)
if(typeof(Z)=='rational') //Check if Z is a ratio of polinoms
    num_z=Z(2);
    den_z=Z(3);
    deg_num=degree(num_z);
    deg_den=degree(den_z);
    if((deg_num==deg_den)) then //If this happens they have the same order and it can be approximated by a resistor
        element_z=horner(Z,infinity)
        rem=clean(Z-element_z)//elliminate small terms
        if((degree(rem(2))==0)&&(degree(rem(3)))==0) then //If the degree of the remainder is 0 I put it on the final resistor
            rem=0;
            element_z=element_z+horner(rem,infinity);
        end
        
     
    elseif(deg_num<deg_den) // If this happens the network can be approximated by cap
        Y=Z^-1;
        cap=horner(Y/s,infinity);
        Ycap=cap*s;
        Yrem=Y-Ycap;//The remainder in admitance form
            if(Yrem<>0)
            rem=clean(1/Yrem); //return in impedance form elliminate small terms
            else
            rem=0;//If num is 0 I return 0
            end
        element_z=1/Ycap;
    else
        return; //If not there is a problem
     end
else
    element_z=0;
    rem=0;
    return;
end
    
    
    
       
endfunction
