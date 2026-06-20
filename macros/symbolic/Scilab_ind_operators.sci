function [op,ind_fuspar,ind_fusbrack,ind_nonempty]=Scilab_ind_operators(equation)
 
// PURPOSE: store in a tlist the indexes of selected operators
// of an equation that can be run under Scilab
// ------------------------------------------------------------
// INPUT:
// * equation = a equation dissected between string and non
//   string components
// ------------------------------------------------------------
// OUTPUT:
// * op = a tlist with each field corresponding to an operator
//   op(i) = a (4 x p) matrix:
//   - first line: the positions of the operator
//   - second line: the equation number where the operator
//     appears
//   - third line: the position of the operator end
//   - fourth line: the precedence of the operator, derived by
//     myself
// * ind_nonempty = vector of non empty operator fields
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
[ind_leftpar,ind_rightpar,ind_fuspar]=sci_find_parenth(equation,['(';')'],11)
[ind_leftbrack,ind_rightbrack,ind_fusbrack]=sci_find_parenth(equation,['[';']'],12)
 
ind_power=sci_find_simple(equation,'.^',85)
ind_hat=sci_find_simple(equation,'^',85)
ind_matmul=sci_find_simple(equation,'.*',80)
ind_star=sci_find_simple(equation,'*',80)
ind_matdiv=sci_find_simple(equation,'./',80)
ind_slash=sci_find_simple(equation,'/',80)
ind_plus=sci_find_simple(equation,'+',70)
ind_minus=sci_find_simple(equation,'-',70)
ind_equal=sci_find_simple(equation,'=',10)
 
ind_comma=sci_find_simple(equation,',',11)
 
for i=1:size(ind_matmul,2)
   ind_star(:,ind_star(1,:) == ind_matmul(1,i)+1)=[]
end
 
for i=1:size(ind_matdiv,2)
   ind_slash(:,ind_slash(1,:) == ind_matdiv(1,i)+1)=[]
end
 
for i=1:size(ind_power,2)
   ind_hat(:,ind_hat(1,:) == ind_power(1,i)+1)=[]
end
 
ind_unary=[]
for i=size(ind_minus,2):-1:1
  if isempty(stripblanks(part(equation,1:ind_minus(1,i)- 1))) then
     ind_unary=[ind_minus(:,i) ind_unary]
     ind_minus(:,i)=[]
   else
      stat_start=stripblanks(part(strcat(equation,' '),1:ind_minus(1,i)-1))
      length_start=length(stat_start)
      char_before_minus=part(stat_start,length_start)
      char_3before_minus=part(stat_start,max(1,length_start-2):length_start)
      char_4before_minus=part(stat_start,max(1,length_start-3):length_start)
      if or(char_before_minus == [ '[' ; '*' ; '~' ; ',' ; ';' ; '/' ;'+' ; ...
          '=' ; '<' ; '>' ; '.' ; ':' ; '(' ; '%' ; '^']) then
         ind_unary=[ind_minus(:,i) ind_unary]
         ind_minus(:,i)=[]
      end
   end
end
 
op=tlist(['op';'power';'hat';'unary';'star';'matmul';'slash';...
'matdiv';'plus';'minus';'equal';'comma';'all'],...
ind_power,ind_hat,ind_unary,ind_star,ind_matmul,ind_slash,...
ind_matdiv,ind_plus,ind_minus,ind_equal,ind_comma)
 
ind_all=[]
for i=2:length(op)-2
   ind_all=[ind_all op(i) ]
end
 
[junk,ind]=gsort(ind_all(1,:),'g','i')
ind_all=ind_all(:,ind)
op('all')=ind_all
 
endfunction
