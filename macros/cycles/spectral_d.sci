function spectral_d()
 
global GROCERDIR;
 
// performes spectral analysis of QoQ growth rate
// of French (fr), German (ger), Italian (it) and Spanish (spa) PPP GDP
 
 
load(GROCERDIR+'\data\specgdp.dat');
 
// get the name of variable avaible in the database
lvar =dblist(GROCERDIR+'\data\specgdp.dat');
 
// transforms by log and first difference
for i = 1:size(lvar,1)
	execstr('dl'+lvar(i)+' = delts(log('+lvar(i)+'))')
end
 
 
wger = 0.33 ; // germany weight in euro zone GDP
wfr = 0.24  ; // same for France, Italy and spain
wit = 0.16;			
wsp = 0.11;
wt = wfr+wger+wit+wsp ;
 
bounds()
// estimates and prints spectral density of each gdp with a truncation window of 6
rspec = spectral('dlger','dlfr','dlit','dlsp','trunc=6','spec=1','cospe=1');
write(%io(2),'Press a key to continue','(a)')	;
halt();
 
bounds('1970q1','2003q3');								
rspec = spectral('dlger','dlfr','dlit','trunc=12',...
'dcorr=1','coher=1','cohes=1','boot=1','B=200','sb=8');
endfunction
