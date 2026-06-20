function [bcpf,bctf] = turnbb(x,k,M,e,m,imcd,freqx,dates)
 
// PURPOSE: performs Bry-Boschan datation method
//-------------------------------------------------------
// INPUTS:
// * x 		= vector
// * k 		= # to determine the local min or max
// * M 		= minimal duration Peak-Peak or Trough-Trough
// * e		= min # of periods separating a turn form borders
// * m		= minimal phase
// * imcd       = month of cyclical dominance for bry-boschan procedure
// * freqx 	= frequency of the serie = 4 (quartely) or 12 (monthly)
// * dates 	= a vector of dates
//--------------------------------------------------------
// OUPUTS:
// * bcpf : new vector of peak indexes
// * bctf : new vector of trough indexes
//--------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss proprams by M. Watson
 
 
// Execute Step I of Bry-Boschan Procedure
// Check for outliers and replace with fitted values.";
xsp=spencer(x);
[xo,nxo]=bbout(x,xsp); // xo now contains the series with extremes adjusted
if size(nxo,1) > 0 then
   prtoutliers(nxo,xo,x,dates)
end
 
// Execute Step II of Bry-Boschan Procedure
// Determine turning points in 12-month moving averages
xma=mak(xo,freqx);     // Symmetric k-month moving averages, k = 4,12
[bcp1,bct1] =turnpoints(xma,k);
 
if isempty(bcp1) |  isempty(bct1) then
   write(%io(2),"No Peaks or No Troughs for this Series. Process Stops",'(a)');
   break;
end;
 
// Make Sure Dates alternate, peak then trough
// if not choose highest peak and lowest trough
[bcp2,bct2]=alter2(bcp1,bct1,xma);
 
 
// Execute Step III of Bry-Boschan Procedure
// Refine these using turns in the Spencer curve
xspo=spencer(xo);  // Spencer Curve For Data With Extremes Replaced
 
// A. Refine Previous Dates to ñ5 using of xspo
[bcp3,bct3]=refine(bcp2,bct2,xspo,5);
[bcp3,bct3]=alter2(bcp3,bct3,x);
 
// B. Enforce M month minimum P-P and T-T cycles
[bcp3,bct3]=enf1p(bcp3,bct3,xspo,M)
 
// Execute Step IV of Bry-Boschan Procedure
// Refine these dates using MCD-dependent term moving averages
mcdnum=mcd(x,freqx) // Program chooses term of moving
if imcd==0 then
 
	if mcdnum <= 2 then;
			mcdx=mak(x,3);          												// average depending on MCD as
		elseif mcdnum <= 4 then
			mcdx=mak(x,4);     																// prescribed in Bry-Boschan
		elseif mcdnum <= 6 then;
			mcdx=mak(x,5);     																// text pgs 24-26.
		else;
			mcdx=mak(x,6);
	end;
 
else;
   mcdx=mak(x,imcd)
 
end;
 
// A. Refine Previous Dates to ñ5 using of mcdx
[bcp4,bct4]=refine(bcp3,bct3,mcdx,5);
[bcp4,bct4]=alter2(bcp4,bct4,x);
 
// Step V: of Bry-Boschan Procedure
// Refine these using the actual series
span=max([mcdnum 4]);
 
// A. Refine Previous Dates to ñmax(4,mcd) using of x //
[bcp5,bct5]=refine(bcp4,bct4,x,span);
 
// B. Enforce censoring rules
[bcpf,bctf]= censor(bcp5,bct5,x,M,e,m)
 
endfunction
