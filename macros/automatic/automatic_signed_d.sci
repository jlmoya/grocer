function automatic_signed_d()
    
load(GROCERDIR+'\data\conjfra.dat')
 
bounds('1991q3','2008q2','2009q3','2011q2')
tests='test=predfailin(0.9),doornhans,arlm(4),hetero_sq'
listx=['serv_paou_m1','serv_paou_m1-lagts(serv_paou_m1)','serv_exou_m1-serv_paou_m1','serv_exou_m1-lagts(serv_exou_m1)',...
'man_paou_m1','man_paou_m1-lagts(man_paou_m3)','man_exou_m1-lagts(man_paou_m3)','man_exou_m1-lagts(man_exou_m3)',...
'bat_paou_m1','bat_paou_m1-lagts(bat_paou_m3)','bat_exou_m1-lagts(bat_paou_m3)','bat_exou_m1-lagts(bat_exou_m3)',...
'ret_paou_m1','ret_paou_m1-lagts(ret_paou_m1)','ret_glor_m1-lagts(ret_paou_m3)','ret_glor_m1-lagts(ret_glor_m3)',...
'france_climcr_m1','france_climcr_m1-lagts(france_climcr_m3)']

signx=ones(size(listx,2),1)
[r1,rf1]=automatic_signed('growthr(fra_gdp)',listx,signx,'comp=const','strategy=liberal',tests)

endfunction
