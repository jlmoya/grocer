function s_PZtini=ini_eta(eta);
 
//*****************************************************************************//
//** 6. INI_ETA                                                              **//
//*****************************************************************************//
 
i_PZt1=eta(1,1)+eta(2,1);
i_PZt2=eta(3,3)+eta(4,3);
i_PWt1=eta(1,1)+eta(3,1);
i_PWt2=eta(2,2)+eta(4,2);
i_PZtini=[(1-i_PZt2) ; (1-i_PZt1)] .*. ones(1,2)/(2-i_PZt1-i_PZt2);
i_PWtini=[(1-i_PWt2) ; (1-i_PWt1)] .*. ones(1,2)/(2-i_PWt1-i_PWt2);
 
s_PZtini=i_PZtini .*. i_PWtini;
 
endfunction
 
