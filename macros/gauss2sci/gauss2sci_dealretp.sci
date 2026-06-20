function [gauss2sci_matout,gauss2sci_listnewstat]=gauss2sci_dealretp(vi,ind_retp,noutput)
 
// PURPOSE: replace the Gauss definition of the function
// with its Scilab equivalent
// ------------------------------------------------------------
// INPUT:
// * vi = a matrix of statements, containing the keyword 'retp'
// * ind_retp = the indexes of the string 'retp' in vi
// * noutput = the # of outputs stemming from the proc
//   statement
// ------------------------------------------------------------
// OUTPUT:
// * gauss2sci_matout = a (noutput x 1) vector of outputs
// * gauss2sci_listnewstat = the list of instructions replacing
//   the retp instructions with commands defining the output
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
gauss2sci_matout=[]
gauss2sci_listnewstat=[]
 
if isempty(ind_retp) then
   if noutput ~= 0 & ~isnan(noutput) then
      error('your gauss progamm has '+string(noutput)+' outputs, but does not contain the keyword ''retp''')
   end
   return
end
 
 
ind_leftpar=strindex(vi(1),'(')
ind_rightpar=strindex(vi(1),')')
// take the interior of retp
vi_aux=part(vi(1),ind_leftpar(1)+1:ind_rightpar($)-1)
nretp=size(ind_retp,1)
gauss2sci_listnewstat=emptystr(nretp,1)
 
 
if nretp > 1 then
 
   nargs=0
   for j=1:nretp
      vi_j=vi(j)
      ind_leftpar=strindex(vi_j,'(')
      ind_rightpar=strindex(vi_j,')')
      vi_aux=part(vi_j,ind_leftpar(1)+1:ind_rightpar($)-1)
      list_arg=extract_arg(vi_aux,',',['(';'['],[')';']'],''"')
      nargs_j=size(list_arg,'*')
      nargs=max(nargs,nargs_j)
      gauss2sci_listnewstat(j)=gauss2sci_listnewstat(j)+joinstr('gauss2sci_output',string(1:nargs_j),'=',list_arg,';')+';return;'
   end
 
   gauss2sci_matout=[gauss2sci_matout ; 'gauss2sci_output'+string([1:nargs]')]
 
else
// there is only one retp
// find the end of the command by searching the opening and ending parenthesis
 
   list_arg=extract_arg(vi_aux,',',['(';'['],[')';']'],''"')
   nargs=size(list_arg,'*')
 
   for i=1:size(list_arg,'*')
      outputi=list_arg(i)
      if isempty([strindex(outputi,'(') strindex(outputi,'[') strindex(outputi,'+') strindex(outputi,'=')  ...
         strindex(outputi,'-') strindex(outputi,'*') strindex(outputi,'/') strindex(outputi,'^') ...
         strindex(outputi,'''') strindex(outputi,'<') strindex(outputi,'>') strindex(outputi,'=')] ) then
         gauss2sci_matout=[gauss2sci_matout ; outputi]
      else
         execstr('gauss2sci_output'+string(i)+'='''+strsubst(outputi,'''','''''')+'''')
         gauss2sci_matout=[gauss2sci_matout ; 'gauss2sci_output'+string(i)]
         gauss2sci_listnewstat=gauss2sci_listnewstat+'gauss2sci_output'+string(i)+'='+outputi+';'
      end
   end
end
 
endfunction
