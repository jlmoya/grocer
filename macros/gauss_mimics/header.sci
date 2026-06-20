function header(prcnm,dataset,ver)
 
// PURPOSE: mimic gauss function header: prints a header for a
// report
// ------------------------------------------------------------
// INPUT:
// * prcnm = string, name of procedure that calls header.
// * dataset = string, name of data set
// * ver = 2×1 numeric vector, the first element is the major
//  version number of the program, the second element is the
// revision number. Normallythis argument will be the version/
// revision global (__??_ver) associated with the module within
// which header is called. This argument will be ignored if set
// to 0
// ------------------------------------------------------------
// OUTPUT:
// * y = L×1 vector containing all unique values that are in v1
// and v2, sorted in ascending order
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
h=strcat(emptystr(1,79)+'=','')
if string(dataset) == '0' then
   dataset=emptystr()
else
   dataset='datastet:'+dataset
end
 
if ver == 0 then
   ver=emptystr()
else
   ver='Version '+strcat(string(ver),'.')
end
 
load(GROCERDIR+'/param/dailyform.dat')
dat=getdate()
dat2=zeros(3,1)
dat2(grocer_dailypart(1))=dat(1)
dat2(grocer_dailypart(2))=dat(2)
dat2(grocer_dailypart(3))=dat(3)
 
t=prcnm+'  '+dataset+'  '+ver+'  '+strcat(string(dat2),grocer_dailysep)...
+'  '+string(dat(7))+':'+string(dat(8))
 
mat2print=[h;t;h]
printmat(mat2print,%io(2))
 
endfunction
