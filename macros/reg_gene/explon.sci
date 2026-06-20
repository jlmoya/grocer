function [grocer_mats,grocer_names,grocer_prests,grocer_b,grocer_nonna]=explon(grocer_vars,grocer_named,grocer_b,grocer_testna,grocer_dropna,grocer_mindat,grocer_lags)
 
// PURPOSE: explode n lists of variables into matrices, names
// and define corresponding bounds
// ------------------------------------------------------------
// INPUT:
// * grocer_vars = list of n:
//   - lists of variables
//   - matrix of names of variables
//   the variables being in the form of
//   * a time series
//   * a real vector,
//   * a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
//   * a matrix of strings, each one being the name of a
//   variable
//   * the string 'cte' or 'const' if the user wants a constant
//     to be included automatically
// * grocer_named = a (n x 1) or (1 x n) vector of strings
//   representing the name of variables not entered between
//   quotes
// * grocer_b = a (p x 1) string vector (of dates) (optional:
//   if not given the function either takes the existing bounds
//   or determines the bounds suitable to the given series)
// * grocer_testna = a boolean indicating whether the program
//   will test the existence of na’s values in the matrices of
//   values grocer_y and grocer_x
// * grocer_dropna = a boolean indicating whether the program
//   should keep only lines of matrices grocer_y and grocer_x
//   with non na values in both matrices (suppose that
//   grocer_testna has been set to %f)
// * grocer_lags = a (n x 1) vector, each coordinate indicating
//   the lag needed for the corresponding elements in the list
//   grocer_vars
// ------------------------------------------------------------
// OUTPUT:
// * grocer_mats = a list of n (T x ki) matrices
// * grocer_names = a list of n (ki x 1) matrices of names
// * grocer_prests = a boolean indicating whether there is a ts
// * grocer_b = a (2*p x 1) string matrix (of dates) or []
// * grocer_nonna = a (T x 1) vector of the indexes with non na values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006-2022
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_nargout,grocer_nargin] = argn(0)
grocer_n=length(grocer_vars) // number of different types of econometric objects
if grocer_nargin < 7 then
   grocer_lags=zeros(grocer_n,1)
end
if grocer_nargin < 6 then
   grocer_mindat=%f
end
 
if grocer_nargin < 5 then
   grocer_dropna=%f
end
 
if grocer_nargin < 4 then
   grocer_testna=%t
end
 
if grocer_nargin < 3 then
   // bounds have not been entered into the function
   grocer_b=[]
end
 
grocer_mats=list() // the list of grocer_n matrices to be used in the regession
grocer_names=list() // the list of grocer_n vectors of the corresponding variables names
grocer_listts=list() // the list of grocer_n ts for each type of econometric objects
grocer_listtsmat=list() // the list of grocer_n tsmat for each type of econometric objects
grocer_vec0=list() // the list of grocer_n real matrices for each type of econometric objects
grocer_indts0=list() // the list of grocer_n ts indexes for each type of econometric objects
grocer_indtsmat0=list() // the list of grocer_n tsmat indexes for each type of econometric objects
grocer_indvec0=list() // the list of grocer_n real matrices indexes for each type of econometric objects
grocer_indcte0=list() // the list of grocer_n real indexes of specific variables for each type of econometric objects
grocer_n0=list() // the list collecting the number of final variables for each type of econometric objects
grocer_prests=%f
grocer_searchb=%f
grocer_isvec=%f
grocer_b0=grocer_b
 
for grocer_i=1:grocer_n
 
   grocer_li=grocer_vars(grocer_i)
 
// explode the list grocer_i into its various components (real matrices, ts, tsmat, specific variables)
// and their indexes
   [grocer_namei,grocer_listtsi,grocer_veci,grocer_indtsi,grocer_indveci,grocer_indctei,grocer_ni,grocer_listtsmati,grocer_indtsmati]=...
   explovars(grocer_li,grocer_named(grocer_i))
 
// add the components and indexes to the corresponding list
   grocer_names(grocer_i)=grocer_namei
   grocer_listts(grocer_i)=grocer_listtsi
   grocer_listtsmat(grocer_i)=grocer_listtsmati
   grocer_vec0(grocer_i)=grocer_veci
   grocer_indts0(grocer_i)=grocer_indtsi
   grocer_indtsmat0(grocer_i)=grocer_indtsmati
   grocer_indvec0(grocer_i)=grocer_indveci
   grocer_indcte0(grocer_i)=grocer_indctei
   grocer_n0(grocer_i)=grocer_ni
   if ~exists('grocer_ts1','local') & ~isempty(grocer_indtsi) then
      grocer_ts1=grocer_listtsi(1)
      grocer_fq=grocer_ts1('freq')
   elseif ~exists('grocer_tsmat1','local') & ~isempty(grocer_indtsmati) then
      grocer_tsmat1=grocer_listtsmati(1)
      grocer_fq=grocer_tsmat1('freq')
   end
   grocer_prests = grocer_prests | length(grocer_listtsi) ~= 0 | length(grocer_listtsmati) ~= 0
   grocer_isvec = grocer_isvec | length(grocer_veci) ~= 0
 
end
 
grocer_searchb=%f
grocer_boundsnum=[]
if grocer_prests then
   if grocer_isvec
      warning('your regression contains ts as well as vectors')
   end

   if isempty(grocer_b) then
      if exists('grocer_boundsvar') then
         if ~isempty(grocer_boundsvar) then
            [junk,grocer_fqb]=date2num_fq(grocer_boundsvar(1))
            if grocer_fqb(1) ~= grocer_fq(1) | cumprod(grocer_fq) ~= cumprod(grocer_fqb) then
               error('time series and bounds have not the same frequency')
            end
            grocer_b=grocer_boundsvar
         else
            grocer_searchb=%t
         end
      else
         grocer_searchb=%t
      end
   else
      if exists('grocer_boundsvar') then
         [junk,grocer_fqb]=date2num_fq(grocer_b(1))
         if grocer_fqb(1) ~= grocer_fq(1) | cumprod(grocer_fq) ~= cumprod(grocer_fqb) then
            error('time series and bound have not the same frequency')
         end
      end

   end
 
   if grocer_searchb then
      grocer_dates_start=[]
      grocer_dates_end=[]
      for grocer_i=1:grocer_n
         if ~isempty(grocer_listts(grocer_i)) then
            [grocer_datei_start,grocer_datei_end]=ts_span(grocer_listts(grocer_i))
            grocer_dates_start=[grocer_dates_start ; grocer_datei_start+grocer_lags(grocer_i)]
            grocer_dates_end=[grocer_dates_end ; grocer_datei_end]
         end
         if ~isempty(grocer_listtsmat(grocer_i)) then
            [grocer_datei_start,grocer_datei_end]=ts_span(grocer_listtsmat(grocer_i))
            grocer_dates_start=[grocer_dates_start ; grocer_datei_start+grocer_lags(grocer_i)]
            grocer_dates_end=[grocer_dates_end ; grocer_datei_end]
         end
      end
      if ~grocer_testna & grocer_mindat then
         grocer_dmin=min(grocer_dates_start)
         grocer_dmax=max(grocer_dates_end)
      else
         grocer_dmin=max(grocer_dates_start)
         grocer_dmax=min(grocer_dates_end)
      end
      grocer_boundsnum=[grocer_dmin:grocer_dmax]'
      grocer_b=[num2date(grocer_dmin,grocer_fq) ; num2date(grocer_dmax,grocer_fq)]
 
   else
      grocer_boundsnum=[date2num(grocer_b(1)):date2num(grocer_b(2))]'
      for i=2:size(grocer_b,1)/2
         grocer_boundsnum=[grocer_boundsnum ; [date2num(grocer_b(2*i-1)):date2num(grocer_b(2*i))]']
      end
 
   end
   grocer_nobs=size(grocer_boundsnum,1)
 
   for grocer_j=1:grocer_n
      grocer_lagj=grocer_lags(grocer_j)
      grocer_yj=%nan*ones(grocer_nobs+grocer_lagj,grocer_n0(grocer_j)) // grocer_yj = vector of values to fill
      grocer_bj=[grocer_boundsnum(1)-[grocer_lagj:-1:0]' ;grocer_boundsnum(2:$)]
      grocer_listtsj=grocer_listts(grocer_j)
      grocer_indtsj=grocer_indts0(grocer_j)
   // treat the j-th type of econometric object
      for grocer_k=1:size(grocer_indtsj,1)
         grocer_tsk=grocer_listtsj(grocer_k)
         grocer_tsk_dates=grocer_tsk('dates')
         if grocer_tsk_dates(1)-grocer_bj(1) > 0 & grocer_testna then
            error('series '+grocer_names(grocer_j)(grocer_indtsj(grocer_k))+' starts after the bounds you have given')
         end
         if grocer_bj($)-grocer_tsk_dates($) > 0 & grocer_testna then
            error('series '+grocer_names(grocer_j)(grocer_indtsj(grocer_k))+' ends before the bounds you have given')
         end
         grocer_start_y=max(1,grocer_tsk_dates(1)-grocer_bj(1)+1)
         grocer_end_y=min(grocer_nobs,grocer_nobs-grocer_bj($)+grocer_tsk_dates($))+grocer_lagj
         grocer_by=grocer_bj(grocer_bj >= grocer_tsk_dates(1) & grocer_bj <= grocer_tsk_dates($))
         grocer_yj(grocer_start_y:grocer_end_y,grocer_indtsj(grocer_k))=grocer_tsk('series')(grocer_by-grocer_tsk_dates(1)+1) // fill the values stemming from ts
      end
 
      grocer_listtsmatj=grocer_listtsmat(grocer_j)
      grocer_indtsmatj=grocer_indtsmat0(grocer_j)
      grocer_ind0=0
      for grocer_k=1:length(grocer_listtsmatj)
         grocer_tsmatk=grocer_listtsmatj(grocer_k)
         grocer_tsmatk_dates=grocer_tsmatk('dates')
 
         if grocer_tsmatk_dates(1)-grocer_bj(1) > 0 & grocer_testna then
            error('tsmat input starts after the bounds you have given')
         end
         if grocer_bj($)-grocer_tsmatk_dates($) > 0 & grocer_testna then
            error('tsmat input ends before the bounds you have given')
         end
 
         grocer_start_y=max(1,grocer_tsmatk_dates(1)-grocer_bj(1)+1)
         grocer_end_y=min(grocer_nobs,grocer_nobs-grocer_bj($)+grocer_tsmatk_dates($))+grocer_lagj
         grocer_by= grocer_bj(grocer_bj >= grocer_tsmatk_dates(1) & grocer_bj <= grocer_tsmatk_dates($))
         grocer_ind1=size(grocer_tsmatk('series'),2)
         grocer_yj(grocer_start_y:grocer_end_y,grocer_indtsmatj(grocer_ind0+[1:grocer_ind1]))=...
                   grocer_tsmatk('series')(grocer_by-grocer_tsmatk_dates(1)+1,:) // fill the values stemming from ts
         grocer_ind0=grocer_ind1
 
      end
 
      grocer_nmatj=size(grocer_vec0(grocer_j),1) // number of observations stemming from the real matrices
      if grocer_nmatj > 0 & grocer_nmatj ~= grocer_nobs then
         error('nobs of matrices do not match with those of ts')
      end
      grocer_yj(:,grocer_indvec0(grocer_j))=grocer_vec0(grocer_j) // fill the values stemming from real matrices
 
      grocer_indctei=grocer_indcte0(grocer_j) // index of the specific variables
      grocer_namei=grocer_names(grocer_j)
      for grocer_i=1:size(grocer_indctei,1)
         grocer_k=grocer_indctei(grocer_i)
         grocer_yj=deal_varspec(grocer_yj,grocer_namei(grocer_k),grocer_k,grocer_b) // fill the matrix of values for the specific variables
      end
 
      grocer_mats(grocer_j)=grocer_yj
   end
 
else
// there is no ts: only real matrices and specific objects
   grocer_fill=[] // indexes of econometric objects that contain explicit values
   for grocer_j=1:grocer_n
      if grocer_indvec0(grocer_j) ~= [] then
         grocer_fill=[grocer_fill grocer_j]
      end
   end
   grocer_empt=1:grocer_n // indexes of econometric objects that do not contain explicit values
   grocer_empt(grocer_fill)=[]
   grocer_nobs=size(grocer_vec0(grocer_fill(1)),1)-grocer_lags(1)
 
   for grocer_i=1:size(grocer_fill,2)
      grocer_j=grocer_fill(grocer_i)
      grocer_yj=ones(grocer_nobs+grocer_lags(grocer_j),grocer_n0(grocer_j))
      grocer_yj(:,grocer_indvec0(grocer_j))=grocer_vec0(grocer_j) // fill the concerned yj columns with their values
 
      grocer_indctej=grocer_indcte0(grocer_j)
      grocer_namej=grocer_names(grocer_j)
      for grocer_m=1:size(grocer_indctej,1)
         grocer_k=grocer_indctej(grocer_m)
         grocer_yj=deal_varspec(grocer_yj,grocer_namej(grocer_k),grocer_k,1:grocer_nobs+grocer_lags(grocer_j)) // fill specific variables
      end
 
      grocer_indcte=search_cte(grocer_yj) // indexes of constant variables
      if size(grocer_indcte,2) > 1 & grocer_j > 1 then
         warning('you have more than one constant in your '+grocer_named(j)+' set of variables')
      end
      grocer_mats(grocer_j)=grocer_yj
   end
 
   for grocer_i=1:size(grocer_empt,2)
      grocer_j=grocer_empt(grocer_i)
      grocer_indctej=grocer_indcte0(grocer_j)
      grocer_yj=ones(grocer_nobs+grocer_lags(grocer_j),grocer_n0(grocer_j))
      grocer_namej=grocer_names(grocer_j)
      for grocer_m=1:size(grocer_indctej,1)
         grocer_k=grocer_indctej(grocer_m)
         grocer_yj=deal_varspec(grocer_yj,grocer_namej(grocer_k),grocer_k,1:grocer_nobs+grocer_lags(grocer_j)) // fill specific variables
      end
 
      grocer_indcte=search_cte(grocer_yj) // indexes of constant variables
 
      if size(grocer_indcte,2) > 1 & grocer_j>1 then
         warning('you have more than one constant in your '+grocer_named(j)+' set of variables')
      end
      grocer_mats(grocer_j)=grocer_yj
   end
   grocer_b=[]
 
end
 
grocer_nonna=%t
grocer_mat=[]
for grocer_i=1:grocer_n
   grocer_mat_aux=[grocer_mats(grocer_i) mlag(grocer_mats(grocer_i),grocer_lags(grocer_i))]
   grocer_mat=[grocer_mat grocer_mat_aux(1+grocer_lags(grocer_i):$,:)]
end
 
grocer_ind_na=find(or(isnan(grocer_mat),'c'))
grocer_nonna=find(and(~isnan(grocer_mat),'c'))
 
if grocer_dropna then
   for grocer_j=1:grocer_n
      grocer_matj=grocer_mats(grocer_j)
      grocer_ind_nalags=grocer_ind_na+grocer_lags(grocer_j)
      for grocer_i=1:grocer_lags(grocer_j)-1
         grocer_ind_nalags=[grocer_ind_nalags grocer_ind_na+grocer_lags(j)+grocer_i]
      end
      grocer_ind_nalags=unique(grocer_ind_nalags)
      grocer_matj(grocer_ind_nalags,:)=[]
      grocer_mats(grocer_j)=grocer_matj
   end
 
elseif grocer_searchb & grocer_testna then
   [grocer_indminb,grocer_indmaxb]=longest_nonna_span(grocer_mat,'c')
   grocer_boundsnum=grocer_boundsnum(grocer_indminb:grocer_indmaxb)
   grocer_b=[num2date(grocer_boundsnum(1),grocer_fq) ; num2date(grocer_boundsnum($),grocer_fq)]
   for grocer_j=1:grocer_n
      grocer_lagj=grocer_lags(grocer_j)
      grocer_matj=grocer_mats(grocer_j)
      grocer_mats(grocer_j)=grocer_matj(grocer_indminb:grocer_indmaxb+grocer_lagj,:)
   end
 
elseif grocer_testna & ~grocer_mindat then
 
   for grocer_j=1:grocer_n
      grocer_presna=find(or(isnan(grocer_mats(grocer_j)),'r'))
      grocer_namesj=grocer_names(grocer_j)
      if ~isempty(grocer_presna) then
         error('series '+strcat(grocer_namesj(grocer_presna),', ')+' contain(s) Nan in the range you have specified')
      end
   end
 
end
 
endfunction
 
