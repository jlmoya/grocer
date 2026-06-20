function [statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end,add_stat,ind_statements]=gauss2sci_rep_simple(statement,statements,type_statements,i_stat,state_start,state_end,comment_startf,comment_endf,ind_statements)
 
// PURPOSE: Make substitutions of simple commands: end; endp;
// ...
// ------------------------------------------------------------
// INPUT:
// * statement = a gauss statement
// ------------------------------------------------------------
// OUTPUT:
// * statement = the same statement but with simple commands
//   transformed
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
stat=part(statement(1),1:length(statement(1))-1)
add_stat=0
 
select strsubst(stat,' ','')
 
case 'end' then
   statements(i_stat)=strsubst(stat,'end','return')
   ind_statements(ind_statements == i_stat)=[]
 
case 'endif' then
   statements(i_stat)=strsubst(stat,'endif','end')
   ind_statements(ind_statements == i_stat)=[]
 
case 'endo' then
   statements(i_stat)=strsubst(stat,'endo','end')
   ind_statements(ind_statements == i_stat)=[]
 
case 'endfor' then
   statements(i_stat)=strsubst(stat,'endfor','end')
   ind_statements(ind_statements == i_stat)=[]
 
case 'endwhile' then
   statements(i_stat)=strsubst(stat,'endwhile','end')
   ind_statements(ind_statements == i_stat)=[]
 
case 'endp' then
   stat=strsubst(stat,'endp','endfunction')
   statements=lstcat(statements(1:i_stat-1) , ' ' , 'ieee(grocer_ieee);' , ' ' , stat , statements(i_stat+1:$))
   type_statements=lstcat(type_statements(1:i_stat-1) , 'nostring' , 'nostring' , 'nostring', statements(i_stat:$))
   if ~isempty(state_end(i_stat+1:$,1)) then
      state_start=[state_start(1:i_stat-1,:) ;  [state_start(i_stat,1)+[0:2]' ones(3,1)] ; ...
                 state_start(i_stat,1)+3 state_start(i_stat,2) ; state_start(i_stat+1:$,1)+3 state_start(i_stat:$,2) ]
      state_end=[state_end(1:i_stat-1,:) ;  [state_end(i_stat,1)+[0:2]' [2;18;2]]; ...
                 state_end(i_stat,1)+3 state_end(i_stat,2)+7 ;state_end(i_stat+1:$,1)+3 state_end(i_stat:$,2) ]
   else
      state_start=[state_start(1:i_stat-1,:) ;  [state_start(i_stat,1)+[0:2]' ones(3,1)] ; ...
                 state_start(i_stat,1)+3 state_start(i_stat,2) ]
      state_end=[state_end(1:i_stat-1,:) ;  [state_end(i_stat,1)+[0:2]' [2;18;2]]; ...
                 state_end(i_stat,1)+3 state_end(i_stat,2)+7 ]
   end
   commentsf=[commentsf(1:state_start(i_stat,1)-1) ; emptystr(3,1) ; commentsf(state_start(i_stat,1):$)]
   add_stat=add_stat+3
   ind_statements(ind_statements == i_stat)=[]
 
 
case 'ndpclex' then
   statements(i_stat)='//ndpclex;'
   ind_statements(ind_statements == i_stat)=[]
 
case 'print' then
   statements(i_stat)=strsubst(statements(i_stat),'print','print_gauss('" '")')
   ind_statements(ind_statements == i_stat)=[]
 
case 'stop' then
   statements(i_stat)=strsubst(statements(i_stat),'stop','return')
   ind_statements(ind_statements == i_stat)=[]
 
case 'wait' then
   statements(i_stat)=strsubst(statements(i_stat),'wait','pause')
   ind_statements(ind_statements == i_stat)=[]
 
else
 
   [true_con,ind_con_def,statk]=findobject(stat,'con',[' ' ; '='],['(' ' '],%t)
   [true_cons,ind_cons_def,statk]=findobject(stat,'cons',[' ' ; '='],[';' ' '],%t)
 
   if true_cons then
      ind=1
      indeq=strindex(stat,'=')
      while part(stat,ind) == ' ' then
         ind=ind+1
      end
      statements(i_stat)=part(stat,1:ind-1)+'[ok,'+part(stat,ind:indeq-1)+']=getvalue('"'",'"'",list('"str'",1),emptystr())'
      ind_statements(ind_statements == i_stat)=[]
 
   elseif true_con then
      ind=1
      indeq=strindex(stat,'=')
      ind_lef
      while part(stat,ind) == ' ' then
         ind=ind+1
      end
      fuspar=op('fuspar')
      statements(i_stat)=part(stat,1:ind-1)+'[ok,'+part(stat,ind:indeq-1)+']=getvalue('"'",'"'",list('"mat'",['+...
                         part(stat,fuspar(1,1)+1:fuspar(1,$)-1)+'],emptystr())'
         ind_statements(ind_statements == i_stat)=[]
 
   elseif part(stripblanks(stat),1:4) =='goto' then
      comment_warn='// !! statement: '"'+stat+''" has not been translated'
      statements(i_stat)='// not translated: '+strcat(statement)
      ind_statements(ind_statements == i_stat)=[]
 
   else
      statements(i_stat)=stat
   end
 
end
 
endfunction
