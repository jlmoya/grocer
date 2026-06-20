function [r,c]=range2num(rangefile)
 
// PURPOSE: transform Excel celle definitions into Scilab
// indexes
// ------------------------------------------------------------
// INPUT:
// * rangefile = string, range to read, e.g. a2:b20, or the
// * mask = a (L x M) matrix, E x E conformable with x,
//   containing ones and zeros, which is used to specify
//    whetherthe particular row, column, or element is to be
//    printed as a character (0) or numeric (1) value
// * fmt = (K x 3) or (1 × 3) matrix where each row specifies
//   the format for the respective column of x
// ------------------------------------------------------------
// OUTPUT:
// * r = the corresponding indexes of the rows
// * c = the corresponding indexes of the cols
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
rangefile=convstr(rangefile)
indsep=strindex(rangefile,':')
ind1=part(rangefile,1:indsep-1)
ind2=part(rangefile,indsep+1:length(rangefile))
 
ind1_ascii=ascii(ind1)
ind1_chars=find(ind1_ascii>=46 & ind1_ascii <= 57)
execstr('r1='+part(ind1,ind1_chars(1):length(ind1)))
c1_ascii=ind1_ascii(1:ind1_chars(1)-1)
c1=sum((c1_ascii-96) .* 26^[ind1_chars(1)-2:-1:0])
 
ind2_ascii=ascii(ind2)
ind2_chars=find(ind2_ascii>=46 & ind2_ascii <= 57)
execstr('r2='+part(ind2,ind2_chars(1):length(ind2)))
c2_ascii=ind2_ascii(1:ind2_chars(1)-1)
c2=sum((c2_ascii-96) .* 26^[ind2_chars(1)-2:-1:0])
 
c=c1:c2
r=r1:r2
 
endfunction
