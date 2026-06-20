function gmmLin_d()
 
// PURPOSE: demo program for GMM estimation of a linear model
//    and performs tests of coefficient restrictions
 
 
 
write(%io(2),'Demo program for GMM estimation of a  linear model','(a)')
write(%io(2),'The model is y = X*b with b=[0;1;-1]','(a)')
write(%io(2),'We will generate some data, estimate by OLS (using White SE), then','(a)')
write(%io(2),'estimate by GMM and compare.','(a)')
 
lines(0);
X = [ones(1000,1) grand(1000,1,'nor',0,1) grand(1000,1,'nor',0,1)];
b = [0;1;-1];
e = grand(1000,1,'nor',0,1);
y = X*b + e;
 
olsout=hwhite(y,X);
 
write(%io(2),' Now we define a tlist variable to tell GMM what to do.','(a)')
gmmopt = tlist(['gmm';'momt';'jake';'prt';'gmmit';'S']);
gmmopt('prt')=1;
gmmopt('gmmit') = 1;
gmmopt('S')='W';
gmmopt('momt')='gmmLinM';
gmmopt('jake')='gmmLinJ';
 
write(%io(2),'gmmopt is','(a)');
write(%io(2),'','(a)');
disp(gmmopt);
 
write(%io(2),'We need some starting values b0=zeros(3,1)','(a)');
b0=zeros(3,1);
//halt();write(%io(2),'Strike a key to continue','(a)');
 
uout=gmm('y',gmmopt,'exo=''X''','ivar=''X''','parm0=b0');
 
halt();write(%io(2),'Strike a key to continue','(a)');
write(%io(2),'We will know perform some tests of parameter restriction','(a)');
write(%io(2),'  we want to test if b3=0','(a)');
write(%io(2),'','(a)');
br=[0;0];
bu = [0;0;0];
gmmopt('prt')=0;
 
write(%io(2),'We will start with the D-test','(a)');
write(%io(2),'We estimate the constrained model on the prior W','(a)');
write(%io(2),'W0 = uout(''W'');  gmmopt(''W0'') = ''Win'';','(a)');
write(%io(2),'rout=gmm(''y'',gmmopt,''exo=''X(:,2:3)'''',''ivar=''''X'''',''Win=W0'',''parm0=[0;0]'');','(a)');
write(%io(2),'then we perfom the test: ','(a)');
write(%io(2),'rd = gmmDtest(uout,rout,1)','(a)');
write(%io(2),'','(a)');
W0 = uout('W');
gmmopt(1)($+1) = 'W0';
gmmopt('W0') = 'Win';
rout=gmm('y',gmmopt,'exo=''X(:,2:3)''','ivar=''X''','parm0=br','Win=W0','noprint');
rd = gmmDtest(uout,rout,1);
 
halt();write(%io(2),'Strike A Key to Continue','(a)');
write(%io(2),'Wald test using unconstrained estimates','(a)')
write(%io(2),'R = [1 0 0]; r = 0;','(a)');
write(%io(2),'rw=gmmWald(uout,R,r);','(a)');
write(%io(2),'','(a)');
R = [1 0 0];
r = 0;
rw=gmmWald(uout,R,r);
 
write(%io(2),'check if the non-linear Wald gives the same results','(a)')
write(%io(2),'the constraint is written R=[''p1''] with p1 the first parameter','(a)');
write(%io(2),'','(a)');
R = 'p1';
rw=gmmNlWald(uout,R);
 
halt();write(%io(2),'Strike A Key to Continue','(a)');
write(%io(2),'LM test using the unconstrained objective function at the constrained estimate','(a)');
write(%io(2),'','(a)');
gmmopt('W0')='Z';
rout=gmm('y',gmmopt,'exo=''X(:,2:3)''','ivar=''X''','parm0=br','noprint');
rlm = gmmLM(uout,rout,[0,1,1],1);
 
 
endfunction
