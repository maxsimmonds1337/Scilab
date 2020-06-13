//Plot 2 bode plots the continuos and the discrete
function plot_3bode(fon1,title1,fon2,title2,fon3,title3,f_max)
    
    frq=logspace(-4,log10(f_max),1000)

respGs=repfreq(fon1,frq);
[magGs,phaseGs]=dbphi(respGs);
respGzPI=repfreq(fon2,frq);
[magGzPI,phaseGzPI]=dbphi(respGzPI);
respGzPD=repfreq(fon3,frq);
[magGzPD,phaseGzPD]=dbphi(respGzPD);

     scf()
     subplot(2,1,1)
     plot2d('ll',frq,[magGs.' magGzPI.' magGzPD.'])
     xlabel('Frequency (Hz)')
     ylabel('Mag (dB)')
     
     subplot(2,1,2)
     plot2d('ln',frq,[phaseGs.' phaseGzPI.' phaseGzPD.'])
     xlabel('Frequency (Hz)')
     ylabel('Phase (deg)')
     legend(title1,title2,title3, "in_lower_right")
endfunction
