function txt=explode_log(txt)
 
// PURPOSE: in a txt transform the log of products or divisions
// into the sum of the corresponding logs
// ------------------------------------------------------------
// INPUT:
// * txt = a string
// ------------------------------------------------------------
// OUTPUT:
// * txt = the same string with logs transformed as indicated
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
ind_log=find_log(txt)
[leftpar,rightpar,fuspar]=sci_find_parenth_mod(txt)
 
for i=size(ind_log,2):-1:1
   ind_fus_log=find(fuspar(1,:) > ind_log(i) )
   fus_log=fuspar(:,ind_fus_log)
   end_fus_log=find(fus_log(4,:) == fus_log(4,1)-1)
   txt_log=part(txt,ind_log(i)+4:fus_log(1,end_fus_log(1))-1)
   end_txt=part(txt,ind_log(i)+5+length(txt_log):length(txt))
   fus_log=fus_log(:,2:end_fus_log(1)-1)
 
   if ~isempty(fus_log) then
      fus_log(1,:)=fus_log(1,:)-ind_log(i)-3
      fus_log(4,:)=fus_log(4,:)-1
   end
   // remove useless parentheses
   simplified=isempty(fus_log)
   while ~simplified
      if isempty(fus_log) then
         simplified=%t
      elseif fus_log(1,1) ~= 1 | fus_log(1,$) ~= length(txt_log) then
         simplified=%t
      elseif or(find(fus_log(4,:) == fus_log(4,1)-1) < size(fus_log,2)) then
         simplified=%t
      else
         txt_log=part(txt_log,2:length(txt_log)-1)
         fus_log(4,:)=fus_log(4,:)-1
         fus_log(1,:)=fus_log(1,:)-1
         fus_log=fus_log(:,2:$-1)
      end
   end
 
   ind_plus=sci_find_plus_minus(txt_log,'+',70)
   ind_minus=sci_find_plus_minus(txt_log,'-',70)
   ind_op=gsort([ ind_plus(1,:) , ind_minus(1,:)],'g','i')
 
   ind_star=strindex(txt_log,'*')
   ind_slash=strindex(txt_log,'/')
   ind_starslash=gsort([ind_star ind_slash],'g','i')
 
   if ~isempty(fus_log) & ~isempty(ind_starslash) then
      ind_firstpar=fus_log(4,1)
      find_openingpar=find(fus_log(4,:) == ind_firstpar & fus_log(2,:) == 1)
      find_closingpar=find(fus_log(4,:) == ind_firstpar-1 & fus_log(2,:) == -1)
      for j=1:size(find_openingpar,2)
         ind_op(ind_op > fus_log(1,find_openingpar(j)) & ind_op < fus_log(1,find_closingpar(j)))=[]
         ind_starslash(ind_starslash > fus_log(1,find_openingpar(j)) & ind_starslash < fus_log(1,find_closingpar(j)))=[]
      end
   end
 
   if isempty(ind_op) & ~isempty(ind_starslash) then
      ind_starslash=[0 ind_starslash length(txt_log)+1]
      n_starslash=size(ind_starslash,2)-2
      newtxt=emptystr(n_starslash+1,1)
      indsign=emptystr(n_starslash+1,1)
      newtxt(1)='log('+part(txt_log,ind_starslash(1)+1:ind_starslash(2)-1)+')'
      indsign(1)='1'
 
      for j=2:n_starslash+1
         newtxt(j)='log('+part(txt_log,ind_starslash(j)+1:ind_starslash(j+1)-1)+')'
         if or(ind_starslash(j) == ind_star) then
            indsign(j)='1'
         else
            indsign(j)='-1'
         end
      end
 
      if ind_log(i) == 1 then
         indsign(indsign == '1')='+'
         indsign(indsign == '-1')='-'
         txt=newtxt(1)+strcat(indsign(2:$)+newtxt(2:$))+end_txt
 
      elseif part(txt,ind_log(i)-1) == '('
         indsign(indsign == '1')='+'
         indsign(indsign == '-1')='-'
         txt=part(txt,1:ind_log(i)-1)+strcat(indsign+newtxt)+end_txt
 
      elseif part(txt,ind_log(i)-1) == '+' then
         indsign(indsign == '1')='+'
         indsign(indsign == '-1')='-'
         txt=part(txt,1:ind_log(i)-2)+strcat(indsign+newtxt)+end_txt
 
      elseif part(txt,ind_log(i)-1) == '-' then
         indsign(indsign == '1')='-'
         indsign(indsign == '-1')='+'
         txt=part(txt,1:ind_log(i)-2)+strcat(indsign+newtxt)+end_txt
 
      else
         indsign(indsign == '1')='+'
         indsign(indsign == '-1')='-'
         txt=part(txt,1:ind_log(i)-1)+'('+strcat(indsign+newtxt)+')'+end_txt
      end
   end
end
 
endfunction
