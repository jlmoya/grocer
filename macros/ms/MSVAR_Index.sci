function [n_sort,bench] = MSVAR_Index(y,apriori,M);
 
// PURPOSE: extract a submatrix of ending index, starting from
// a sorted benchmark coded 1 to M
// ------------------------------------------------------------
// INPUT:
// * y = a (T x k) matrix
// * apriori = a scalar:
//   - 0 if there is no a priori datation
//   - 1 if there is an a priori datation
//   - 1 if there is an a priori datation
// * M =# of states
// ------------------------------------------------------------
// OUTPUT:
// * n_sort = a (Mx1) vector of end points for the datation
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
											
n_sort=zeros(M,1);
 
if apriori == 1 then; 				
// There is an apriori reference datation available _ref_date */
 
   bench=grocer_MS_refdate  // global variable, reference datation, caution : should be a M states 1...M coded series, see ref_date.xls */
   N=rows(bench);
   bench_sort=sortc(bench,1);
   j=1;
 
   // Caution, the first index correspond to the first ending index in order to be treated as n(i+1,.]: n[i,.] */
 
   for i =1:N-1;
 
      if (bench_sort(i,1) ~= bench_sort(i+1,1)) then
      //(bench_sort(i,1)./=bench_sort(i+1,1))
         n_sort(j,1)= i;
         j=j+1;
      end;
 
   end;
 
   n_sort(j,1)=N;
   if j>M then ;
     error("Error in MSVAR_index");
   end;
   //add an error message if j >M
 
else
//apriori==0, no apriori reference datation
 
   bench=y(:,1);   //assumption : with no information, the first series is used as datation reference
   N=rows(bench);
   for j =1:M;
      n_sort(j,1)=floor((N*j)/M);    //n1..nM, vector of ending stop points
   end
 
end;
 
 
endfunction
