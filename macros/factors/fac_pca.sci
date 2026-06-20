function res = fac_pca(varargin)
 
// Purpose: Static factor analysis with the selection of
// the number of factors according to Bai-Ng information
// criteria
//---------------------------------------------------------
// INPUT:
// varargin = arguments which can be:
//		. a time series
//		. a real (nxp) vector
//		. a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//		. 'snum=xx' a vector [1,..,k] with the factors to keep
//         or the maximum the number of factor test
//         if bai_ng option is used
//		. 'pnum=xx' number of factors to keep for results
//     printing
//		. 'bai_ng=xx' with xx=ICp1, ICp2 or ICp3 if the
//     user wants to select the number of factors according
//     to Bai-Ng information criteria
//		. the string 'noprint' if the user doesn't want to print
//     the results of the regression
//---------------------------------------------------------
// OUTPUT:
// res a tlist with:
// . res('meth') = 'static factor'
// . res('x') = matrix of data
// . res('propor') = proportion of variance explained by
//   each factor (default is the first five factors)
// . res('loadings') = matrix of loadings (variables are in
//   rows) (default is the first five factors)
// . res('corr_x_f') = matrix of correlations between
//   variables and factors (default is the first five factors)
// . res('snum') = # of kept factors
// . res('pnum') = # of kept factors for results printing
// . res('yhat') = adjusted y
// . res('resid') = residual
// . res('fi') = i-th factor selected by the user (or Bai-Ng
//   information criteria), that is the factor with the i-th
//   contribution to total variance; the # of factors stored
//   in the tlist is either given by the user in option snum
//   or selected by one of the criteria proposed by Bai and
//   Ng
// . res('bai_ng') = 'no' or 'Icp1', 'ICp2', 'ICp3'
// . res('ICpk') = vector of information criteria if
//  'bai_ng'~= 'no'
// . res('prests') = a boolean indicating the presence of
//   ts in the variables
// . res('namex') = the string vector of names of the
//   input variables
// . res('bounds') = bounds of the estimation (if there are
//   ts in the regression)
//---------------------------------------------------------
// REFERENCES:
// . Stock, J. H. and M. Watson (1998),"Diffusion Indexes",
//   NBER Working Paper, n°6702
// . Bai, J., and S. Ng (2002): "Determining the Number of
//   Factors in Approximate Factor Models",  Econometrica,
//      70(1), 191-221.
//---------------------------------------------------------
// E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_snum=1
grocer_pnum= 5
grocer_bai_ng='no'
grocer_prt=%t
grocer_stan='no'
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      str4=part(grocer_argi,1:4)
      str6=part(grocer_argi,1:6)
	  if str4 == 'snum' | str4 == 'pnum'  then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
   		
   	  elseif str6 == 'bai_ng' then
	     grocer_bai_ng=part(grocer_argi,8:length(grocer_argi))
         varargin(grocer_i)=null()
 
      elseif grocer_argi == 'noprint'
         varargin(grocer_i)=null()
         grocer_prt=%f
 
      elseif str4 == 'stan' then
         varargin(grocer_i)=null()
         grocer_stan='stan'
      end
 
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
// explode the list of the arguments into the corresponding
// variable, its name, and, if necessary updates the bounds
[grocer_x,grocer_namexos,grocer_boundsvarb,grocer_prests]= explox(varargin,'exogenous')
 
[T,n] = size(grocer_x)
if grocer_snum > n then
	error('must have fewer factors than variables')
elseif grocer_pnum > n then
	grocer_pnum = n
end
 
// performs dynamic factor analysis
res = fac_pca1(grocer_x,grocer_snum,grocer_pnum,grocer_bai_ng,grocer_stan)
 
// complete the tlist
res(1)($+1) = 'prests'
res(1)($+1) = 'namex'
res('prests')=grocer_prests
res('namex')= grocer_namexos
 
if grocer_prests then
   res(1)($+1) = 'bounds'
   res('bounds')=grocer_boundsvarb
 
  // add dates
  for i =1:length(res('snum'))
	 execstr('res(''f'+string(grocer_snum(i))+''') = reshape(res(''f'+string(grocer_snum(i))+'''),grocer_boundsvarb(1))')
  end
end
 
// print resullts
if grocer_prt then
	prtfac_pca(res,%io(2))
end
 
endfunction
 
