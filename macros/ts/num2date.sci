function dat=num2date(num,fq)
 
// PURPOSE: transform a date in numerical presentation into
// its string format
// ------------------------------------------------------------
// INPUT:
// * num = a date in numerical presentation
// * fq = dates frequency (in constant format)
// ------------------------------------------------------------
// OUTPUT:
// * dat = a date in string format
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
load(GROCERDIR+'\param\basets.dat')
load(GROCERDIR+'\param\dailyform.dat')
 
if size(fq,'*') == 1 then
   fq=[fq 1]
end
 
i=vectorfind(grocer_basefqnum,fq,'r')
if fq(1) == 1 then
   if ~isempty(i) then
      dat=string(num)+grocer_basefqlit(i)
   else
      dat=string(num)+'z'+string(fq(2))
   end
 
elseif fq(1) == 365 then
   dat0=string(datevec(num))
 
// add 0 to the months with a single figure
   dat0_m=dat0(:,2)
   [r,c]=find(length(dat0_m) == 1)
   dat0_m(r)='0'+dat0_m(r)
   dat0(:,2)=dat0_m
 
// add 0 to the days with a single figure
   dat0_d=dat0(:,3)
   [r,c]=find(length(dat0_d) == 1)
   if ~isempty(r) then
      dat0_d(r)='0'+dat0_d(r)
   end
   dat0(:,3)=dat0_d
 
   dat=dat0(:,1)+grocer_dailysep+dat0(:,2)+grocer_dailysep+dat0(:,3)
   if size(num,1) == 1 then
      dat=dat'
   end

elseif fq(1) == 52 then
   if or(isnan(num)) then
      error('dates contain %nan values')
   end
   dat0=string(datevec(num*7+3))
 
// add 0 to the months with a single figure
   dat0_m=dat0(:,2)
   [r,c]=find(length(dat0_m) == 1)
   if ~isempty(r) then
      dat0_m(r)='0'+dat0_m(r)
   end
   dat0(:,2)=dat0_m
 
// add 0 to the days with a single figure
   dat0_d=dat0(:,3)
   [r,c]=find(length(dat0_d) == 1)
   dat0_d(r)='0'+dat0_d(r)
   dat0(:,3)=dat0_d
 
   dat=dat0(:,1)+grocer_dailysep+dat0(:,2)+grocer_dailysep+dat0(:,3)
 
   if size(num,1) == 1 then
      dat=dat'
   end
 
else
   an=floor((num-1)/fq(1))
   i=vectorfind(grocer_basefqnum,fq,'r')
   if ~isempty(i) then
      dat=string(an)+grocer_basefqlit(i)+string(num-fq(1)*an)
   else
      dat=string(an)+'f'+string(fq(1))+'d'+string(num-fq(1)*an)
   end
 
end
 
endfunction
