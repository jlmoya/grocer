function rba = banerji(Pr,Tr,Pt,Tt,varargin)
 
// PURPOSE: Randomization test to evaluate the leading profile of
// a series against another one
// Test the null H0: leads are not significant
//-------------------------------------------------------------------
// INPUT:
// . Pr = a vector of through dates for the reference series
// . Tr = a vector of through dates for the reference series
// . Pt = a vector of through dates for the competing series
// . Tt = a vector of through dates for the competing series
// . 'lead=xx' = number of leads to test (default is 4)
// . 'noprint' = if the user doesn't want to print the results
//-------------------------------------------------------------------
// OUTPUT:
// rba a tlist results
// . rba('signi')      = confidence for rejection of the null
//   hypothesis of lead not significant
// . rba('sum_ini')    = initial sum of time difference
// . rba('lead')       = number of tested leads (default is 4)
// . rba('dates_extra')= dates of extra-cycle in the reference serie
// . rba('PT_extra')   = type of each dates (P or T) in the
//   extra-cycle
//-------------------------------------------------------------------
// REFERENCE:
// A. Banerji (1999),"The lead profile and other non-parametric tools
//	to evaluate survey series as leading indicators" , 24e CIRET Conference
//-------------------------------------------------------------------
// Copyright E. Michaux (2005)
 
// set defaults
grocer_lead= 4
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
     str4=part(varargin(grocer_i),1:4)
     if str4 == 'lead' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
      end
 
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
      typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
// convert dates into numerics
vecn = ['t' 'r']
vectu1 = ['p' 't']
vectu2 = ['P' 'T']
 
for i =1:2
   for j = 1:2
      execstr('n'+vectu1(i)+vecn(j)+' = size('+vectu2(i)+vecn(j)+',1)') // determines number of peaks and throughs for each serie
      execstr(vectu1(i)+vecn(j)+' = zeros(n'+vectu1(i)+vecn(j)+',1)')	
      execstr('ndate = n'+vectu1(i)+vecn(j)')
      for k = 1:ndate
         execstr(vectu1(i)+vecn(j)+'('+string(k)+') = date2num('+vectu2(i)+vecn(j)+'('+string(k)+'))')
      end	
   end
end
 
// determine if the first point is a peak or a through
// if it is a trough (second element of vectu1) then the first date of a
// peak (pr(1)) must be greater than the last date of a trough (tr($))
 
firstr=vectu1(1+(pr(1) > tr(1)))
firstt=vectu1(1+(pt(1) > tt(1)))
 
if firstr ~= firstt then
   warning('series have not the same type of first turning point:')
   if firstr == 'p' then
      if pr(1) < tt(1) then
         write(%io(2),'first peak of the reference series had been ignored','(a)')
         pr(1)=[]
         npr=npr-1
         firstr='t'
      else
         write(%io(2),'last trough of the tested series had been ignored','(a)')
         tt(1)=[]
         ntt=ntt-1
         firstt='p'
      end
   else
      if tr(1) < pt(1) then
         write(%io(2),'first trough of the reference series had been ignored','(a)')
         tr(1)=[]
         ntr=ntr-1
         firstr='p'
      else
         write(%io(2),'first peak of the tested series had been ignored','(a)')
         pt(1)=[]
         npt=npt-1
         firstt='t'
      end
   end
   write(%io(2),' ','(a)')
end
 
// determine the same way if the last point is a peak or a through
lastr=vectu1(1+(pr($) < tr($)))
lastt=vectu1(1+(pt($) < tt($)))
 
if lastr ~= lastt then
   warning('series have not the same type of last turning point:')
   if lastr == 'p' then
      if pr($) > tt($) then
         write(%io(2),'last peak of the reference series had been ignored','(a)')
         pr($)=[]
         npr=npr-1
         lastr='t'
      else
         write(%io(2),'last trough of the tested series had been ignored','(a)')
         tt($)=[]
         ntt=ntt-1
         lastt='p'
      end
   else
      if tr($) > pt($) then
         write(%io(2),'last trough of the reference series had been ignored','(a)')
         tr($)=[]
         ntr=ntr-1
         lastr='p'
      else
         write(%io(2),'last peak of the tested series had been ignored','(a)')
         pt($)=[]
         npt=npt-1
         lastt='p'
      end
   end
   write(%io(2),' ','(a)')
end
 
// test if the the competing serie hasn't more turning points than the reference series
// the inverse is allowed in the case of an even number of extra points: there will be considered
// as an extra cycle and will be removed from the test
if (npt > npr) | (ntt > ntr) then
   error('the competiting series must have at much the same number of turning points as the reference serie')
end
 
// test presence of extra-cycle in the reference serie
nextra = 0
t1= npr-npt
t2 =ntr-ntt
if (t1 == t2) then
   nextra = t1
end
 
// merge vectors of peaks and through
yr = []
yt = []
if firstr == 't' then
   for i = 1:min(ntr,npr)
      yr = [yr tr(i) pr(i)]
   end
 
   for i = 1:min(ntt,npt)	
	yt = [yt tt(i) pt(i)]
   end
elseif firstr == 'p' then  	
   for i = 1:min(ntr,npr)
      yr = [yr pr(i) tr(i)]
   end
 
   for i = 1:min(ntt,npt)
// bug fix Eric Dubois 10/12/06
// http://grocer.toolbox.free.fr/grocer.html
      yt = [yt pt(i) tt(i)]
   end
end
 
if npr > ntr then
   yr = [yr  pr(npr)]
   yt = [yt  pr(npt)]
elseif ntr > npr then
   yr = [yr tr(ntr)]
   yt = [yt tt(ntt)]
end
 
// find periods of extra-cycle
loc = []
yr_ini = yr
if nextra > 0 then
   i = 1
 
   while (size(yr,2) ~= size(yt,2)) & (i < size(yr,2))  then
      // an extra-cycle is defined as a P to T
      // or T to P periode present in the reference serie
      // and not in the competiting serie
      if (abs(yr(i)-yt(i)) >	abs(yr(i+2)-yt(i))) &...
         (abs(yr(i+1)-yt(i+1)) >	abs(yr(i+3)-yt(i+1))) then
         loc = [loc ; i]
         nyr = size(yr,2)
         yr = [yr(1:i-1) yr(i+2:nyr)]
         i  = i-1
      end
      i = i+1
   end
 
   if (size(loc,1) ~= nextra) | (i >= size(yr,2)) then
      error('Error in detection of extra-cycle')
   end
end
 
extra =[]
pextra = []
fq = date2fq(Pr(1)) // determine the frequency of the dates
for i = 1:size(loc,1)
   extra = [extra;num2date(yr_ini(loc(i)),fq) num2date(yr_ini(loc(i)+1),fq)]
 
   // determine if the extra-cyles are a P to T or a T to P cycle
   if firstr == 'p' then
      if loc(i)/2 == int(loc(i)/2) then
         pextra = [pextra;'P' 'T']
      else
         pextra = [pextra;'T' 'P']
      end
   else
      if loc(i)/2 == int(loc(i)/2) then
         pextra = [pextra;'T' 'P']
      else
         pextra = [pextra;'P' 'T']
      end
   end
 
end
 
grocer_y = yr - yt
rba = banerji0(grocer_y,grocer_lead)
 
// save number and type of of extra cycle
rba(1)($+1)  = "dates_extra"
rba(1)($+1)  = "PT_extra"
rba('dates_extra') = extra
rba('PT_extra') = pextra
 
// print results
if grocer_prt then
   prtbanerji(rba,%io(2))						
end
 
endfunction
 
 
