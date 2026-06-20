function rbb = brybos(grocer_namey0,varargin)
 
// PURPOSE: compute Bry-Boshan or Harding and Pagan turning
// points dating rules
//---------------------------------------------------------
// INPUT:
// * grocer_namey0  = a ts
// * varargin = options:
//   - 'M=xx'    	    = minimal duration Peak-to-Peak or
//   trough-to-trough
//   - 'e=xx'    	    = min # of periods separating a turn
//   form borders
//   - 'm=xx'    	    = minimal phase
//   - 'k=xx'    	    = # to determine the local min or max
//   - 'ma=xx'   	    = use of filtered data by a moving
//   xx-centered moving average
//   - 'spenc=1' 	    = filters data by a Spencer curve
//   - 'proc =''bb''' = performs bry-boschan specific
//   procedure
//	 	else  performs Harding-Pagan dating rules
//   ('proc =''hp''')
//   - 'imcd = xx'	    = user defined month of cyclical
//   dominance for bry-boschan procedure
//   - 'noprint' if the user does not want to print the
//   results
//---------------------------------------------------------
// OUTPUT:
// a results tlist with:
// - rbb('meth')   = method used ('bb' or 'hp')  			
// - rbb('P')	   = dates of peaks  			
// - rbb('T')      = dates of troughs 			
// - rbb('DPP)	   = average duration from peak to peak
// - rbb('DTT')	   = average duration from trough to trough
// - rbb('DPT')    = average duration from peak to trough
// - rbb('DTP')    = average duration from trough to peak
// - rbb('APT')    = average amplitude from peak to trough
// - rbb('ATP')    = average amplitude from trough to peak
// - rbb('filter') = if the data are filtered before
//  analysis
// - rbb('ind_peaks') = indexes of the peaks
// - rbb('ind_troughs') = indexes of the troughs
// - rbb('phases') = a (nobs x 1) vector equal to 0 in
//  recessions and 1 in expansions
// - rbb('prests') = %t = indicates the presence of a time
// series in the regression
// - rbb('namey')  = name of the y variable
// - rbb('bounds') = the bounds of the data
//---------------------------------------------------------
// REFERENCES:
// * D. Harding & A. Pagan (2002), "Dissecting the Cycle: a Methodological
// 		Investigation", Journal of Monetary Economics, n�49, pp. 365-381
// * G. Bry & C. Boschan (1971), "Cyclical Analysis of Time Series:
//		 Selected Procedures and Computer Programs", NBER Technical Paper n�20
//---------------------------------------------------------
// Copyright E. Michaux (2005)
 
global GROCERDIR ;
 
[grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb]=explone(grocer_namey0)
 
if grocer_prests then
   grocer_freqy = date2fq(grocer_boundsvarb(1))
   grocer_freqy = grocer_freqy(1)
else
   error('function brybos works only with ts')
end
 
// set defaults
grocer_prt=%t
grocer_spenc= 0
grocer_ma = 0
grocer_proc = 'hp'
grocer_imcd = 0
 
if grocer_freqy(1) == 4 then
   grocer_M = 5
   grocer_m = 2
   grocer_e = 2
   grocer_k = 2
 
elseif grocer_freqy(1) == 12
   grocer_M = 15
   grocer_m = 6
   grocer_e = 5
   grocer_k = 5
end
 
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      str1=part(varargin(grocer_i),1:1)
      str2=part(varargin(grocer_i),1:2)
      str3=part(varargin(grocer_i),1:3)
      str4=part(varargin(grocer_i),1:4)
      str5=part(varargin(grocer_i),1:5)
      if str1 == 'M' | str1 == 'm' | str1 == 'e' | str1 == 'k' then
         execstr('grocer_'+varargin(grocer_i))
      elseif str2 == 'ma' then
         execstr('grocer_'+varargin(grocer_i))
      elseif or(str4 == ['imcd' 'proc']) then
         execstr('grocer_'+varargin(grocer_i))
      elseif str5 == 'spenc' then
         execstr('grocer_'+varargin(grocer_i))
      elseif varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
 
if grocer_freqy(1) <= 2 then
   grocer_proc='hp'
   warning('your series are neither monthly not quarterly')
   if ~exists('grocer_M','local') then
      error('you should therefore have entered values for M,the minimal duration between two consecutive peaks')
   end
   if ~exists('grocer_m','local') then
      error('you should therefore have entered values for m, the minimal phase between a peak and a trough')
   end
   if ~exists('grocer_e','local') then
      error('you should therefore have entered values fore, the minimal number of periods separating a turn form borders ')
   end
   if ~exists('grocer_k','local') then
      error('you should therefore have entered values for k, determining a two-sided interval over which peaks and troughs are defined as local extrema')
   end
 
elseif and(grocer_freqy(1) ~= [4,12]) then
   grocer_proc='bb'
   warning('your series are neither monthly not quarterly')
   if ~exists('grocer_M','local') then
      error('you should have entered values for M,the minimal duration between two consecutive peaks')
   end
   if ~exists('grocer_m','local') then
      error('you should therefore have entered values for m, the minimal phase between a peak and a trough')
   end
   if ~exists('grocer_e','local') then
      error('you should therefore have entered values fore, the minimal number of periods separating a turn form borders ')
   end
   if ~exists('grocer_k','local') then
      error('you should therefore have entered values for k, determining a two-sided interval over which peaks and troughs are defined as local extrema')
   end
end
 
if grocer_spenc == 1 & grocer_ma ~= 0 then
   error("Spencer curve and MA-filetring cannot be used in the same time")
elseif (grocer_spenc == 1 | grocer_ma ~= 0) & grocer_proc == 'bb' then
   error("Spencer curve or MA-filetring are already used in Bry-Boschan specific procedure")
elseif grocer_proc ~= 'bb' & grocer_proc ~= 'hp' then
   error("Wrong type of procedure : must be ''bb'' or ''hp''")
end
 
// determine the beginning of the sample
if isempty(grocer_boundsvarb) then
   ndates=grocer_y('dates')
   dates = num2date(grocer_y('dates'),grocer_freqy)
else
   ndeb = date2num(grocer_boundsvarb(1))
   nfin = date2num(grocer_boundsvarb(2))
   ndates = (ndeb:nfin)'
   dates = num2date(ndates,grocer_freqy)
end
 
// determine Peaks and troughs
filt = 'none'
grocer_x = grocer_y
if grocer_proc == 'bb' then
   [bcpf,bctf] = turnbb(grocer_x,grocer_k,grocer_M,grocer_e,grocer_m,grocer_imcd,grocer_freqy,dates)
 
else
 
   if grocer_spenc == 1 then
      grocer_x =spencer(grocer_x)
      filt = 'spencer curve'
   elseif grocer_ma ~= 0 then
      grocer_x = mak(grocer_x,grocer_ma)
      filt = string(grocer_ma)+' terms centered moving-average'
   end
 
   [bcpf,bctf] = turnhp(grocer_x,grocer_k,grocer_M,grocer_e,grocer_m)
 
end
 
[PP,TT,PT,TP,APT,ATP] = avdu(bcpf,bctf,grocer_x) ;
 
nbcpf=size(bcpf,1)
nbctf=size(bctf,1)
nobs=size(grocer_y,1)
// load the parameters determining if peaks and troughs belong to
// the recession period
load(GROCERDIR+'/param/define_recession.dat')
 
if isempty(bctf) | isempty(bcpf) then
   phase_vec=[]
 
elseif bctf(1) < bcpf(1) then
// the first turning point is a trough
   phase_vec=0*grocer_y
   for i=1:min(nbcpf,nbctf)
      phase_vec(bctf(i)+grocer_trough:bcpf(i)-grocer_peak) = 1
   end
   // add 1 at the end if the last turning point is a trough
   // (it is the case if nbctf-ncpf=1)
   phase_vec(bctf($)+grocer_trough:(nbctf-nbcpf)*nobs)=1
 
else
   phase_vec=0*grocer_y+1
   for i=1:min(nbcpf,nbctf)
      phase_vec(bcpf(i)+grocer_peak:bctf(i)-grocer_trough) = 0
   end
   // add 0 at the end if the last turning point is a peak
   // (it is the case if nbcpf-nbctf=1)
   phase_vec(bcpf($)+grocer_peak:(nbcpf-nbctf)*nobs)=0
 
end
 
nbcpf = bcpf ;
nbctf = bctf ;
bcpf = dates(bcpf)
bctf = dates(bctf)
 
// bug fix : Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
phases=tlist(['ts';'freq';'dates';'series'],grocer_freqy,ndates,phase_vec)
 
// define the tlist result
rbb = tlist(['results';'meth';'y';'filt. y';'P';'T';'DPP';'DTT';'DPT';'DTP';'APT';'ATP';'filter';'ind_peaks';'ind_troughs';'phases'],...
						grocer_proc,grocer_y,grocer_x,bcpf,bctf,PP,TT,PT,TP,APT,ATP,filt,nbcpf,nbctf,phases)
 
// saves the names, the bounds if the regression involves ts
rbb(1)($+1) = 'prests'
rbb(1)($+1) = 'namey'
rbb('namey')=grocer_namey
rbb(1)($+1) = 'bounds'
rbb('bounds')=grocer_boundsvarb
 
// print results
if grocer_prt then
   prtbrybos(rbb,%io(2))		
   pltbrybos(rbb)
end
 
endfunction
