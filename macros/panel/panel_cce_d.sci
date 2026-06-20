function panel_cce_d()
 
// PURPOSE: load a database with 9 countries in TS format
//  and transform if into panel tlist format
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/DataFex.dat')
 
// Countries labels:
// - ze: Eurozone         - jp: japan        - ca: Canada
// - uk: United-Kingdom   - sw: Switserland  - nw: Norway
// - sd: Sweden           - dk: Denemark     - us: United-States
lco = ['ze';'jp';'ca';'uk';'sw';'nw';'sd';'dk'];  // names of countries
 
// Variable labels:
// . xrate: exchange rate against dollar
// . money: narrow money
// . rmmkt: short term interest rate
// . cpic: core cpi
 
// compute core inflation and takes log of exchange rates
uspic = delts(12,uscpic);
for i=1:size(lco,1)
    execstr(lco(i)+'pic = delts(12,log('+lco(i)+'cpic))')
    execstr(lco(i)+'dlxrate =delts(log('+lco(i)+'xrate))')
    execstr(lco(i)+'dlxrate1 =delts(lagts(log('+lco(i)+'xrate)))')
end
 
lvar = ['money';'rmmkt';'pic']; // list of name of variable
// spread of mooney, inflation & interest rates against US
for n=1:size(lco,1)
  for l = 1:size(lvar,1)
    if lvar(l) == 'money' then
      execstr(lco(n)+lvar(l)+'_s = log('+lco(n)+lvar(l)+'/us'+lvar(l)+')') ;
    elseif lvar(l) == 'pic' | lvar(l) == 'rmmkt' then
      execstr(lco(n)+lvar(l)+'_s = '+lco(n)+lvar(l)+'-us'+lvar(l)) ;
    end
  end
end


// take the first difference of the exchange rate 
 
lvar = ['dlxrate';'dlxrate1';'money_s';'rmmkt_s';'pic_s']; // list of  new variables
 
// build panel database over 1994 - 2002 sample
pdb=paneldb(lco,lvar,'bounds=[''1994m1'';''2002m12'']');


// option 'x=' is used : estimation is done on a subset of the variables
//   available in the panel tlist  
//  test of cross-sectional dependence 
cdtest('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','lm_homo'); // LM adjusted test test on homogeneous panel
cdtest('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','lm_hetero'); // LM adjusted test test on heterogeneous panel
cdtest('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','cd_hetero'); // Pesaran (2004) test on heterogeneous panel

// mean group estimator
rp1=pcce('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','cce=meang');

// pooled estimator
rp2=pcce('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','cce=pooled'); 
 
// with an AR part 
rp3=pcce('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','yar=dlxrate1','cce=meang');  

// with an AR part and 12 lags for the cross-sectionnal means 
// of the regressors (to "whiten" residuals)
rp4=pcce('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','yar=dlxrate1','cce=meang','mglag=4');  

// with an AR part, 12 lags for the cross-sectionnal means of the 
//  regressors and an half-panel jackknife correction
rp5=pcce('dlxrate',pdb,'x=[money_s;rmmkt_s;pic_s]','yar=dlxrate1','cce=meang','mglag=4','jackkn');  


 
 
endfunction
