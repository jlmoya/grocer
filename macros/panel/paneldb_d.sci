function paneldb_d()
 
// PURPOSE: load a database with 9 countries in TS format
//  and transform if into panel tlist format
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/DataFex.dat')
 
// Countries labels:
// - ze: Eurozone         - jp: japan        - ca: Canada
// - uk: United-Kingdom   - sw: Switserland  - nw: Norway
// - sd: Sweden           - dk: Denemark     - us: United-States
lco = ['ze';'jp';'ca';'uk';'sw';'nw';'sd';'dk';'us'];  // names of countries
 
// Variable labels:
// . xrate: exchange rate against dollar
// . money: narrow money
// . rmmkt: short term interest rate
// . cpic: core cpi
 
// compute core inflation and takes log of exchange rates
for i=1:size(lco,1)
    execstr(lco(i)+'pic = delts(12,log('+lco(i)+'cpic))')
    execstr(lco(i)+'lxrate = log('+lco(i)+'xrate)')
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
 
lvar = ['lxrate';'money_s';'rmmkt_s';'pic_s']; // list of  new variables
 
// build panel database over 1994 - 2002 sample
pdb = paneldb(lco,lvar,'bounds=[''1994m1'' ''2002m12'']');
 
 
 
 
 
endfunction
