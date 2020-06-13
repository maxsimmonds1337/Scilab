//function to plot Zout_cl against ECSS curve
function [mag,flog,mask]=ECSS_zout(Zout_cl,Po,Vo)
    flog=logspace(0,5,10000)
    [flog,response]=repfreq(Zout_cl,flog)
    mag=abs(response)
    zlimit=Vo^2/Po;
    
    mask=ones(flog)*0.002
   
    
    slopeup_start=find(flog>10)
    slopeup_start=min(slopeup_start);
    slopeup_end=find(flog>100)
    slopeup_end=min(slopeup_end);
    
    slopedown_start=find(flog>1e4)
    slopedown_start=min(slopedown_start);
    slopedown_end=length(flog)
    
    mask_up=0.002*flog(slopeup_start:slopeup_end)/10;
    mask_down=(0.02*10000 ./flog(slopedown_start:slopedown_end));
    
    

    mask(slopeup_start:slopeup_end)=mask_up;
    mask(slopedown_start:slopedown_end)=mask_down;
    mask(slopeup_end:slopedown_start)=0.02;
    mask=mask*zlimit;
  
    scf()
    plot2d('ll',[flog.',flog.'],[mag.',mask.'])
    legend(['zo_cl','ECSS Zo mask'],4)

endfunction
