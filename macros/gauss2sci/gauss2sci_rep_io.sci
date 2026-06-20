function [stat,ind_statements]=gauss2sci_rep_io(stat,i_stat,ind_statements)
 
// PURPOSE: transform Gauss I/O keywords or functions into their
// Scilab or Grocer equivalent
// ------------------------------------------------------------
// INPUT:
// * txt = a string
// ------------------------------------------------------------
// OUTPUT:
// * txt= the transformed string
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
stat=strsubst_trueobj(stat,'fopen','mopen',[' ';'='],[' ';'('],%f,%f)
 
true_create=findobject(convstr(stat1),'create',[' '],[' ' '('],%f)
true_datalist=findobject(convstr(stat1),'datalist',[' '],[' ' '('],%f)
true_dataloop=findobject(convstr(stat1),'dataloop',[' '],[' ' '('],%f)
true_extern=findobject(convstr(stat1),'extern',[' '],[' '],%f)
true_external=findobject(convstr(stat1),'external',[' '],[' '],%f)
true_intrleav=findobject(convstr(stat1),'intrleav',[' '],[' ' '('],%f)
true_keep=findobject(convstr(stat1),'keep',[' '],[' '],%f)
true_keyword=findobject(convstr(stat1),'keyword',[' '],[' '],%f)
true_make=findobject(convstr(stat1),'make',[' '],[' '],%f)
true_makevars=findobject(convstr(stat1),'makevars',[' '],[' ' '('],%f)
true_outtyp=findobject(convstr(stat1),'outtyp',[' '],[' ' '('],%f)
true_outwidth=findobject(convstr(stat1),'width',[' '],[' ' '('],%f)
true_saveall=findobject(convstr(stat1),'saveall',[' '],[' ' '('],%f)
true_screen=findobject(convstr(stat1),'screen',[' '],[' ' '('],%f)
true_select=findobject(convstr(stat1),'select',[' '],[' ' ],%f)
true_vlist=findobject(convstr(stat1),'vlist',[' '],[' ' '('],%f)
 
true_io=[true_create;true_datalist;true_dataloop;true_extern;...
true_external;true_intrleav;true_keep;true_keyword;true_make;....
true_makevars;true_outtyp;true_outwidth;true_saveall;true_screen;...
true_select;true_vlist]
 
if or(true_io) then
   ind_statements(ind_statements == i_stat)=[]
end
 
endfunction
 
