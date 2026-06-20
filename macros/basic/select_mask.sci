function [selected,index]=select_mask(str_vec,str_mask)

// PURPOSE: Find in a string vector the coordinates that
// match a mask
// ------------------------------------------------------------
// INPUT:
// * str_vec = a string vector
// * str_mask = a string, the mask to find
// ------------------------------------------------------------
// OUTPUT:
// * selected = the elements in the original vector which match
//   with the entered mask
// * index = the corresponding coordinates in the vector
// ------------------------------------------------------------
// Copyright Eric Dubois 2015-2023
// http://grocer.toolbox.free.fr/grocer.html


length_str_mask=length(str_mask)
sup=strindex(str_mask,'>')
star=strindex(str_mask,'*')
n_vec=size(str_vec,'*')
index=[]
if isempty(sup) & isempty(star) then
   selected=str_mask
   index=find(str_vec == str_mask)
   
else
   if ~isempty(sup) then
      sup=[0 , sup , length(str_mask)+1]
      nsup=size(sup,2)
      significant=emptystr(nsup-1,1)
      for j=1:size(sup,2)-1
         significant(j)=part(str_mask,sup(j)+1:sup(j+1)-1)
      end

      if isempty(significant(1)) then
         ind1_sup=%t
         start=2
      else
         ind1_sup=%f
         start=1
      end
   
      if isempty(significant($)) then
         ind$_sup=%t
         nsup=nsup-1
      else
         ind$_sup=%f
      end

      signif_start=significant(start)   
      signif_nsup=significant(nsup-1)
      length_signif_nsup=length(signif_nsup)
      for j=1:n_vec
         found=%f
         lj=str_vec(j)
         ind_1=[strindex(lj,significant(start)) 0] // I add 0 to encapsulate in the 
                                                // following conditions the case 
                                                // when the first string is not found
         if (ind1_sup & ind_1(1) > 1) | (~ind1_sup & ind_1(1) == 1) then
          // either the start is undefined and the first significant part
          // msut start at least at poistion 2
          // or the start is defined and must begin at the start of the string
            ind_signif=ind_1(1)
         
            ind_end=[length(lj)+1-length_signif_nsup strindex(lj,signif_nsup)]
            // I add length(lj)+1-length_signif_nsup to encapsulate in the 
            // following conditions the case 
            // when the string is not found
            dist_end=length(lj)-ind_end($)+1-length_signif_nsup
            if (ind$_sup & dist_end($) ~= 0) | (~ind$_sup & dist_end($)     == 0) then
               // either the end is undefined and the last significant part
               // msut start at most at position nvec-1
              // or the end is defined and must not end at the end of the string
               ind_signif=[ind_signif ; ind_end($)]
               found=%t
            
               for k=start+1:nsup-2
                  ind_k=strindex(lj,significant(k))
                  ind_k2=ind_k(ind_k > ind_signif($-1) & ind_k < ind_signif($))
                  if isempty(ind_k2) then 
                     found=%f
                  else
                     ind_signif=[ind_signif(1:$-1) ; ind_k2(1) ;ind_signif(1:$-1)] 
                  end
               end
            end
         end
         if found then
            index=[index ; j]
         end
      end
   end
 
   if ~isempty(star) then
   // just have to check if the strings other than '*' match
      ind=1:length(str_mask)
      ind(star)=[]
      str_maskcut=part(str_mask,ind)
      for j=1:n_vec
         lj=str_vec(j,1)
         if length(str_mask) == length(lj) then
            if part(lj,ind) == str_maskcut then
               index=[index ; j]
            end
         end
      end
   end
end

selected=str_vec(index)

endfunction
