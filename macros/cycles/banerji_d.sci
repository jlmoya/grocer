function rba=banerji_d()
 
global GROCERDIR;
 
// test the leading profile of belgium business climate
// over french one since the 90's
 
load(GROCERDIR+'/data/BusinessClimate.dat');
 
// performs bry-boschan turning points dating procedure
bounds('1990m1','2005m5')
rbe = brybos('clim_be','proc=''bb''');	
rfr =brybos('clim_fr','proc=''bb''');	
bounds()
 
// French business climate is the reference serie
Pr = rfr('P') ;
Tr = rfr('T') ;
Pt = rbe('P') ;
Tt = rbe('T') ;
 
// banerji with 4 month lead
rba =banerji(Pr,Tr,Pt,Tt,'lead=4');
 
endfunction
