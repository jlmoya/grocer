function johansen_d()
 
global GROCERDIR;
bounds()
 
load(GROCERDIR+'\data\juselius.dat')
 
write(%io(2),'************','(a)')
write(%io(2),'fig 3.3 p.41','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
pltseries('dnk_Lm3n-dnk_Lpy','window=1')
pltseries('dnk_Lyr','window=2')
pltseries('dnk_Rb','window=3')
pltseries('dnk_Rm','window=4')
pltseries('dnk_DLpy','window=5')
 
q1=seasdummy(['1973q1';'2003q1'],1)-0.25
q2=seasdummy(['1973q1';'2003q1'],2)-0.25
q3=seasdummy(['1973q1';'2003q1'],3)-0.25
 
 
write(%io(2),'************','(a)')
write(%io(2),'Table 4.1 p.60','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
VAR(2,'endo=dnk_Lm3n-dnk_Lpy;dnk_Lyr;dnk_DLpy;dnk_Rm;dnk_Rb','exo=q1;q2;q3')
 
// create dummies used for regression p.111-112
post83q1=dummy(['1973q1';'2003q1'],['1983q1';'2003q1']);
dum75q4=dummy(['1973q1';'2003q1'],'1975q4')-0.5*dummy(['1973q1';'2003q1'],['1976q1';'1976q2']);
dum76q4=dummy(['1973q1';'2003q1'],'1976q4');
dum83q2=dummy(['1973q1';'2003q1'],'1983q2');
dum83q1=dummy(['1973q1';'2003q1'],'1983q1');
 
write(%io(2),'************','(a)')
write(%io(2),'fig 6.3 p.109','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
pltseries('dnk_Lm3n-dnk_Lpy','dnk_Lm3rC')
 
write(%io(2),'************','(a)')
write(%io(2),'table 6.3 p.112','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
VAR(1,'endo=delts(dnk_Lm3rC);delts(dnk_Lyr);delts(dnk_DLpy);delts(dnk_Rm);delts(dnk_Rb)',...
'exo=lagts(dnk_Lm3rC);lagts(dnk_Lyr);lagts(dnk_DLpy);lagts(dnk_Rm);lagts(dnk_Rb);lagts(post83q1);trend^1;dum75q4;dum76q4;dum83q1;dum83q2')
 
write(%io(2),'************','(a)')
write(%io(2),'table 8.1 p. 144','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rj1=johansen(1,'dnk_Lm3rC','dnk_Lyr','dnk_DLpy','dnk_Rm','dnk_Rb',...
'exo_lt=trend^1;post(1983q1)','exo_st=const;dum75q4;dum76q4;dum83q1')
 
// display the cointegration vectors
prtjohvec(rj1,5)
 
write(%io(2),'************','(a)')
write(%io(2),'normalize cointegration vectors as done in table 7.1 p. 123','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rj1b=johansen_normalize(rj1,[3,1,4,2,5])
 
write(%io(2),'************','(a)')
write(%io(2),'test not in the book: tests of the inclusion of the trend in the','(a)')
write(%io(2),'cointegration vectors','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
r_test_exolt=johansen_test_exo_lt(rj1,2,'trend')
 
write(%io(2),'************','(a)')
write(%io(2),' tests p.181','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
// caution: the order of the trend and the dummy are not the same
// H1
write(%io(2),'hypothesis H1','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
H1=zeros(7,6);
for i=1:5
   H1(i,i)=1;
end
H1(7,6)=1
rjtest1=johansen_common_beta(rj1,3,H1)
// normalize the cointegrating vectors as in Juselius
rjtest1n=johansen_normalize(rjtest1,[3;1;4])
// print the -now normalized- first 3 cintegrating vectors
// prtjohvec(rjtest1n,3)
 
// H2
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H2','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
H2=zeros(7,6)
for i=1:6
   H2(i,i)=1
end
rjtest2=johansen_common_beta(rj1,3,H2)
// normalize the cointegrating vectors as in Juselius
rjtest2n=johansen_normalize(rjtest2,[3;1;4])
// print the -now normalized- first 3 cointegrating vectors
// prtjohvec(rjtest2n,3)
 
 
write(%io(2),'************','(a)')
write(%io(2),'table 10.3 p.188','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
 
write(%io(2),'first remove the trend from the cointegrating relation','(a)')
rj2=johansen(1,'dnk_Lm3rC','dnk_Lyr','dnk_DLpy','dnk_Rm','dnk_Rb',...
'exo_lt=post(1983q1)','exo_st=const;dum75q4;dum76q4;dum83q1')
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H7','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
b=[0;0;1;0;0;0]
rjtest7=johansen_known_beta(rj2,3,b)
 
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H8','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
b=[0;0;0;1;0;0]
rjtest8=johansen_known_beta(rj2,3,b)
// H9 p.188
b=[0;0;0;0;1;0]
rjtest9=johansen_known_beta(rj2,3,b)
 
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H10','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
b=[0;0;1;-1;0;0]
rjtest10=johansen_known_beta(rj2,3,b)
 
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H11','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
b=[0;0;1;0;-1;0]
rjtest11=johansen_known_beta(rj2,3,b)
 
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H12','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
b=[0;0;0;1;-1;0]
rjtest12=johansen_known_beta(rj2,3,b)
 
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H13','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
H1=zeros(6,2);
H1(1,1)=1;
H1(2,1)=-1;
H1(6,2)=1
rjtest13=johansen_beta_part(rj2,3,H1)
 
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H17','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
H1=zeros(6,3)
H1(2,1)=1
H1(3,2)=1
H1(6,3)=1
rjtest17=johansen_beta_part(rj2,3,H1)
 
write(%io(2),' ','(a)')
write(%io(2),'hypothesis H22','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
H1=zeros(6,2)
H1(3,1)=1
H1(4,1)=-1
H1(6,2)=1
rjtest22=johansen_beta_part(rj2,3,H1)
 
write(%io(2),' ','(a)')
write(%io(2),'table 11.1 p.197 - case of the monney demand with 3 cointegration relations','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rjtest23=johansen_test_lr_weakexo(rj2,3,'dnk_Lm3rC')
 
write(%io(2),' ','(a)')
write(%io(2),'test of pages 196-197 that y and Rb are both weakly exogenous','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rjtest24=johansen_test_lr_weakexo(rj2,3,['dnk_Lyr' 'dnk_Rb'])
 
write(%io(2),' ','(a)')
write(%io(2),'test of pages 202: case of mr','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rjtest25=johansen_known_alpha(rj2,3,[1 0 0 0 0]')
 
write(%io(2),' ','(a)')
write(%io(2),'test of pages 202: case of Lyr','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rjtest26=johansen_known_alpha(rj2,3,[0 1 0 0 0]')
 
write(%io(2),' ','(a)')
write(%io(2),'test of pages 202: case of DLpy','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rjtest27=johansen_known_alpha(rj2,3,[0 0 1 0 0]')
 
write(%io(2),' ','(a)')
write(%io(2),'test of pages 202: case of Rm','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rjtest28=johansen_known_alpha(rj2,3,[0 0 0 1 0]')
 
write(%io(2),' ','(a)')
write(%io(2),'test of pages 202: case of Rb','(a)')
write(%io(2),'************','(a)')
write(%io(2),' ','(a)')
rjtest29=johansen_known_alpha(rj2,3,[0 0 0 0 1]')
 
endfunction
