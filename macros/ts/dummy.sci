function dum=dummy(boun,subperiod)
 
// PURPOSE: create a dummy variable equal to 1 over a
// sub-period, 0 over the rest of the period
// ------------------------------------------------------------
// INPUT:
// * boun = a (2x1) string vector of dates
// * subperiod =
//  - either a string scalar if the dummy is relative to the
//    lone date subperiod
//  - or a (2 x1) string vector if the dummy is relative to the
//    period subperiod(1) to subperiod(2)
// ------------------------------------------------------------
// OUTPUT:
// * dum = a ts equal to 1 for the period subperiod,
//                         O otherwise
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[dat1,fq]=date2num_fq(boun(1))
[dat$]=date2num_fq(boun($))
nvalues=dat$-dat1+1
vect=zeros(nvalues,1)
 
subp1=date2num(subperiod(1))
nsp=size(vec2col(subperiod),1)
diffper1=subp1-dat1+1
 
select nsp
 
case 1 then
   diffper2=diffper1
 
case 2 then
   diffper2=date2num(subperiod(2))-dat1+1
 
else
   error(string(nsp)+': not a suitable size for arg 2 (should be 1 or 2)')
end
 
vect(diffper1:diffper2)=1
 
dum=tlist(['ts';'freq';'dates';'series'],fq,[dat1:dat$]',vect)
 
endfunction
