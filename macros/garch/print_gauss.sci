function print_gauss(varargin)
 
// PURPOSE: mimic gauss function print: Computes the roots
// of the determinant of a matrix polynomial
// ------------------------------------------------------------
// INPUT:
// * varargin =
// - /flush
// - /mat, /sa or /str: indicates which symbol types
//  the output format is for
// - /on or  /off: enables or disables formatting
// - /mf: matrix format
// - /jnt: literal, controls justification, notation, and the
//   trailing character.
// - any GAUSS expressions that produce matrices, arrays,
//   strings, or string arrays and/or names of variables to print,
//   separated by spaces.
// (see Gauus Langage Reference for more details)
// ------------------------------------------------------------
// OUTPUT:
// Nothing: the result is printed on screen
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
global format_gss grocer_output ;
 
if ~exists('grocer_output') then
   grocer_output=list()
end
 
grocer_nargin=length(varargin)
 
if grocer_nargin == 0 then
   return
end
 
if isempty(format_gss) then
   format_gauss()
end
 
grocer_typ=2
grocer_trailing=tlist(['trail';'s';'c';'t';'n'],' ','c',ascii(9),'')
 
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      if stripblanks(grocer_argi) == '/on' then
         varargin(grocer_i)=null()
 
      elseif stripblanks(grocer_argi) == '/off' then
         varargin(grocer_i)=null()
         format_gss('fmted')='off'
 
      elseif stripblanks(grocer_argi) == '/flush'  then
         varargin(grocer_i)=null()
//         mclose(grocer_output)
//         fd=mopen(grocer_output,'wt')
 
      elseif or(grocer_argi == ['/mat' ;'/sa';'/str']) then
         varargin(grocer_i)=null()
         grocer_typ=find(['/mat' ;'sa '; '/str'] == grocer_argi)+1
 
      elseif or(part(stripblanks(grocer_argi),1:2) == ['/r' ;'/l']) then
         varargin(grocer_i)=null()
         if length(grocer_argi) == 3 then
            format_gss(grocer_typ)(2)=grocer_argi+'s'
         else
            format_gss(grocer_typ)(2)=grocer_argi
         end
 
      elseif or(part(stripblanks(grocer_argi),1:2) == ['/m' ;'/a' ; '/b']) then
         varargin(grocer_i)=null()
         format_gss(grocer_typ)(1)=grocer_argi
      end
   end
end
 
grocer_v=format()
format_gauss_mat=format_gss('mat')
execstr('grocer_fmt_dec='+format_gauss_mat(4))
grocer_fmt_numbers=part(format_gauss_mat(2),3)
grocer_nargin=length(varargin)
grocer_typeof_arg=zeros(grocer_nargin,1)
grocer_trailing_arg=emptystr(grocer_nargin,1)
 
for grocer_i=1:grocer_nargin
   grocer_argi=varargin(grocer_i)
   [grocer_nrows,grocer_ncols]=size(grocer_argi)
 
   if typeof(grocer_argi) == 'constant' then
      grocer_trailing_i=part(format_gauss_mat(2),4)
      if isempty(grocer_trailing_i) then
         grocer_trailing_arg(grocer_i)=''
      else
         grocer_trailing_arg(grocer_i)=grocer_trailing(grocer_trailing_i)
      end
      grocer_typeof_arg(grocer_i)=2
      grocer_data=string(grocer_argi)
 
      for grocer_j=1:grocer_nrows
         for grocer_k=1:grocer_ncols
            grocer_data(grocer_j,grocer_k)=num2fmt(grocer_argi(grocer_j,grocer_k),grocer_fmt_numbers,grocer_fmt_dec)
         end
      end
      grocer_argi=grocer_data
   else
      if max(size(grocer_argi)) == 1 then
         grocer_typeof_arg(grocer_i)=4
      else
         grocer_typeof_arg(grocer_i)=3
      end
   end
 
   grocer_format_argi=format_gss(grocer_typeof_arg(grocer_i))
   grocer_justified=part(grocer_format_argi(2),2)
   grocer_mf=grocer_format_argi(1)
   execstr('grocer_leng='+grocer_format_argi(3))
   grocer_argi=justify_g(grocer_argi,grocer_leng,grocer_justified)
 
   if part(grocer_mf,2:3) == 'ma' then
      execstr('grocer_nreturns='+part(grocer_mf,4))
      grocer_argin=emptystr((grocer_nreturns)*grocer_nrows-grocer_nreturns,grocer_ncols)+' '
      grocer_argin(1+2*[0:nrows-1])=grocer_argi
      grocer_argi=grocer_argin
 
   elseif part(grocer_mf,2) == 'm' then
      execstr('grocer_opt='+part(grocer_mf,length(grocer_mf)))
      if grocer_opt == 3 then
         grocer_argin=emptystr(2*grocer_nrows,grocer_ncols)+' '
         grocer_argin(2+2*[0:nrows-1],:)=argi
         grocer_argin(1+2*[0:nrows-1],1)='Row '+string([1:nrows]')
      elseif grocer_opt == 0 then
         grocer_argin=strcat(grocer_argi(1,:),grocer_trailing_arg(grocer_i))
         for grocer_j=2:grocer_nrows
            grocer_argin=grocer_argin+strcat(grocer_argi(grocer_j,:),grocer_trailing_arg(grocer_i))
         end
      else
         grocer_argin=emptystr(grocer_opt*grocer_nrows,grocer_ncols)+' '
         grocer_argin(grocer_opt*[1:grocer_nrows],:)=grocer_argi
      end
      grocer_argi=grocer_argin
   end
 
   if grocer_ncols > 1 | grocer_nrows > 1 then
      if part(grocer_mf,2) == 'a' then
         grocer_opt=part(grocer_mf,3)
         grocer_argin=emptystr((grocer_opt+1)*grocer_nrows,grocer_ncols)+' '
         grocer_argin((grocer_opt+1)*[1:grocer_nrows])=grocer_argi
         grocer_argi=grocer_argin
 
      elseif part(grocer_mf,2) == 'b' then
         grocer_opt=part(grocer_mf,3)
         if grocer_opt == '3' then
            grocer_argin=emptystr(2*grocer_nrows,grocer_ncols)+' '
            grocer_argin(2+2*[0:grocer_nrows-1])=grocer_argi
            grocer_argin(1+2*[0:grocer_nrows-1],1)='Row '+string([1:grocer_nrows]')
         else
            grocer_argin=emptystr((grocer_opt+1)*grocer_nrows,grocer_ncols)+' '
            grocer_argin((grocer_opt+1)*[1:grocer_nrows])=grocer_argi
         end
         grocer_argi=grocer_argin
      end
   end
   varargin(grocer_i)=grocer_argi
end
 
grocer_i=1
grocer_h=(size(varargin(1),1) == 1)
grocer_m2prt=emptystr()
while grocer_h then
    grocer_m2prt=grocer_m2prt+strcat(varargin(grocer_i),grocer_trailing_arg(grocer_i))
    grocer_i=grocer_i+1
    if grocer_i > grocer_nargin then
       grocer_h=%f
    elseif size(varargin(grocer_i),1) > 1 then
       grocer_h=%f
    end
end
if ~isempty(grocer_m2prt) then
   write(%io(2),grocer_m2prt)
   if ~isempty(grocer_output) then
      mputl(grocer_m2prt,grocer_output(2))
   end
end
 
for i=grocer_i:grocer_nargin
   grocer_argi=varargin(grocer_i)
   grocer_m2prt=emptystr(size(grocer_argi,1),1)
   for grocer_j=1:size(grocer_argi,1)
      grocer_m2prt(grocer_j)=strcat(grocer_argi(grocer_j,:),grocer_trailing_arg(grocer_i))
   end
   write(%io(2),grocer_m2prt)
   if ~isempty(grocer_output) then
      mputl(grocer_m2prt,grocer_output(2))
   end
end
format(grocer_v(2),grocer_v(1))
 
endfunction
