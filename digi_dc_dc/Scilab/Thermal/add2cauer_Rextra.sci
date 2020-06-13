//Function that takes a Foster like impedance awith 4 elements and transforms 
//it in a Cauer network taken from Temes book, Manus thesis and "
//Combination of Thermal Subsystems Modeled by Rapid Circuit Transformation"
//Zinter are the impedance of the individual elements of the Cauer network
//Rextra represents the thermal impedance to the point that the temepreature is controlled.
function [Zcauer]=add2cauer_Rextra(Zinter,Rextra)
    s=poly(0,'s'); //Laplace variable
    my_inf=1e40; //Big value to eval the functions
 /*   //Extract the polynoms
    num_zth=Zth(2);
    den_zth=Zth(3);
   //The result will be stored here
   Zinter=[];
   rem=Zth; //define the variable
   while(rem<>0)
      
       [new_el,rem]=remainder(rem,s,my_inf);//extrac it
       Zinter=[Zinter,new_el]
       
   end*/
   //Verify it the two last elements are of the same kind
   //This can happen if the remainder is vey small but bigger than eps so it pass clean
   
   //get the number of elements
   [m,n]=size(Zinter);
   num_Zinter=Zinter(2);
   den_Zinter=Zinter(3);
   if(num_Zinter($)<>1) then
   Yend=den_Zinter($-1)+1/(num_Zinter($)+Rextra);//This is the final impedance is a resistor we should add the extra
    else
    Zend=num_Zinter($-1)+Rextra+1/(den_Zinter($)); //The final impedance is a cap
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
