function tsmat=%tsmat_e(r,c,tsmat)
 
// PURPOSE: Extract the specified row and column of a tsmtat
// the overloading capability of scilab allows then one to write
// tsmat(r,c) to extract the r-th tow and c-th column of a tsmat
// ------------------------------------------------------------
// INPUT:
// * tsmat= a tlist of type tsmat
// * r = a vector of indexes or the name of a variable in the
//   tsmat
// *c = a vector
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat or ts
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
 
st=tsmat('series')
namest=tsmat('names')
datest=tsmat('dates')
if or(typeof(r) == ['constant' ; 'implicitlist']) then
   // standard interpetation of an extraction: tsmat=tsmat(row,col)
   tsmat('series')=st(r,c)
   tsmat('names')=namest(c)
   tsmat('dates')=datest(r)
 
elseif typeof(r) == 'string' then
    // non standard interpretation of an extraction: ts=tsmat(name_ts,bounds)
   ind_nam=find(namest == r)
   select typeof(c)
 
   case 'string' then
      nd=size(c,'*')
      [dat1,fq]=date2num_fq(c(1))
      if fq ~= tsmat('freq') then
         error(c(1)+' has not the same frequency as tsmat frequency')
      end
      [dat2,fq]=date2num_fq(c(2))
      if fq ~= tsmat('freq') then
          error(c(2)+' has not the same frequency as tsmat frequency')
      end
      ind=[dat1:dat2]-datest(1)+1
      tsmat=tlist(['ts';'freq';'dates';'series'],tsmat('freq'),datest(ind),st(ind,ind_nam))
 
   else
      tsmat=tlist(['ts';'freq';'dates';'series'],tsmat('freq'),datest,st(:,ind_nam))
   end
end
 
endfunction
