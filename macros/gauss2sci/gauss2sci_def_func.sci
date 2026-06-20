function [statements,namefunc,state_start,state_end,commentsf]=gauss2sci_def_func(statements,state_start,state_end,commentsf)
 
// PURPOSE: replace the Gauss definition of the function
// with its Scilab equivalent
// ------------------------------------------------------------
// INPUT:
// * statements = a list of statements
// * state_start = a (N x 2) matrix contaning the # of the
//   line and column where a statement starts
// ------------------------------------------------------------
// OUTPUT:
// * statements = a list of transformed statements, with the
//   lines containing 'retp', 'proc' replaced
// * namefunc = the name of the function
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
vretp=[]
ind_retp=[]
line_retp=[]
for j=1:length(statements)
   statements_j=statements(j)
   if size(statements_j,2) == 1 then
      [true_retp,ind,vi]=findobject(statements_j,'retp',[' ' ; ';'],['('],%t)
      if true_retp then
         line_retp=[line_retp ; j]
         ind_retp=[ind_retp ; ind]
         vretp=[vretp ; vi]
      end
   end
end
vproc=statements(1)
 
 
ind_proc=strindex(vproc,'proc')
ind_semicol=strindex(vproc,';')
lproc_equal=strindex(vproc,'=')
lproc_equal=lproc_equal(lproc_equal>ind_proc)
 
lproc_rightpar=strindex(vproc,')')
lproc_rightpar=lproc_rightpar(lproc_rightpar>ind_proc)
 
lproc_leftpar=strindex(vproc,'(')
lproc_leftpar=lproc_leftpar(lproc_leftpar>ind_proc)
// now find the name of the function: this should be beteween
// the first '=' and the second '('
 
if isempty(lproc_equal) then
   if isempty(lproc_leftpar) then
      namefunc=strsubst(part(vproc,ind_proc+5:ind_semicol(1)-1),' ','')
   else
      namefunc=strsubst(part(vproc,ind_proc+5:lproc_leftpar(1)-1),' ','')
   end
   noutput=%nan
   end_def='='+part(vproc,ind_proc+5:length(vproc))
 
else
   end_str=part(vproc,lproc_equal(1)+1:length(vproc))
   lproc_leftpar2=strindex(end_str,'(')
   if isempty(lproc_leftpar2) then
      namefunc=strsubst(part(end_str,1:ind_semicol(1)-lproc_equal(1)-1),' ','')
   else
      namefunc=strsubst(part(end_str,1:lproc_leftpar2(1)-1),' ','')
   end
 
   execstr('noutput='+part(vproc,ind_proc+4:lproc_rightpar(1)))
   end_def=part(vproc,lproc_rightpar(1)+1:length(vproc))...
   +part(vproc,ind_semicol(1)+1:length(vproc))
end
// noutput is the char between the left and right parentheses after
// the keyword 'proc'
// retrieve the names of the output variables and the commands
// defining the output not directly defined as an existing variable
[gauss2sci_matout,gauss2sci_listnewstat]=gauss2sci_dealretp(vretp,ind_retp,noutput)
 
// change the lines containing 'retp': the line should be either empty (all
// ouput have the form of a varaible) or contain the expressions needed to
// build the output variables
if ~isempty(ind_retp) then
   if ~isempty(gauss2sci_listnewstat) then
      for i=1:size(ind_retp,1)
         statements(line_retp(i))=gauss2sci_listnewstat(i)
      end
   else
      statements(line_retp)=emptystr()
   end
end
 
// change the definition of the function
statements=lstcat(part(vproc,1:ind_proc-1)+'function ['+strcat(gauss2sci_matout,',')...
+']'+end_def , ' ' , 'grocer_ieee=ieee();' , 'ieee(2);' ,' ' , statements(2:$))
state_start=[ state_start(1,:) ; [state_end(1)+[1:4]' ones(4,1)] ;  state_start(2:$,1)+4 state_start(2:$,2)]
if state_end(1) == 1 then
   state_end=[1 length(statements(1)) ;state_end(1)+1 2;state_end(1)+2 19;state_end(1)+3 8; state_end(1)+4  2; state_end(2:$,1)+4 state_end(2:$,2)]
else
// if the proc definition takes several lines, then the last line is
// unchanged and the already defined state_end(1,:) still applies
   state_end=[state_end(1,:) ;state_end(1)+1 2;state_end(1)+2 19;state_end(1)+3 8; state_end(1)+4  2; state_end(2:$,1)+4 state_end(2:$,2)]
end
commentsf=[commentsf(1) ; emptystr(4,1) ; commentsf(2:$)]
 
 
endfunction
