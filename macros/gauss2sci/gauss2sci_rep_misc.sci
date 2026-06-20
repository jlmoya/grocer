function [statement,op,ind_statements]=gauss2sci_rep_misc(statement,type_statement,op,i_stat,ind_statements)
 
// PURPOSE: transform Gauss miscellaneous functions
// ------------------------------------------------------------
// INPUT:
// * statement = a (1 x K) vector, stemming from a gauss
//   statement sperated between string and non string
//   components
// * type_statement = a (1 x K) vector, indicating if the
//   corresponding statement component is a string or not
// * ind_length = a (1 x (K+1)) vector, starting with 0 and
//   then indicating the cumulated length of the statement
//   components
// ------------------------------------------------------------
// OUTPUT:
// * statk = the same statement but with Scilab
//   definitions for conditionals
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
stat1=statement(1)
[true_errorlog,ind_errorlog_def,stat1]=findobject(stat1,'errorlog',[' '],' ',%f)
if true_errorlog then
   statement(1)=strsubst(stat1,'errorlog','disp(')
   op=shift_op(op,ind_nonempty,ind_errorlog_def,-3)
   statement($)=part(statement($),1:length(statement($))-1)+');'
   ind_statements(ind_statements == i_stat)=[]
end
 
for i=1:size(statement,2)
   if type_statement(i) == 'nostring' then
      statk=statement(i)
      [statk,true_call]=strsubst_trueobj(statk,'call','',' ',' ',%f,%f)
      [statk,true_pause]=strsubst_trueobj(statk,'pause(','pause(1000*',' ',[],%f,%f)
      statement(i)=statk
      if or([true_call true_pause strindex(statk,'error(0)')]) then
         ind_statements(ind_statements == i_stat)=[]
      end
      statk=strsubst(statk,'error(0)','%nan')
   end
end
 
true_delete=findobject(stat1,'delete',[' '],[' ' '('],%f)
true_drop=findobject(stat1,'drop',[' '],[' ' '('],%f)
true_eqSolveset=findobject(stat1,'eqsolveset',[' '],[' ' ';'],%f)
true_gosub=findobject(stat1,'gosub',[' '],[' '],%f)
true_lib=findobject(stat1,'lib',[' '],[' '],%f)
true_loopnextindex=findobject(stat1,'loopnextindex ',[' '],[' '],%f)
true_msym=findobject(stat1,'msym',[' '],[' '],%f)
true_new=findobject(stat1,'new',[' '],[' '],%f)
true_pop=findobject(stat1,'pop',[' '],[' '],%f)
true_printdos=findobject(stat1,'printdos',[' '],[' '],%f)
true_recode=findobject(stat1,'recode',[' '],[' '],%f)
true_run=findobject(stat1,'run',[' '],[' '],%f)
true_setarray=findobject(stat1,'setarray',[' '],[' '],%f)
true_shell=findobject(stat1,'shell',[' '],[' '],%f)
true_show=findobject(stat1,'show',[' '],[' '],%f)
true_sqpSolveSet=findobject(stat1,'sqpsolveset',[' '],[' ' ';'],%f)
true_ThreadBegin=findobject(stat1,'threadbegin',[' '],[' ' ';'],%f)
true_ThreadEnd=findobject(stat1,'threadend',[' '],[' ' ';'],%f)
true_ThreadJoin=findobject(stat1,'threadjoin',[' '],[' ' ';'],%f)
true_ThreadStat=findobject(stat1,'threadstat',[' '],[' ' ';'],%f)
true_trap=findobject(stat1,'trap',[' '],[' ' ],%f)
true_vector=findobject(stat1,'vector',[' '],[' ' ],%f)
 
true_misc=[true_delete;true_drop;true_eqSolveset;true_gosub;...
true_lib;true_loopnextindex;true_msym;true_new;true_pop;...
true_printdos;true_recode;true_run;true_setarray;true_shell;...
true_show;true_sqpSolveSet;true_ThreadBegin;true_ThreadEnd;...
true_ThreadJoin;true_ThreadStat;true_trap;true_vector]
 
if or(true_misc) then
   ind_statements(ind_statements == i_stat)=[]
end
 
 
endfunction
 
