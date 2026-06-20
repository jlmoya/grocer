function simul_bounds=bounds_db4model(model,dbmod,np)
 
// PURPOSE: find the admissible bounds for a model and its
// database
// ------------------------------------------------------------
// INPUT:
// * model = a model tlist
// * dbmod = a database tsmat
// * np = 'noprint' if the user does want to dosplay the bounds
// ------------------------------------------------------------
// OUTPUT:
// * simul_bounds = a (n x 3) string matrix, with:
//  - the first column gathers the first possible starting date
//  - the second column gathers the last possible starting date
//  - the third column gathers the last possible ending date
// ------------------------------------------------------------
// Copyright: Eric Dubois 2017
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if typeof(dbmod) == 'results' then
   if  or(dbmod(1) == 'simulation results') then
      dbmod= dbmod('simulation results')
   end
end
 
lag_exo=model('lags exos')
lag_resid=model('lags resids')
lag_endo=model('lags endos')
maxlag=model('maxlag')
start_db=maxlag+1
 
name_endo=model('name endo')
name_exo=model('name exo')
name_resid=model('name resid')
fq=dbmod('freq')
dat=dbmod('dates')
dat=[dat(1)+maxlag:dat($)]'
 
names_db=dbmod('names')
ser=dbmod('series')
nobs=size(ser,1)
 
clear model dbmod ;
// fill the matrix exo_lagged with all exogenous variables lagged as recorded
// in the model tlist
exo_lagged=0
for i=1:size(name_exo,1)
   name_exo_i=name_exo(i)
   lag_exo_i=unique(lag_exo(i))
   ind_exo_indb=find(name_exo_i == names_db)
   dbmod_exo_i=ser(:,ind_exo_indb)
   for j=1:size(lag_exo_i,1)
       aux=abs(dbmod_exo_i(start_db-lag_exo_i(j):nobs-lag_exo_i(j)));
       exo_lagged=exo_lagged + aux./(1+aux)
   end
end
 
// fill the matrix resid_lagged with all residuals variables lagged as recorded
// in the model tlist
for i=1:size(name_resid,1)
   name_resid_i=name_resid(i)
   lag_resid_i=unique(lag_resid(i))
   ind_resid_indb=find(name_resid_i == names_db)
   dbmod_resid_i=ser(:,ind_resid_indb)
   for j=1:size(lag_resid_i,1)
       aux=abs(dbmod_resid_i(start_db-lag_resid_i(j):nobs-lag_resid_i(j)));
       exo_lagged=exo_lagged + aux./(1+aux)
   end
end
 
start1=find(~isnan(exo_lagged))
del_start1=start1(2:$)-start1(1:$-1)
ind_break1=[0 , find(del_start1 > 1) , size(start1,2)]
 
list_lags=list()
for i=1:maxlag
    list_lags($+1)=[]
end
ind_endo_db_k=0
for i=size(name_endo,1):-1:1
   name_endo_i=name_endo(i)
   lag_endo_i=unique(lag_endo(i))
   lag_endo_i=lag_endo_i(lag_endo_i ~= 0)
   // lag_endo_i collects the non 0 lags of endo i
   if ~isempty(lag_endo_i) then
      // ind_endo_indb_i is the index of endo i in the database
      ind_endo_indb_i=find(name_endo_i == names_db)
      ind_endo_db_k=ind_endo_db_k+1
      for j=1:size(lag_endo_i,1)
         lags_j=lag_endo_i(j)
         // add the index of the endo i to the list of endos at lag lags_j
         list_lags(lags_j)=[list_lags(lags_j) ; ind_endo_indb_i]
      end
   end
end
 
if ind_endo_db_k == 0 then
   // no endogenous lagged
//   ind_endo_indb=[]
   endo_lagged=zeros(aux)
   lags=[]
else
//   ind_endo_indb=ind_endo_indb(1:ind_endo_db_k)
   endo_lagged=zeros(aux)
   lags=1:maxlag
   for i=length(list_lags):-1:1
       if isempty(list_lags(i)) then
          list_lags(i)=null()
          lags(i)=[]
       else
          list_lags(i)=unique(list_lags(i))
      end
   end
   for i=1:length(list_lags)
      aux=sum(abs(ser(start_db-lags(i):nobs-lags(i),list_lags(i))),'c')
      endo_lagged=endo_lagged+aux./(1+aux)
   end
end
 
ind_start_sim=find(~isnan(exo_lagged))
 
if isempty(ind_start_sim) then
   simul_bounds=[]
   write(%io(2),'tsmat does not allow any simulation','(a)')
 
else
   ind_lagged_na=find(isnan(endo_lagged))
   ind_lagged_na(ind_lagged_na <= ind_start_sim(1))=[]
   sum_naninrow2=bool2s(isnan(endo_lagged))
   for j=1:size(ind_lagged_na,2)
      sum_naninrow2(ind_lagged_na(j))=0
      for k=lags
         sum_naninrow2(ind_lagged_na(j))=sum_naninrow2(ind_lagged_na(j))+sum(isnan(ser(ind_lagged_na(j)-lags(k),list_lags(k))))
      end
   end
   ind_end_sim=find(~isnan(exo_lagged) & sum_naninrow2 == 0)
 
   simul_bounds=[]
 
   del_start_sim=ind_start_sim(2:$)-ind_start_sim(1:$-1)
   ind_break0=[0 , find(del_start_sim > 1) , size(ind_start_sim,2)]
 
   for j=1:size(ind_break0,2)-1
      ind_ends=ind_end_sim(ind_end_sim > = ind_start_sim(ind_break0(j+1)))
      del_end_sim=ind_ends(2:$)-ind_ends(1:$-1)
      ind_break1=[find(del_end_sim > 1) , size(ind_ends,2)]
      simul_bounds_j=[num2date(dat(ind_start_sim(ind_break0(j)+1)),fq) , num2date(dat(ind_start_sim(ind_break0(j+1))),fq) ,...
                     num2date(dat(ind_ends(ind_break1(1))),fq) ]
   end
   simul_bounds=[simul_bounds ; simul_bounds_j]
   if nargin < 3 then
      mat2prt1=[' - '+simul_bounds(:,1)+' to '+simul_bounds(:,2) ,  emptystr(simul_bounds(:,1))+'|' , simul_bounds(:,3)]
      mat2prt=[['simulation can start from: ' , '|' , 'and must end by:'; '--------------------------' , '|' , '----------------']; mat2prt1]
      write(%io(2),' ','(a)')
      printmat(mat2prt,%io(2))
      write(%io(2),' ','(a)')
      write(%io(2),' ','(a)')
   end
 
end
 
endfunction
