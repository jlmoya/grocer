function [statements,type_statements]=gauss2sci_comp_print(statements,ind_statements,type_statements)
    
ind_pot=0
n_pot=size(ind_statements,'*')
while ind_pot < n_pot
   ind_pot=ind_pot+1
   i_stat=ind_statements(ind_pot)
   statement=statements(i_stat)
   stat1=statement(1)
   statshort=strsubst(strsubst(strsubst(statement,' ',''),ascii(9),''),ascii(32),'')
   if statement == ';' & i_stat > 1 then
      stat_m1=statements(i_stat-1)
      end_stat_m1=stat_m1($)
      if part(stat_m1($),length(end_stat_m1)+[-1:0]) == ');' then
         stat_m1($)=part(stat_m1($),1:length(end_stat_m1)-2)+',... '
         stat_p1=statement(i_stat+1)
         type_stat_p1=type_statements(i_stat+1)
         ind_nos=find(type_stat_p1 == 'nostring')

         if ind_nos(1) == 1 then
         // next statement does not start with a string
            stat_m1($)=stat_m1($)+stat_p1(1)
            statements(i_stat-1)=[stat_m1 , stat_p1(2:$)]
            type_statement(i_stat-1)=[type_statement(i_stat-1), ...
                                     type_stat_p1(2:$)]
         else
            statements(i_stat-1)=[stat_m1 , stat_p1]
            type_statement(i_stat-1)=[type_statement(i_stat-1), ...
                                     type_stat_p1]
         end

         ind_statements(ind_statements == i_stat)=[]
         n_pot=size(ind_statements,'*')
      end
 
    elseif statshort == ';' then
       statements(i_stat)=strsubst(statement,';','')

    elseif ~isempty(statshort) then
      indeq=[]
      ind_prt=[]
      for j=1:size(statement,2)
         indeq=[indeq strindex(statement(j),'=')]
         ind_prt=[ind_prt strindex(statement(j),'print_gauss')]
      end
      [true_proc]=findobject(stat1,'proc ',[' ' ],[],%f)
      [true_else]=findobject(stat1,'else',[' ' ],[' ', ';'],%f)
      [true_if]=findobject(stat1,'if',[' ' ],[' '],%f)
      [true_while]=findobject(stat1,'while',[' ' ],[' '],%f)

      if isempty(indeq) & isempty(ind_prt) & ~true_proc & ~true_else ...
          & ~true_if & ~true_while then
      // this a gauss printing
         stat1=statement(1)
         ind_nos=find(type_statements(i_stat) == 'nostring')
         if ind_nos(1) == 1 then
            indb=strindex(stat1,' ')
            if isempty(indb) then
               statement(1)='print_gauss('+stat1
               statement($)=part(statement($),1:length(statement($))-1)+');'
            else
               v=1:size(indb,2)
               first_nonb=find(indb-v >0)
               if isempty(first_nonb) then
                  statement(1)=stat1+'print_gauss('
               elseif first_nonb(1) == 1 then
                  statement(1)='print_gauss('+stat1
               else
                  statement(1)=part(stat1,1:indb(first_nonb(1)-1))+'print_gauss('+...
                               part(stat1,indb(first_nonb(1)-1):length(stat1))
               end
               statement($)=part(statement($),1:length(statement($))-1)+');'
            end

         else
            statement($)=part(statement($),1:length(statement($))-1)+');'
            statement=['print_gauss(' statement]
            type_statements(i_stat)=['nostring' type_statements(i_stat)]
         end
         statements(i_stat)=statement
      end
   end
end

endfunction