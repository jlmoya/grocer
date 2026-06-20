function dfbeta_d()
 
// PURPOSE: demo of dfbeta(), plt_dfb()
//         influential observations diagnostics
//          from Belsley, Kuh and Welsch (1980)
//          REGRESSION DIAGNOSTICS
//---------------------------------------------------
// USAGE: dbeta_d
//---------------------------------------------------
 
// generate data set
//n = 100;
//k = 6;
 
 
exo = grand(100,6,'nor',0,1);
exo(:,1) = ones(100,1);
exo(:,3) = exo(:,2) + grand(100,1,'nor',0,1)*0.05;
 
bet = ones(6,1);
 
endo = exo*bet + grand(100,1,'nor',0,1);
 
// now add a few outliers
endo(50,1) = 10.0;
endo(70,1) = -10.0;
 
result = dfbeta('endo','exo');
 
endfunction
