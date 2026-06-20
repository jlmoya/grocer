function rbma=bma_d()
 
global GROCERDIR;
 
 // PURPOSE: compute bayesian model averaging on Ehrlich crime data base
 
// load Ehrlich crime data
// LABEL OF THE DATA
// crime = rate of crimes in a particular category per head of population	
// so				=	indicator variable for a southern state	
// m     = percentage of males aged 14–24	
// ed				= mean years of schooling	
// po1   = police expenditure in 1960	
// po2   = police expenditure in 1959	
// lf    = labour force participation rate		
// mf    = number of males per 1000 females	
// pop   = state population	
// nw    = number of nonwhites per 1000 people	
// u1    = unemployment rate of urban males 14–24	
// u2    = unemployment rate of urban males 35–39	
// gdp   = gross domestic product per head	
// ineq  = income inequality	
// prob  = probability of imprisonment	
// time  = average time served in state prisons
load(GROCERDIR+'/data/crime.dat')
 
// take log of data
listn = ['crime';'m';'ed';'po1';'po2';'lf';'mf';'pop';'nw';'u1';'u2';'gdp';'ineq';'prob';'time'] ;
for i =1:size(listn,1)
	execstr('l'+listn(i)+' = log('+listn(i)+')')
end
 
// BMA estimation
rbma = bma_g('lcrime',30000,'lm','so','led','lpo1','lpo2','llf','lmf','lpop','lnw','lu1','lu2',...
'lgdp','lineq','lprob','ltime','burnin=10000','mcmc=''mc3''');
 
 
 
endfunction
