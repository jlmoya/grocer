function mpltseries_d()
 
global GROCERDIR
load(GROCERDIR+'\data\bdhenderic.dat')
 
mpltseries('lm1','ly','lp','rnet','window=0','title=[lm1;ly;lp;rnet]','noleg',...
    'main_title=Hendry-Ericsson database','font_title=3','font_main_title=4','font_axis=3',...
    'color=[1,2,5,7]','bounds=[''1968q1'';''1985q4'']') ;
 
write(%io(2),'press any key to continue','(a)');
halt();
load(GROCERDIR+'/data/DataFex.dat');
 
//Countries labels:
// - ze: Eurozone         - jp: japan        - ca: Canada
// - uk: United-Kingdom   - sw: Switserland   - us: United-States
lco = ['ze';'jp';'uk';'us'];  // names of countries
 
// compute core inflation and takes log of exchange rates
for i=1:size(lco,1)
    execstr(lco(i)+'pic = delts(12,log('+lco(i)+'cpic))')
end
tsmat_pi=ts2tsmat('zepic','jppic','ukpic','uspic')
tsmat_r=ts2tsmat('zermmkt','jprmmkt','ukrmmkt','usrmmkt')
 
mpltseries(tsmat_r,tsmat_pi,'order=-1','nseries=2','ncol=2','yaxis=[1,2]','window=1',...
    'main_title=Inflation and monetary policy','title=[Euro area;Japan;UK;US]',...
    'main_legend=[interest rate (3 month, lhs) ;inflation (rhs)]',...
    'font_main_title=4','font_title=3','font_legend=3') ;
 
write(%io(2),'The same graph could have been generated without a tsmat','(a)')
write(%io(2),'You just need to replace the 2 tsmat by the name of the TS','(a)')
 
mpltseries('zermmkt','jprmmkt','ukrmmkt','usrmmkt','zepic','jppic','ukpic','uspic',...
    'order=-1','nseries=2','ncol=2','yaxis=[1,2]','window=1',...
    'main_title=Inflation and monetary policy', 'title=[Euro area;Japan;UK;US]',...
    'main_legend=[interest rate (3 month, lhs) ;inflation (rhs)]',...
    'font_main_title=4','font_title=3','font_legend=3') ;
 
 
endfunction
 
 
