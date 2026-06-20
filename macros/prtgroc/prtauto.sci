function []=prtauto(results,lnp,output)
 
// PURPOSE: prints the results of automatic() along the
// options given by the user and stored in lnp
// ------------------------------------------------------------
// INPUT:
// * results = a tlist provided by automatic
// * lnp = the list of options provided by the user
// * output = the file where to print the results
// ------------------------------------------------------------
// OUTPUT:
// nothing, just print the results
// ------------------------------------------------------------
// NOTES: used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2011
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   output=%io(2)
end
 
// set default values
initial=%f
st0_mod=%f
st1_mod=%f
st1_union=%f
st2_mod=%f
st2_union=%f
final=%f
test_inter=%f
test_final=%f
st1_path=%f
st2_path=%f
 
if length(lnp) == 0 then
   final=%t
   test_final=%t
else
   txt_opt=strsubst(lnp,' ','')
   txt_opt=strsubst(txt_opt,'prt=','')
   txt_opt=strsubst(txt_opt,',',';')
// find the first and last index of each option in lnp
   ind1=[0 strindex(txt_opt,';')]+1
   ind2=[strindex(txt_opt,';') length(txt_opt)+1]-1
   for i=1:size(ind1,2)
      txt_aux=part(txt_opt,ind1(i):ind2(i))
      select txt_aux
      case 'all' then
         listmod=results(1)
         initial=%t
         st0_mod=%t
         if or(listmod == 'stage 1 models') then
            st1_mod=%t
            st1_path=%t
         end
         if or(listmod == 'stage 1 union model') then
            st1_union=%t
         end
         if or(listmod == 'stage 2 models') then
            st2_mod=%t
            st2_path=%t
         end
         if or(listmod == 'stage 2 union model') then
            st2_union=%t
         end
         test_inter=%t
         test_final=%t
 
      case 'nothing' then
         return
      case 'initial' then
         initial=%t
      case 'st0_mod' then
         st0_mod=%t
      case 'st1_mod' then
         st1_mod=%t
      case 'st1_union' then
         st1_union=%t
      case 'st2_mod' then
         st2_mod=%t
      case 'st2_union' then
         st2_union=%t
      case 'final' then
         final=%t
      case 'st1_path' then
         st1_path=%t
      case 'st2_path' then
         st2_path=%t
      case 'path' then
         st1_path=%t
         st2_path=%t
      case 'test_final' then
         test_final=%t
      case 'test_inter' then
         test_inter=%t
      case 'test' then
         test_final=%t
         test_inter=%t
      else
         error(txt_aux+' is not a automatic printable output')
      end
   end
end
 
chars=' __________________________________________________ '
write(output,chars)
write(output,'| results of the automatic regression package      |')
write(output,chars)
write(output,' ')
 
if or(results('ending reason') == ['final model is empty' ; 'stage 0 model is empty']) then
   write(output,results('ending reason')+'!')
   write(output,' ')
else
   if initial then
      prtauto_univ(results,'initial model',test_inter,output)
   end
 
   if st0_mod then
      prtauto_univ(results,'stage 0 model',test_inter,output)
   end
 
   if st1_mod then
      prtauto_multi(results,'stage 1 models',test_inter,st1_path,output)
   end
 
   if st1_union then
      prtauto_univ(results,'stage 1 union model',test_inter,output)
   end
 
   if st2_mod then
      prtauto_multi(results,'stage 2 models',test_inter,st2_path,output)
   end
 
   if st2_union then
      prtauto_univ(results,'stage 2 union model',test_inter,output)
   end
 
   if final then
      prtauto_univ(results,'final model',test_final,output)
   end
end
 
endfunction
