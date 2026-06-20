function rpdb = paneldb(grocer_ind,grocer_var,varargin)
 
// PURPOSE: Build a panel tlist
//---------------------------------------------------
// INPUT:
// * grocer_ind = vector of name for individual
// * grocer_var = vector of generic name for variable
// * varargin = arguments which can be:
//  . 'conc' if variable names end by individual identifier
//    (default: variable names start by individual identifier)
//  . 'sep=xx' whith xx a string containing the separator
//      between variable and individual names
//  . 'bounds =[''bounds1'' ''bounds2'']' bounds for data
//  . 'dropna' if the user wants to remove the NA values
//     from the data
//---------------------------------------------------
// OUTPUT:
// * rpdb = a tlist in "panel format"
//  . rpdb('panel data') = type of the list
//  . rpdb('dates')= bounds of data
//  . rpdb('id')= individual indentifiant
//  . rpdb('x')= stacked data in matrix format
//  . rpdb('nameid')= names of individual indentifiant
//  . rpdb('namex')= generic names of data
//  . rpdb('dropna')= boolean indicating if NAs had
//		                         been droped
//  . rpdb('nonna') = vector indicating position of non-NAs
//---------------------------------------------------
// E. Michaux (2006)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_conc = 1
grocer_bounds = []
grocer_dropna = %f
grocer_sep=emptystr()
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
 
      argi=strsubst(varargin(grocer_i),' ','')
      str3=part(argi,1:3)
      str4=part(argi,1:4)
      str6=part(argi,1:6)
 
      if  str6 == 'bounds' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif  str6 == 'dropna' then
         grocer_dropna =%t
         varargin(grocer_i)=null()
      elseif str4 == 'conc' then
         grocer_conc=0
         varargin(grocer_i)=null()
      elseif str3 == 'sep' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
       end
 
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
                                typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
 
end
 
// matrix of names
ni = max(size(grocer_ind))
nv = max(size(grocer_var))
lname = []
if grocer_conc == 1 then
  for v =1:nv
    for i =1:ni
      execstr('lname = [lname;'''+grocer_ind(i)+grocer_sep+grocer_var(v)+''']')
    end
  end
else
  for v =1:nv
    for i =1:ni
      execstr('lname = [lname;'''+grocer_var(v)+grocer_sep+grocer_ind(i)+''']')
    end
  end
end
 
if isempty(grocer_bounds) then
   [xmat,junk1,junk2,grocer_bounds,nonna] =explone(lname,[],'panel mat',%t,grocer_dropna)
else
   [xmat,junk1,junk2,grocer_bounds,nonna] =explone(lname,grocer_bounds,'panel mat',%t,grocer_dropna)
end
 
// matrix of stacked data
n = size(xmat,1)
grocer_xmat = matrix(xmat,n*ni,nv)
 
// individual idenetifiant
grocer_id = (1:ni)'.*.ones(n,1)
 
//vector of dates
n = diff_date(grocer_bounds(2),grocer_bounds(1))+1
if n < 0 then
  error('bounds are expressed in the wrong order')
end
 
[datfirst,fq]=date2num_fq(grocer_bounds(1))
vdate=datfirst+[0:(n-1)]*fq(2)	
vdate = num2date(vdate,fq)
vdate = repmat(vdate,1,ni) // repeat vector of dates n-times (n=number of individuals)
 
// transpose data if necessary
[n1,n2]=size(grocer_ind)
if n1<n2 then
   grocer_ind=grocer_ind'
end
 
[n1,n2]=size(grocer_var)
if n1<n2 then
   grocer_var=grocer_var'
end
 
 
// tlist result
rpdb = tlist(['panel data';'dates';'id';'x';'nameid';'namex';'dropna'],...
              vdate,grocer_id,grocer_xmat,grocer_ind,grocer_var,grocer_dropna);
 
if grocer_dropna then
  rpdb(1)($+1) = 'nonna'
  rpdb('nonna') = nonna
end
 
endfunction
