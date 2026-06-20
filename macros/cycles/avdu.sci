function [PP,TT,PT,TP,APT,ATP] = avdu(bcpf,bctf,x) ;
 
// PURPOSE: computes average durations and amplitudes
// of peak to peak, trough to trough, trough to peak,
// and peak to trough cycles
//------------------------------------------------------
// INPUT:
//  * bcpf = vector of peak indexes
//  * bctf = vector of trough indexes
//  * x    = economic variable
//------------------------------------------------------
// OUTPUT:
//  * PP   = average duration peak to peak
//  * TT   = average duration trough to trough
//  * PT   = average duration peak to trough
//  * TP   = average duration trough to peak
//  * APT  = average amplitude peak to trough
//  * ATP  = average amplitude trough to peak
//------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// julien matheron
// Banque de France, centre de recherche
// Oct. 2002
 
 
PP = mean0(diff(bcpf));
TT = mean0(diff(bctf));
m = min([bcpf;bctf]);
M = max([bcpf;bctf]);
q = min(size(bctf,1),size(bcpf,1));
 
 
 
// ----------------------------------------
// Main loop
// ----------------------------------------
 
if size(bctf,1)==size(bcpf,1);
 
   // -------------------------------------------
   // 1st case: as many peaks as troughs
   // -------------------------------------------
 
   if bcpf(1)==m;
 
      // ----------------------------------------
      // subcase #1: peaks are first
      // ----------------------------------------
 
      PT  = mean0(bctf-bcpf);
      TP  = mean0(bcpf(2:q,1)-bctf(1:q-1,1));
      APT = mean0(x(bctf)-x(bcpf));
      ATP = mean0(x(bcpf(2:q,1))-x(bctf(1:q-1,1)));
 
   else
 
      // ----------------------------------------
      // subcase #2:  troughs are first
      // ----------------------------------------
 
      TP  = mean0(bcpf-bctf);
      PT  = mean0(bctf(2:q,1)-bcpf(1:q-1,1));
      ATP = mean0(x(bcpf)-x(bctf));
      APT = mean0(x(bctf(2:q,1))-x(bcpf(1:q-1,1)));
 
   end
 
else
 
   // -------------------------------------------
   // 2nd case: unequal # of peaks and troughs
   // -------------------------------------------
 
   if bcpf(1)==m then
 
      // ----------------------------------------
      // subcase #1: peaks are first
      // ----------------------------------------
 
      PT  = mean0(bctf(1:q,1)-bcpf(1:q,1));
      APT = mean0(x(bctf(1:q,1))-x(bcpf(1:q,1)));
 
 
      if bcpf(size(bcpf,1))==M;
 
         // -------------------------------------
         // subsubcase #1: peaks are last
         // -------------------------------------
 
         TP  = mean0(bcpf(2:q+1,1)-bctf(1:q,1));
         ATP = mean0(x(bcpf(2:q+1,1))-x(bctf(1:q,1)));
 
      else
 
         // -------------------------------------
         // subsubcase #2: troughs are last
         // -------------------------------------
 
         TP  = mean0(bcpf(2:q,1)-bctf(1:q-2,1));
         ATP = mean0(x(bcpf(2:q,1))-x(bctf(1:q-2,1)));
 
 
      end
 
   else bctf(1)==m;
 
      // ----------------------------------------
      // subcase #2: troughs are first
      // ----------------------------------------
 
      TP  = mean0(bcpf(1:q,1)-bctf(1:q,1));
      ATP = mean0(x(bcpf(1:q,1))-x(bctf(1:q,1)));
 
      if bctf(size(bctf,1))==M;
 
         // -------------------------------------
         // subsubcase #1: troughs are last
         // -------------------------------------
 
         PT  = mean0(bctf(2:q+1,1)-bcpf(1:q,1));
         APT = mean0(x(bctf(2:q+1,1))-x(bcpf(1:q,1)));
 
      else
 
         // -------------------------------------
         // subsubcase #2: peaks are last
         // -------------------------------------
 
         PT  = mean0(bctf(2:q,1)-bcpf(1:q-2,1));
         APT = mean0(x(bctf(2:q,1))-x(bcpf(1:q-2,1)));
 
      end
   end
end
 
endfunction
