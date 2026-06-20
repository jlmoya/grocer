function plt_impact_shock(db1,db2,boun,vari,transf,tit,varargin)
 
// PURPOSE: plot results of the a simulation of a shock
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
// * tit= a string, the title of the graph
// * varargin = optional arguments that can be 'leg=x' if the
//   user wants its own legend or any variable argument to
//   function pltseries0
// ------------------------------------------------------------
// OUTPUT:
// Nothing: results are displayed on screen
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
leg='leg='+strcat(vari,';')
nargin=length(varargin)
for i=nargin:-1:1
   argi=stripblanks(varargin(i))
   if part(argi,1:7) == 'legend=' then
      leg=strsubst(argi,'legend','leg')
      varagin(i)=null()
   end
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
 
nvari=size(vari,'*')
y=zeros(ind$_dat_db1-ind1_dat_db1+1,nvari)
ind_names1=zeros(vari)
ind_names2=zeros(vari)
for i=nvari:-1:1
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
         sers1=db1('series')(ind1_dat_db1:ind$_dat_db1,ind1_i)
         sers2=db2('series')(ind1_dat_db2:ind$_dat_db2,ind2_i)
         select transf(i)
         case 'pcer' then
            y(:,i)=100*(sers2 ./ sers1-1)
         case 'er' then
            y(:,i)=sers2- sers1
         else
            error('not an available option to compare databases: '+transf)
         end
      end
   end
end
 
win=winsid()
 
scal=0:ind$_dat_db1-ind1_dat_db1+1
pltseries0(y,0,tit,scal,max(win)+1,leg,'styleg=7',varargin(:))
xlabel(xleg,"fontsize",4)
 
endfunction
