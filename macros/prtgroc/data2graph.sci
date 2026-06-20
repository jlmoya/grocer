function [matout,xscale0]=data2graph(mat,bo)
 
// PURPOSE: from data in a matrix and corresponding bounds
// (which can be discontinous), determine the x axis and
// complement the matrix with NA for the missind dates
// ------------------------------------------------------------
// INPUT:
// * mat = a (nobsr x nvar) real matrix
// * bo = a vector of dates
// ------------------------------------------------------------
// OUPTUT:
// * matout = the filled matrix
// * matout = the corresponding x axis
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007-2010
// http://grocer.toolbox.free.fr/grocer.html
 
deb=0
nbperiods=size(bo,1)/2
diffdates=ones(nbperiods,1)
for i=1:nbperiods
   diffdates(i)=diff_date(bo(2*i),bo(2*i-1))
end
nobst=sum(diffdates)+nbperiods
[nobsr,nvar]=size(mat)
 
// propor is the ratio between the # of dates
// and the # of observations (relevant only for weekly ts)
propor=(nobst-1)/(nobsr-1)
diffdates=diffdates/propor
nobspna=diff_date(bo($),bo(1))/propor+1
matout=%nan*ones(nobspna,nvar)
 
fin1=1+diffdates(1)
matout(1:fin1,:)=mat(1:fin1,:)
[d1,fq]=date2num_fq(bo(1))
xscale0=num2date(d1+[0:nobspna-1]*propor,fq)
 
for i=2:nbperiods
   deb1=fin1+diff_date(bo(2*i-1),bo(2*i-2))/propor
   deb2=fin1+1
   fin1=deb1+diffdates(i)
   fin2=deb2+diffdates(i)
   matout(deb1:fin1,:)=mat(deb2:fin2,:)
end
 
endfunction
