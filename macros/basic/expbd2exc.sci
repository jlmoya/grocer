function []=expbd2exc(grocer_bd,grocer_output,grocer_sep,grocer_transpose,grocer_sepx,grocer_names)
 
 
// PURPOSE: export the content of a data base or a list of
// variables bd to a file that Excel can read
//-------------------------------------------------------------
// INPUT:
// * grocer_bd = the name of a database or of a list of ts
// loaded in the environment
// * grocer_output = the excel file where to save the data
// * sep = decimal separator (optional: if not given then sep= '.')
// * transpose = a boolean indicating whether the data must be
//   transposed or not (default = %f)
// * grocer_sepx = a string indicating the separator to be used
//   between columns (default ' ')
// * grocer_names = (k x 1) string vectors, the names that the
//   variables will have in the csv files (optional; default:
//   the names of the data in Scilab)
//-------------------------------------------------------------
// OUTPUT:
// nothing
//-------------------------------------------------------------
// Copyright Eric Dubois 2004-2018
 
// to raise the speed of the function, I make an intensive use
// of the following trick:
//
// for i=1:n
//    y(i)=foo(i)
// end
//
// can be performed also as follows:
//
// execstr('y('+string(1:n)+')=foo('+string(1:n)+')')
// or:
// y=[];execstr('y=[y foo('+string(1:n)+')]')
//
// and this second way is generally more efficient
//
// for instance (line 66):
// execstr('grocer_dmin=[grocer_dmin ; min(datets(grocer_lvar('+string([1:grocer_nvar])+')))]')
//
// is equivalent to:
// for i=1:grocer_nvar
//    grocer_dmin=[grocer_dmin ; min(datets(grocer_lvar(i))]
// end
 
 
if typeof(grocer_bd) == 'list' then
   grocer_nvar=length(grocer_bd)

elseif typeof(grocer_bd) == 'string' then
   if size(grocer_bd,'*') == 1 & isfile(grocer_bd(1)) then
      // this is the name of a database: load it 
      load(grocer_bd)
      // recover the names in teh database; option short 'entered' in the cas of the variable
      // grocer_content exists in the database and the first lines are not the names of teh variables,
      // but strings used for printing
      grocer_bd=dblist(grocer_bd,'short')
   end
   grocer_nvar=size(grocer_bd,1)
      
else
   error('not and admissible type for exportation; '+typeof(grocer_bd))
end
 
[nargout,nargin]=argn(0)
if nargin < 5 then
   grocer_sepx=' '
end
if nargin < 4 then
   grocer_transpose=%f
end
if nargin == 2 then
   grocer_sep='.'
end
 
execstr('grocer_x='+grocer_bd(1))
select typeof(grocer_x)
case 'ts' then
   grocer_lvar=list()
   execstr('grocer_lvar('+string([1:grocer_nvar])+')=evstr(grocer_bd('+string([1:grocer_nvar])+'))')
   grocer_fq=[]
   grocer_dmin=[]
   grocer_dmax=[]
 
   execstr('grocer_fq=[grocer_fq ; freqts_c(grocer_lvar('+string([1:grocer_nvar])+'))]')
   execstr('grocer_dmin=[grocer_dmin ; min(datets(grocer_lvar('+string([1:grocer_nvar])+')))]')
   execstr('grocer_dmax=[grocer_dmax ; max(datets(grocer_lvar('+string([1:grocer_nvar])+')))]')
   if or(grocer_fq ~= grocer_fq(1)) then
      error('all ts have not the same frequency')
   end
 
   grocer_mindmin=min(grocer_dmin)
   grocer_maxdmax=max(grocer_dmax)
 
   grocer_comments=emptystr(1,grocer_nvar)
   grocer_existscomments=%f
 
   for grocer_i=1:grocer_nvar
      execstr('grocer_tsi='+grocer_bd(grocer_i))
      if or(grocer_tsi(1) == 'comment') then
         // tsi contains a comment
         if ~isempty(grocer_tsi('comment'))
            grocer_existscomments=%t
            grocer_comments(grocer_i)=grocer_tsi('comment')
         end
      end
   end
 
   if and(grocer_x('freq') == 1)  then
   // annual data: use directly the numerical date format
      grocer_dat=string(grocer_mindmin:grocer_maxdmax)
   else
      grocer_dat=num2date([grocer_mindmin:grocer_maxdmax],grocer_x('freq'))
   end
 
   grocer_mat=[['dates' ; emptystr(bool2s(grocer_existscomments),1) ; grocer_dat'] , emptystr(grocer_maxdmax-grocer_mindmin+2+bool2s(grocer_existscomments),grocer_nvar)+' ']
 
   if nargin == 6 then
      grocer_names=vec2row(grocer_names)
      grocer_mat(1,2:grocer_nvar+1)=grocer_names
   else
      execstr('grocer_mat(1,'+string(2:grocer_nvar+1)+')=grocer_bd('+string(1:grocer_nvar)+')')
   end
   if grocer_existscomments then
   // add the comments as a second column
 
      grocer_mat(2,1:grocer_nvar+1)=['labels' , grocer_comments]
   end
   lhs1='grocer_mat([grocer_dmin('+string(1:grocer_nvar)+'):grocer_dmax('+string(1:grocer_nvar)+')]'
   lhs2='-grocer_mindmin+2+bool2s(grocer_existscomments),'+string(2:grocer_nvar+1)+')'
   rhs='=string(series(grocer_lvar('+string(1:grocer_nvar)+')))'
   execstr(lhs1+lhs2+rhs)
 
case 'constant' then
 
   grocer_size_vec=[]
   execstr('grocer_size_vec=[grocer_size_vec ; size(evstr(grocer_bd('+string([1:grocer_nvar])+')),''*'')]')
   grocer_maxs=max(grocer_size_vec)
   grocer_mat=emptystr(grocer_maxs+1,grocer_nvar)
   if nargin == 6 then
      grocer_names=vec2row(grocer_names)
      grocer_mat(1,1:grocer_nvar)=grocer_names
   else
      execstr('grocer_mat(1,'+string([1:grocer_nvar])+')=grocer_bd('+string([1:grocer_nvar])+')')
   end
   lhs='grocer_mat(2:1+grocer_size_vec('+string([1:grocer_nvar])+'),'+string([1:grocer_nvar])+')'
   rhs='=string(evstr(grocer_bd('+string([1:grocer_nvar])+')))'
   execstr(lhs+rhs)
 
case 'string' then
 
   grocer_size_vec=[]
   execstr('grocer_size_vec=[grocer_size_vec ; size(evstr(grocer_bd('+string([1:grocer_nvar])+')),''*'')]')
   grocer_maxs=max(grocer_size_vec)
   grocer_mat=emptystr(grocer_maxs+1,grocer_nvar)
   lhs='grocer_mat(2:1+grocer_size_vec('+string([1:grocer_nvar])+'),'+string([1:grocer_nvar])+')'
   rhs='=grocer_bd('+string([1:grocer_nvar])+')))'
 
 
else
   error(typeof(grocer_x)+' is not a valid type for the exportation to excel')
end
 
grocer_ind=find(grocer_mat == 'Nan')
grocer_mat(grocer_ind)='#N/A'
 
if grocer_sep ~= '.' then
   grocer_mat=strsubst(grocer_mat,'.',grocer_sep)
end
 
if grocer_transpose then
   grocer_mat=grocer_mat'
end
 
grocer_m2tobexported=grocer_mat(:,1)
for grocer_i=2:size(grocer_mat,2)
   grocer_m2tobexported=grocer_m2tobexported+grocer_sepx+grocer_mat(:,grocer_i)
end
 
mputl(grocer_m2tobexported,grocer_output)
 
endfunction
 
