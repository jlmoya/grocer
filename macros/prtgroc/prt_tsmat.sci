function prt_tsmat(type_prt,bounds_prt,db,vari,nseriespertab,out)
 
// PURPOSE: prints the data from 1 or more tsmat; this is in
// paticular suited to results from model simulations
// ------------------------------------------------------------
// INPUT:
// * type_prt = 'pcer', 'diff', 'level', 'growth rate'
//  - 'pcer' = calculate the percentage differences between the
//    db with repsect to the first one
//  - 'diff' = calculate the differences between the db with
//    repsect to the first one
//  - 'level' = presents the databases one by one
//  - 'growth rate' = presents the growth rate of the chosen
//     variables in the databases one by one
// * bounds_prt = a string vetor of even size or of size 1
// * db =
//   - a list of tsmat
//   - or a string vector of names of tsmast between quotes
//   - or a tsmat
// * vari = a matrix of strings containing elements among these:
//   - names of variables existing in the tsmat(s)
//   - the keyword 'all' if you want to print all variables
//   (note: if you want to display the values of peculiar types
//    of variables frome a model (say mymodel), such as
//   'endogenous', 'exoegnous' or 'residuals', then enter
//   mymodel('name endo'), etc.)
// * nseriespertab = a scalar, the maximum #of series you want
//   to be displayed at a time (optional argument: if not given,
//   then all series are displayed in the same tab, whcich may
//   lead to a very large tab)
// * nseriespertab = a scalar, the maximum # of series you want
//   to be displayed at a time (optional argument: if not given,
//   the all series are displayed in the same tab, whcich may
//   lead to a veyr large tab)
// ------------------------------------------------------------
// OUTPUT:
// * nothing: all results are sent to the output file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
 
// note: il y a encore de nombreux cas à traiter ; laissé pour le futur
 
[nargout,nargin]=argn(0)
if nargin < 6 then
   out=%io(2)
end
 
select typeof(db)
 
case 'list' then
   ndb=length(db)
   for i=1:ndb
      execstr('db'+string(i)+'='+db(i))
   end
 
case 'string' then
   ndb=size(db,'*')
   for i=1:ndb
      execstr('db'+string(i)+'='+db(i))
   end
 
case 'tsmat' then
   ndb=1
   db1=db
   db='tsmat'
end
 
 
nbounds=size(bounds_prt,'*')
if nbounds == 1 then
   [ind_date,fq]=date2num_fq(bounds_prt)
 
elseif modulo(nbounds,2) == 1 then
   error('the number of your arguments is not even')
 
else
   [ind_date1,fq]=date2num_fq(bounds_prt(1))
   ind_date2=date2num(bounds_prt(2))
   ind_date=ind_date1:ind_date2
   for j=2:nbounds/2
      [ind_date1,fq]=date2num_fq(bounds_prt(2*j-1))
      ind_date2=date2num(bounds_prt(2*j))
      ind_date=[ind_date , ind_date1:ind_date2]
   end
end
ind_datelit=num2date(ind_date,fq)
 
for i=1:ndb
   execstr('datei=db'+string(i)+'(''dates'')')
   if datei(1) > ind_date(1) then
      error('bounds start before the first period of db # '+string(i))
   end
   if datei($) < ind_date($) then
      error('bounds end after the last period of db # '+string(i))
   end
 
end
 
list_indvari=list()
vari=vari(:)
if vari == 'all' then
   for j=1:ndb
      execstr('tsmat_names=db'+string(j)+'(''names'')')
      indvari=1:size(tsmat_names,1)
      vari=tsmat_names
      list_indvari($+1)=indvari
   end
 
else
   for j=1:ndb
      execstr('tsmat_names=db'+string(j)+'(''names'')')
      vari=develop_str(vari,tsmat_names)
      indvari=[]
      notfound=[]
      for i=1:size(vari,'*')
         indvari_i=find(tsmat_names == vari(i))
         if isempty(indvari_i) then
            notfound=[notfound , vari(i)]
         else
            indvari=[indvari , indvari_i]
         end
      end
      if ~isempty(notfound) then
         error('variables '+strcat(notfound,' ')+' not found in the database # '+string(j))
      end
      list_indvari($+1)=indvari
   end
end
nvari=size(indvari,2)
 
write(out,' ')
write(out,' ')
 
mod=ieee()
if part(type_prt,1:4) == 'pcer' then
   ieee(2)
   ind_dates1=ind_date-db1('dates')(1)+1
   ind_names1=list_indvari(1)
   s1=db1('series')(ind_dates1,ind_names1)
   for j=2:ndb
      execstr('dbj=db'+string(j))
      ind_datesj=ind_date-dbj('dates')(1)+1
      ind_namesj=list_indvari(j)
      sj=(dbj('series')(ind_datesj,ind_namesj) ./ s1 -1)*100
      if stripblanks(strsubst(type_prt,'pcer','')) == 'rmse' then
          nobs=size(sj,1)
          mean_sj=sum(sj,1)/nobs
          rmse=sqrt(sum((sj-(mean_sj .*. ones(nobs,1))).^2,1)/(nobs-1))'
          write(out,' ')
          tab2prt=[vari , string(rmse)]
          printmat(tab2prt,out)
          write(out,' ')
 
      elseif nargin >= 5 then
         nbtab=ceil(nvari/nseriespertab)
         tab=1
         while tab <= nbtab then
            nbseries=min(nseriespertab,nvari-nseriespertab*(tab-1))
            tab2prt=[' ' vari(nseriespertab*(tab-1)+[1:nbseries])' ; [ind_datelit' , string(sj(:,nseriespertab*(tab-1)+[1:nbseries]))]]
            printmat(tab2prt,out)
            write(out,' ')
            write(out,' ')
            tab=tab+1
         end
 
      else
         tab2prt=[' ' vari' ; [ind_datelit' , string(sj)]]
         printmat(tab2prt,out)
      end
 
   end
 
elseif type_prt == 'er' then
   ieee(2)
   ind_dates1=ind_date-db1('dates')(1)+1
   ind_names1=list_indvari(1)
   s1=db1('series')(ind_dates1,ind_names1)
   for j=2:ndb
      execstr('dbj=db'+string(j))
      ind_datesj=ind_date-dbj('dates')(1)+1
      ind_namesj=list_indvari(j)
      sj=dbj('series')(ind_datesj,ind_namesj) - s1
      if nargin >= 5 then
         nbtab=ceil(nvari/nseriespertab)
         tab=1
         while tab <= nbtab then
            nbseries=min(nseriespertab,nvari-nseriespertab*(tab-1))
            tab2prt=[' ' vari(nseriespertab*(tab-1)+[1:nbseries])' ; [ind_datelit' , string(sj(:,nseriespertab*(tab-1)+[1:nbseries]))]]
            printmat(tab2prt,out)
            write(out,' ')
            write(out,' ')
            tab=tab+1
         end
      else
         tab2prt=[' ' vari' ; [ind_datelit' , string(sj)]]
         printmat(tab2prt,out)
      end
   end
 
elseif type_prt == 'level' then
   ieee(2)
   ind_dates1=ind_date-db1('dates')(1)+1
   ind_names1=list_indvari(1)
   for j=1:ndb
      write(out,db(j))
      write(out,strcat(emptystr(length(db(j))+1,1),'-'))
      write(out,' ')
      execstr('dbj=db'+string(j))
      ind_datesj=ind_date-dbj('dates')(1)+1
      ind_namesj=list_indvari(j)
      sj=dbj('series')(ind_datesj,ind_namesj)
      if nargin >= 5 then
         nbtab=ceil(nvari/nseriespertab)
         tab=1
         while tab <= nbtab then
            nbseries=min(nseriespertab,nvari-nseriespertab*(tab-1))
            tab2prt=[' ' vari(nseriespertab*(tab-1)+[1:nbseries])' ; [ind_datelit' , string(sj(:,nseriespertab*(tab-1)+[1:nbseries]))]]
            printmat(tab2prt,out)
            write(out,' ')
            write(out,' ')
            tab=tab+1
         end
      else
         tab2prt=[' ' vari' ; [ind_datelit' , string(sj)]]
         printmat(tab2prt,out)
      end
   end

elseif type_prt == 'growth rate' then
   ieee(2)
   ind_dates1=ind_date-db1('dates')(1)
   ind_names1=list_indvari(1)
   for j=1:ndb
      write(out,db(j))
      write(out,strcat(emptystr(length(db(j))+1,1),'-'))
      write(out,' ')
      execstr('dbj=db'+string(j))
      ind_datesj=ind_date-dbj('dates')(1)+1
      ind_namesj=list_indvari(j)
      sj0=dbj('series')([ind_datesj(1)-1 , ind_datesj],ind_namesj)
      sj=sj0(2:$,:)./sj0(1:$-1,:)-1
      if nargin >= 5 then
         nbtab=ceil(nvari/nseriespertab)
         tab=1
         while tab <= nbtab then
            nbseries=min(nseriespertab,nvari-nseriespertab*(tab-1))
            tab2prt=[' ' vari(nseriespertab*(tab-1)+[1:nbseries])' ; [ind_datelit' , string(sj(:,nseriespertab*(tab-1)+[1:nbseries]))]]
            printmat(tab2prt,out)
            write(out,' ')
            write(out,' ')
            tab=tab+1
         end
      else
         tab2prt=[' ' vari' ; [ind_datelit' , string(sj)]]
         printmat(tab2prt,out)
      end
   end
 
else
   error('not ana option: '+type_prt)
 
end
ieee(mod)
 
endfunction
