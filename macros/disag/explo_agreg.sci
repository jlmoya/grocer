function [grocer_Y,grocer_x,grocer_namendo,grocer_namexos,grocer_prestshf,grocer_boundshf,grocer_s,grocer_boundslf]=explo_agreg(grocer_ta,grocer_namey,varargin)
 
// PURPOSE: Generate matrices associated to the exogenous and
// endogenous variables of a disaggregation problem, the
// associated names and the conversion from low to high
// frequency parameter
// ------------------------------------------------------------
// INPUT:
// * grocer_ta = type of disaggregation:
//   - grocer_ta = -1 ---> sum (flow)
//   - grocer_ta = 0 ---> average (index)
//   - grocer_ta = k ---> k th element ---> interpolation
// * grocer_namey = low frequency data
// * varargin = a collection of ts, vectors, matrices or
//   strings or lists of such objects
// ------------------------------------------------------------
// OUTPUT:
// * grocer_Y = (N1 x 1) real vector of low frequency data
// * grocer_x = (N2 x p) real matrix of high frequency indicators
//   (without intercept)
// * grocer_nameY = a string name of low frequency data
// * grocer_x = (n x p) string matrix of names for the high
//   frequency indicators
// * grocer_s = number of high frequency data points for each low
//   frequency data points:
//   - s= 4 ---> annual to quarterly
//   - s=12 ---> annual to monthly
//   - s= 3 ---> quarterly to monthly
// * grocer_prestshf = a boolean indicating the presence or
//   absence of ts in the high frequency indicators
// * grocer_boundshf = the corresponding bounds in the presence
//   or [] in the absence of ts
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2011
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_x,grocer_namexos,grocer_prestshf,grocer_boundshf]=explone(varargin,[],'exogenous',%t,%f)
bounds()
 
[grocer_Y,grocer_namendo,grocer_prestslf,grocer_boundslf]=explone(grocer_namey,[],'endogenous',%f,%f)
 
if grocer_prestshf & grocer_prestslf then
   [datnum_hf1,fqh]=date2num_fq(grocer_boundshf(1))
   fql=date2fq(grocer_boundslf(1))
   grocer_s = int(fqh(1)/fqh(2)/fql(1)*fql(2))
   b1=datelf2hf0(grocer_boundslf(1),grocer_s,max(grocer_ta,1))
   db1=diff_date(b1,grocer_boundshf(1))
 
   if db1 > 0 then
   // high frequency series begin before the low frequency one
      grocer_boundshf(1)=b1
      grocer_x=grocer_x(db1+1:$,:)
 
   elseif db1 < 0 then
      dba=ceil(abs(db1)/grocer_s)
      shift=(ceil((datnum_hf1-1)/grocer_s))*grocer_s+1-datnum_hf1
      grocer_boundshf(1)=num2date(datnum_hf1+shift,fqh)
      grocer_x=grocer_x(shift+1:$,:)
      grocer_Y=grocer_Y(dba+1:$,:)
 
   end
 
   b2=datelf2hf0(grocer_boundslf($),grocer_s,max(grocer_ta,1))
   db2=diff_date(b2,grocer_boundshf($))
 
   if db2 > 0 then
   // high frequency series ends before low frequency ones
      nba_sup=int((db2-1)/grocer_s)+1
      grocer_Y=grocer_Y(1:$-nba_sup,:)
   end
 
else
   grocer_s=int(size(grocer_x,1)/size(grocer_Y,1))
 
end
 
endfunction
