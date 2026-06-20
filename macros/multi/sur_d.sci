function [r]=sur_d();
 
// PURPOSE: An example using sur(),
//
// seemingly unrelated regression estimation
// with and without iteration on the error var-cov matrix
//---------------------------------------------------
// USAGE: sur_d
//---------------------------------------------------
 
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/grun.dat')
// grunfeld investment data
// see page 650, Green 1997
 
ige  = grun(:,1); // general electric
fge = grun(:,2);
cge = grun(:,3);
 
iwest  = grun(:,4); // westinghouse
fwest = grun(:,5);
cwest = grun(:,6);
 
igm  = grun(:,7); // general motors
fgm = grun(:,8);
cgm = grun(:,9);
 
ich  = grun(:,10); // chrysler
fch = grun(:,11);
cch = grun(:,12);
 
iuss  = grun(:,13); // us steel
fuss = grun(:,14);
cuss = grun(:,15);
 
// (order follows that in Green, 1997)
 
eq1='igm=a1*fgm+a2*cgm+a3'
eq2='ich=a4*fch+a5*cch+a6'
eq3='ige=a7*fge+a8*cge+a9'
eq4='iwest=a10*fwest+a11*cwest+a12'
eq5='iuss=a13*fuss+a14*cuss+a15'
 
bounds()
r=sur(eq1,eq2,eq3,eq4,eq5)
 
write(%io(2),'if you want to see an example with unequal numbers of observations, type a key','(a)')
write(%io(2),'else, click on abort in the menu','(a)')
halt()
 
load(GROCERDIR+'/data/suruneq_d.dat')
 
bounds('1a','32a')
rsur=sur('vkbus=a1*pob+a2*pibloc+a3*bus','vkpar=a4*pob+a5*pibloc+a6*par',...
'vktax=a7*pob+a8*pibloc+a9*tax','vkcam=a10*pob+a11*pibloc+a12*cam',...
'vkcom=a13*pob+a14*pibloc+a15*com','vkmot=a16*pob+a17*pibloc+a18*mot','unequal')
 
endfunction
