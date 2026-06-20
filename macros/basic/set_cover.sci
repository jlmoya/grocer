function pivots=set_cover(variables,list_varipereq)
 
// PURPOSE: in a set of N equations, find a one-to-one from a
// set of N variables to a set of N equations, with each of the
// N variables being present in the associated equation
// ------------------------------------------------------------
// INPUT:
// * variables = a vector of N variables names
// * list_varipereq = a list of N elements, ecah one gathering
//   the names of the variables present in the i-th equation
// ------------------------------------------------------------
// OUTPUT:
// * pivots = the vector of original N variables, reordered so
//   that the i-th variable appears in the i-th equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015-2019
// http://grocer.toolbox.free.fr/grocer.html
 
nvari=size(variables,'*')
pivots=zeros(nvari,1)
ind_varipereq=zeros(nvari,1)
ordered=1:nvari
// nosol will be set to %f if there is no solution
nosol=%f
 
j=0
while or(pivots ==0) & j< nvari & ~nosol
   j=j+1
   i=ordered(j)
   ind_varipereq(i)=ind_varipereq(i)+1
   list_varipereq_i=list_varipereq(i)
 
   if ind_varipereq(i) > size(list_varipereq_i,'*')
   // there is no variable left in the i-th equation
   // that can be associated to the equation
      if i == 1 then
      // this means that all paths have been explored
      // there is therefore no solution
         nosol=%t
         pivots=[]
      else
      // this means that the path corresponding to the
      // choices made until i-1 is not valid
      // put the endogenous at the top of the list
         ordered=[i , ordered(1:j-1) , ordered(j+1:nvari)]
         j=0
         ind_varipereq=zeros(nvari,1)
         pivots=zeros(nvari,1)
      end
   else
      // try with the next variable in the list of variables
      pivots(i)=list_varipereq(i)(ind_varipereq(i))
      if or(pivots(ordered(1:j-1)) == pivots(i)) then
      // it has already been used, so remove it and remove 1
      // unit to i, so that at the next execution of the loop
      // the program goes back to the current i and tries the
      // next variable in the list
         pivots(i)=0
         j=j-1
      end
   end
 
end
 
if nosol then
   warning('no solution found: output set to the empty matrix')
end
pivots=pivots(ordered)
 
endfunction
