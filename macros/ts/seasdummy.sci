function dum=seasdummy(boun,subperiod)
 
// PURPOSE: transform a date in numerical presentation into
// its string format
// ------------------------------------------------------------
// INPUT:
// * boun = a (2x1) string vector of dates
// * subperiod = a scalar corresponding the yearly period when
//  the dummy variables is set to 1 (for instance 3 for a
//  march-june-september-december dummy with monthly data)
// ------------------------------------------------------------
// OUTPUT:
// * dummy = a ts equal to 1 for the chosen season
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[dat1,fq]=date2num_fq(boun(1))
[dat$]=date2num_fq(boun($))
nvalues=dat$-dat1+1
vect=zeros(nvalues,1)
per1=dat1-floor((dat1-1)/fq(1))*fq(1)
 
diffper=subperiod-per1
if diffper >= 0 then
   vect(diffper+1+fq(1)*[0:floor((nvalues-diffper-1)/fq(1))])=1
else
   diffper=fq(1)-per1+subperiod
   vect(diffper+1+fq(1)*[0:floor((nvalues-diffper-1)/fq(1))])=1
end
 
dum=tlist(['ts';'freq';'dates';'series'],fq,[dat1:dat$]',vect)
 
endfunction
