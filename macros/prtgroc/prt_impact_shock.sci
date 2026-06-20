function prt_impact_shock(db1,db2,boun,vari,transf,periods,labels)
 
// PURPOSE: displays results of the a simulation of a shock
// on a model
// ------------------------------------------------------------
// INPUT:
// * db1 = a tsmat, representing the baseline
// * db2= a tsmat, representing the database resulting from
//   the simulation of the shock
// * bound = a [2 x 1] string vector, the simulation bounds
// * vari = a [n x 1] string vector, collecting the variable
// names belonging to the simulated model and the databases
// db1 and db2 that will be displayed
// * transf = a [n x 1] string vector, collecting the ways
// the variables will be compared ('pcer' for in percentages,
// 'er' for in differences)
// * periods = a [k x 1] string vector, collecting the periods
// over which the results will be displayed, of the type 'pi'
// with:
//  - p a period type (m for month', q for quarter, a for
//    year)
//  - i a integer, the index of the periods
// * labels  = an (optional) [n x 1] string vector, collecting
// names the variables will be given in the table (if different
// from their names in the model)
// ------------------------------------------------------------
// OUTPUT:
// Nothing: reuslt are displayed on screen
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin]=argn(0)
if nargin > 7 then
   labels=vari
end
 
name1=db1('names')
name2=db2('names')
dates1=db1('dates')
ndates1=size(dates1,1)
dates2=db2('dates')
ndates2=size(dates2,1)
[first_date,fq1]=date2num_fq(boun(1))
[last_date,fq$]=date2num_fq(boun(2))
if fq1 ~= fq$ then
   error('frequencies of the given bounds are not the same')
end
freq1=db1('freq')
freq2=db2('freq')
if freq1 ~= fq1 then
   error('frequencies of the given bounds and of the firsat database are not the same')
end
 
if freq2 ~= fq1 then
   error('frequencies of the given bounds and of the firsat database are not the same')
end
 
if fq1 == 1 | fq1 == [1,1] then
   xleg='year'
 
elseif fq1 == 4 | fq1 == [4,1] then
   xleg='quarter'
 
elseif fq1 == 12 | fq1 == [12,1] then
   xleg='month'
 
end
 
ind1_dat_db1=first_date-dates1(1)+1
if ind1_dat_db1 <= 0 then
   warning('first given bound is before the start of first database: it is daapted correspondingly')
   first_date=dates1(1)
end
ind1_dat_db2=first_date-dates2(1)+1
if ind1_dat_db2 <= 0 then
   warning('first given bound is before the start of second database: it is adapted correspondingly')
   first_date=dates2(1)
end
ind1_dat_db1=first_date-dates1(1)+1
ind1_dat_db2=first_date-dates2(1)+1
 
ind$_dat_db1=last_date-dates1(1)+1
if ind$_dat_db1 > ndates1 then
   warning('last given bound is after the end of first database: it is daapted correspondingly')
   last_date=dates1($)
end
ind$_dat_db2=last_date-dates2(1)+1
if ind$_dat_db2 > ndates2 then
   warning('last given bound is after the end of second database: it is daapted correspondingly')
   last_date=dates2($)
end
ind$_dat_db1=last_date-dates1(1)+1
ind$_dat_db2=last_date-dates2(1)+1
 
if name1 ~= name2 then
   warning('databases have not the same variables names')
end
 
ind_names1=zeros(vari)
ind_names2=zeros(vari)
nvari=size(vari,'*')
for i=size(vari,'*'):-1:1
   ind1_i=find(name1 == vari(i))
   if isempty(ind1_i) then
      warning('variable '+vari(i)+' not found in first database')
      ind_names1(i)=[]
      ind_names2(i)=[]
   else
      ind2_i=find(name2 == vari(i))
      if isempty(ind2_i) then
         warning('variable '+vari(i)+' not found in second database')
         ind_names1(i)=[]
         ind_names2(i)=[]
 
      else
         ind_names1(i)=ind1_i
         ind_names2(i)=ind2_i
      end
   end
end
sers1=db1('series')(ind1_dat_db1:ind$_dat_db1,ind_names1)
sers2=db2('series')(ind1_dat_db2:ind$_dat_db2,ind_names2)
 
nperiods=size(periods,'*')
vals1=zeros(nvari,nperiods)
vals2=zeros(nvari,nperiods)
vals=zeros(nvari,nperiods)
mult=ones(nvari,1)
 
for i=1:size(periods,'*')
   periods_i=periods(i)
   select part(periods(i),1)
   case 'm' then
      fq2=12
 
   case 'q' then
      fq2=4
 
   case 'a' then
      fq2=1
 
   else
      error('first char of periods # '+string(i)+' is not admissible')
   end
   if fq2 > fq1(1) then
      error('frequency of '+string(i)+' period  is too high')
   end
   if fq1(1) == fq2 then
      if part(periods_i,length(periods_i)) == '$' then
         vals1(:,i)=sers1($,:)'
         vals2(:,i)=sers2($,:)'
      else
         j=evstr(part(periods_i,2:length(periods_i)))
         vals1(:,i)=sers1(j,:)'
         vals2(:,i)=sers2(j,:)'
      end
   else
      mult(i)=fq1(1)/fq2
      if part(periods_i,length(periods_i)) == '$' then
         vals1(:,i)=sum(sers1($-mult(i)+1:$,:),'r')'
         vals2(:,i)=sum(sers2($-mult(i)+1:$,:),'r')'
      else
         j=evstr(part(periods_i,2:length(periods_i)))
         vals1(:,i)=sum(sers1((j-1)*mult(i)+1:j*mult(i),:),'r')'
         vals2(:,i)=sum(sers2((j-1)*mult(i)+1:j*mult(i),:),'r')'
      end
   end
 
end
 
for i=1:nvari
    select transf(i)
    case 'pcer' then
       vals(i,:)=(vals2(i,:)./vals1(i,:)-1)*100
    case 'er' then
       vals(i,:)=vals2(i,:)-vals1(i,:)
    case 'er mean' then
       vals(i,:)=(vals2(i,:)-vals1(i,:))/mult(i)
    end
 
end
 
write(%io(2),' ')
mat2prt=['' , periods(:)' ]
mat2prt2=[vari , string(vals)]
mat2prt=[mat2prt ; mat2prt2 ]
 
printmat(mat2prt,%io(2))
 
endfunction
