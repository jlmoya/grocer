function format_gauss(str)
 
// PURPOSE: mimics gauss function format: sets the format used
// for printings
// ------------------------------------------------------------
// INPUT:
// * str = a string, representing the text of the options
//   entered by the user to format
// ------------------------------------------------------------
// OUTPUT:
// * format_gss = a tlist gathering the format options
//   (returned by command resume to mimic gauss syntax)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
global format_gss ;
 
[nargout,nargin]=argn(0)
 
if isempty(format_gss) | nargin == 0 then
  // default format
   format_gss=tlist(['format';'mat';'sa';'str';'fmted'],...
          ['/mb1','/ros','16' , '8'],['/mb1','/ros','16' , '8'],...
          ['/mb1','/ros','16' , '8'],'on')
end
typ_fmt=2
if nargin ~= 0 then
   while ~isempty(str) then
      str=stripblanks(str)
      str1=part(str,1)
      str2=part(str,1:2)
      str3=part(str,1:3)
      str4=part(str,1:4)
      len_str=length(str)
      if or(str4 == ['/mat' '/str'])  then
         // find the type of data to which options will apply
         typ_fmt=find(['/mat' ;' '; '/str'] == charact)+1
         // withdraw the text pertaining to this option from the string
         str=part(str,5:len_str)
         // withdraw
 
      elseif str3 == '/sa'
         typ_fmt=3
 
      elseif or(str2 == ['/r';'/l']) then
         if or(part(str,4) == ['s';'c';'t';'n']) then
            format_gss(typ_fmt)(2)=str4
            str=part(str,5:len_str)
         else
            format_gss(typ_fmt)(2)=str3+'s'
            str=part(str,4:len_str)
         end
 
      elseif or(str2 == ['/m';'/a';'b']) then
         if or(part(str,4) == string(1:3)) then
            format_gss(typ_fmt)(1)=str4
            str=part(str,5:len_str)
        else
            format_gss(typ_fmt)(2)=str3
            str=part(str,4:len_str)
        end
 
      elseif ascii(str1) >=46 | ascii(str1) <= 57 then
         ind_slash=[strindex(str,'/') %inf]
         ind_comma=[strindex(str,',') %inf]
         ind_semicol=[strindex(str,';') %inf]
         if ind_semicol(1) < min(ind_slash(1),ind_comma) then
            //end of string
            format_gss(typ_fmt)(2)=part(str,1:len_str-1)
            str=[]
         elseif ind_comma(1) < ind_slash(1) then
            format_gss(typ_fmt)(3)=stripblanks(part(str,1:ind_comma(1)-1))
            str=part(str,ind_comma(1)+1:len_str)
         elseif isinf(ind_slash(1)) then
            format_gss(typ_fmt)(4)=str
            str=[]
         else
            format_gss(typ_fmt)(4)=stripblanks(part(str,1:ind_slash(1)-1))
            str=part(str,ind_slash(1):len_str)
         end
      end
   end
end
 
 
 
endfunction
