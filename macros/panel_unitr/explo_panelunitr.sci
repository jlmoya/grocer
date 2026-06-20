function [grocer_y,grocer_namey,grocer_prests,grocer_b,grocer_noprint,grocer_dropna,grocer_nonna,grocer_param]=explo_panelunitr(varargin)
 
// PURPOSE: explode arguments to a panel unit root function
// ------------------------------------------------------------
// INPUT:
// varargin = arguments that can be:
// * the strings:
//   - 'lagorders=x' with x=%nan (if the lags for the ADF test
//   are to be determined automatically) or a (N x 1) or (1 x N)
//   vector of lags for the ADF test
//   - 'pmax=x' with x=%nan or a number if for the maximal # of
//   lags for the ADF test
//   - 't_order=x' for the trend order:
//      -1: no constant, no trend
//       0: a constant, no trend (default)
//       1: a constant and a trend
//   - 'bandwidth=n' with:
//       n = 'C' (Default) common lag troncature for the
//           Bartlett kernel (Levin and Lin 2003)
//       n = 'N' for the Newey West (1994)'s non parametric
//                   bandwidth parameter
//       n = 'A' for the Andrews (1991) automatic bandwidth
//           parameter selection with AR(1) structure
//    - 'kernel=n' with:
//       n = 'b' for Bartlett (Default)
//       n= 'qs' for Quadratic Spectral (not possible
//              when bandwitch = 'C')
//    - 'signif=x' with x the signifance level
//    - 'noprint' if the user does not want to print the
//      results of the test
// * a time series
// * a real (nxp) matrix
// * a string equal to the name of a time series or a (nxp)
// ------------------------------------------------------------
// OUTPUT:
// * grocer_lagorders = %nan of a vector of lag orders for ADF
//   tests
// * grocer_pmax = %nan or the maximal # of lags for the ADF
//   test
// * grocer_t_order= a scalar, the trend order for the ADF test
// * grocer_kernel = a string, the kernel used
// * grocer_bandwidth = a string, the bandwidth used
// * grocer_signif = a scalar, the significance level
// * grocer_y = a (T x ky) real vector or a ts
// * grocer_namey = a (ky x 1) string vector
// * grocer_prests = a boolean indicating whether there is a ts
// * grocer_b = a (2 x 1) string matrix (of dates) or []
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_param.pmax=%nan
grocer_param.kmax=%nan
grocer_param.lagorders=%nan
grocer_param.t_order=0
grocer_param.kernel='b'
grocer_param.bandwidth='n'
grocer_param.criteria='IC1'
grocer_param.signif=0.05
grocer_param.typeoflag=' '
grocer_param.IGF=1
grocer_panel=%f
grocer_dropna=%f
grocer_noprint=%f
 
grocer_nargin=length(varargin)
 
for grocer_i=grocer_nargin:-1:1
 
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' & size(grocer_argi,'*') == 1 then
      grocer_argin=strsubst(grocer_argi,' ','')
      grocer_indeq=strindex(grocer_argin,'=')
      if ~isempty(grocer_indeq) then
         grocer_before_eq=part(grocer_argin,1:grocer_indeq-1)
         grocer_after_eq=part(grocer_argin,grocer_indeq+1:length(grocer_argin))
         if or(convstr(grocer_before_eq) == ['lagorders' ; 'kmax' ; 'pmax' ; 't_order' ; 'signif';'igf';'typeoflag']) then
 
            execstr('grocer_param.'+grocer_argin)
            varargin(grocer_i)=null()
 
         elseif grocer_before_eq == 'namevar' then
            execstr('grocer_'+grocer_before_eq+'='''+grocer_after_eq+'''')
            varargin(grocer_i)=null()
 
         elseif or(grocer_before_eq == ['namevar' ; 'bandwidth' ; 'kernel' ; 'criteria']) then
            execstr('grocer_param.'+grocer_before_eq+'='''+grocer_after_eq+'''')
            varargin(grocer_i)=null()
 
 
         elseif or(grocer_argin == ['dropna' ; 'noprint']) then
            execstr('grocer_'+grocer_argin+'=%t')
            varargin(grocer_i)=null()
 
         elseif typeof(evstr(grocer_argi(1))) == 'panel data' then
            execstr('varargin(grocer_i)='+grocer_argi)
         end
     end
   end
end
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
 
   grocer_argi=varargin(grocer_i)
   select typeof(grocer_argi)
 
   case 'panel data' then
      grocer_namep=grocer_argi('namex')
      grocer_xp=grocer_argi('x')
      grocer_findendo=(grocer_namevar == grocer_namep)
      grocer_yp=grocer_xp(:,grocer_findendo)
 
      grocer_id=grocer_argi('id')
   // grocer_id is the vector of individuals
 
      grocer_namey=grocer_argi('nameid')
   // and grocer_nameid is their name
 
      uniq=unique(grocer_id)
      dat=date2num_m(grocer_argi('dates'))
      fq=date2fq(grocer_argi('dates')(1))
      dat1=min(dat)
      datn=max(dat)
      grocer_y=zeros(datn-dat1+1,size(uniq,'*'))*%nan
      for grocer_j=1:size(uniq,'*')
         ind=find(grocer_id == uniq(grocer_j))
         dati=dat(ind)
         grocer_y(dati-dat1+1,grocer_j)=grocer_yp(ind)
      end
 
      grocer_b=num2date([dat1 ;datn],fq)
      grocer_prests=%t
      grocer_nonna=find(and(~isnan(grocer_y),'c'))
      if grocer_dropna then
         grocer_y(or(isnan(grocer_y),'c'),:)=[]
      end
   else
      [grocer_y,grocer_namey,grocer_prests,grocer_b,grocer_nonna]=explone(varargin(:),[],'individual',~grocer_dropna,grocer_dropna)
   end
 
end
 
if and(~isnan(grocer_param.lagorders)) & length(grocer_param.lagorders) ~= size(grocer_y,2) then
   warning(" The lag order must be specified for all the individuals of the panel: your lag structure cannot be considered ")
   grocer_param.lagorders = %nan;
end
 
endfunction
