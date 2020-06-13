//Function to retireve the phase and gain margins it complementes natural function p_margin and g_margin
//frq is the margin of frequencies of interest
function [fcross,pmargin,fpi,gmargin]=margins(sys,frq)
    [p_m,fcross]=p_margin(Tz) //Phase margin obtained
//alternative phase margin obtained (in case p_margin fails)
[fr,response]=repfreq(Tz,frq);
[db,phi]=dbphi(response);
[index_cross]=find(db<0);
index_cross=min(index_cross);
fcross_alt=frq(index_cross);
p_m_alt=180+phi(index_cross);
pmargin=min([p_m p_m_alt])
fcross=min([fcross fcross_alt])

//Getting the gain margin
[g_m,fpi]=g_margin(Tz)
//In an alterntive way
[index_pi]=find(phi>-180);
index_pi=max(index_pi);
fpi_alt=frq(index_pi);
g_m_alt=-db(index_pi);
gmargin=min([g_m g_m_alt])
fpi=min([fpi fpi_alt])

endfunction

