//Plot 2 bode plots the continuos and the discrete
function plot_2bode(Gs,title1,Gz,title2,f_max)
    
    frq=logspace(-4,log10(f_max),1000)

respGs=repfreq(Gs,frq);
[magGs,phaseGs]=dbphi(respGs);
respGz=repfreq(Gz,frq);
[magGz,phaseGz]=dbphi(respGz);

     scf()
     subplot(2,1,1)
     plot2d('ln',frq,[magGs.' magGz.'])
     xlabel('Frequency (Hz)')
     ylabel('Mag (dB)')
     
     subplot(2,1,2)
     plot2d('ln',frq,[phaseGs.' phaseGz.'])
     xlabel('Frequency (Hz)')
     ylabel('Phase (deg)')
     legend(title1,title2, "in_lower_right")
endfunction
