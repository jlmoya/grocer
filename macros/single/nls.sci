function [rnls]=nls(grocer_eq,varargin)
 
// PURPOSE: non linear least-squares regression
// ------------------------------------------------------------
// INPUT:
// * eq = a string representing the equation to estimate
// * varargin =
//   . 'coef=[namecoef1;namecoef2;...;namecoefn]' with
//      namecoefi = name of the coefficient # i in
//     (default coef=['a1';'a2';...;'an'])
//   . 'init=[init1;init2;...;intin] if the user wants to give
//     starting values
//   . any option of maxlik (see maxlik() for a list)
//   . 'optfunc=optim' if the user wants to use the optim
//   optimisation function (default: optimg)
//   . 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   . 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   . 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// rnls= a tlist with
//   . rnls('meth')  = 'nls'
//   . rnls('beta')  = bhat
//   . rnls('nobs')  = nobs
//   . rnls('nvar')  = nvars
//   . rnls('beta')  = bhat
//   . rnls('resid') = residuals
//   . rnls('vcovar') = estimated variance-covariance matrix of
//                     beta
//   . rnls('sige')  = estimated variance of the residuals
//   . rnls('sigu')  = sum of squared residuals
//   . rnls('ser')  = standard error of the regression
//   . rnls('tstat') = t-stats
//   . rnls('pvalue') = pvalue of the betas
//   . rnls('dw')    = Durbin-Watson Statistic
//   . rnls('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rnls('namey') = the equation
//   . rnls('namex') = name of the coefficients
//   . rnls('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rnls('ropt') = the output tlist from maxlik (see maxlik
//                    for the list of arguments)
// ------------------------------------------------------------
// PRINTS: The results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_nvararg=length(varargin)
grocer_defcoef=%f
grocer_definit=%f
grocer_prt=%t
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',2*%eps,1000',1e-5)
 
for grocer_i=grocer_nvararg:-1:1
   if type(varargin(grocer_i)) == 10 then
      select part(varargin(grocer_i),1:4)
      case 'coef' then
         grocer_coef=str2vec(varargin(grocer_i),',',';')
         grocer_defcoef=%t
         grocer_nvar=size(grocer_coef,1)
         varargin(grocer_i)=null()
      case 'init' then
         execstr('grocer_'+varargin(grocer_i))
         grocer_definit=%t
         varargin(grocer_i)=null()
      else
         grocer_argis=strsubst(varargin(grocer_i),' ','')
         grocer_indeq=strindex(grocer_argis,'=')
         grocer_startargi=part(grocer_argis,1:grocer_indeq-1)
         if grocer_startargi == 'optfunc' then
             grocer_optfunc=part(grocer_argis,grocer_indeq+1:length(grocer_argis))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_nelmead' then
            grocer_opt_optim('nelmead')=part(grocer_argis,grocer_indeq+1:length(grocer_argis))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_optim' then
            grocer_opt_optim('optim')=part(grocer_argis,grocer_indeq+1:length(grocer_argis))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_optim_ineq' then
            grocer_opt_optim('optim ineq')=part(grocer_argis,grocer_indeq+1:length(grocer_argis))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_convg' then
             execstr('grocer_opt_optim(''convg'')='+part(grocer_argis,grocer_indeq+1:length(grocer_argis)))
             varargin(grocer_i)=null()
         elseif stripblanks(varargin(grocer_i)) == 'noprint' then
            grocer_prt=%f
         end
      end
   end
end
 
grocer_speccarb=['=' ; '+' ; '/' ; '(' ; '-' ; '*' ; ' ';'^']
if ~grocer_defcoef then
   grocer_ind=[]
   for grocer_i=1:9
      for grocer_k=1:size(grocer_speccarb,1)
         grocer_ind=[grocer_ind strindex(grocer_eq,grocer_speccarb(grocer_k)+'a'+string(grocer_i))]
      end
   end
 
   grocer_ind=grocer_ind+2
   grocer_coef=[  ]
 
   for grocer_i=1:size(grocer_ind,2)
      grocer_indi=part(grocer_eq,grocer_ind(grocer_i))
      grocer_j=0
      grocer_indc=part(grocer_eq,grocer_ind(grocer_i)+grocer_j)
      while ascii(grocer_indc) >=48 & ascii(grocer_indc) <= 57
         grocer_j=grocer_j+1
         grocer_indc=part(grocer_eq,grocer_ind(grocer_i)+grocer_j)
      end
      grocer_coef=[grocer_coef ; 'a'+part(grocer_eq,grocer_ind(grocer_i)+[0:grocer_j-1])]
   end
   grocer_coef=unique(grocer_coef)
   grocer_nvar=size(grocer_coef,1)
end
 
indeq=strindex(grocer_eq,'=')
grocer_eqt=part(grocer_eq,indeq+1:length(grocer_eq))+'-('+part(grocer_eq,1:indeq-1)+')'
grocer_eqt=strsubst(grocer_eqt,'*',' .*')
grocer_eqt=strsubst(grocer_eqt,'. .*',' .*')
grocer_eqt=strsubst(grocer_eqt,'/',' ./')
grocer_eqt=strsubst(grocer_eqt,'. ./',' ./')
grocer_eqt1=' '+grocer_eqt
grocer_speccara=['+' ; '-' ; '*' ; '/' ; ')' ; ' ';'^']
// replace the name of the cooefficienst by:
// - grocer_a1, grocer_a2, ... , grocer_an (in grocer_eqt1: for derivation)
// - grocer_a(1), grocer_a(2), ... , grocer_a(n)
//  (in grocer_eqt2: for the minimisation function)
for grocer_i=1:grocer_nvar
   for grocer_k=1:size(grocer_speccara,1)
      for grocer_l=1:size(grocer_speccarb,1)
          grocer_eqt1=strsubst(grocer_eqt1,...
                     grocer_speccarb(grocer_l)+grocer_coef(grocer_i)+...
                     grocer_speccara(grocer_k),grocer_speccarb(grocer_l)+...
                    'grocer_a'+string(grocer_i)+grocer_speccara(grocer_k))
      end
   end
end
 
if grocer_definit then
// the user has provided initial value; check if they are
// a vector and transpose it if necessary
   grocer_a=vec2col(grocer_init)
else
// the user has provided no initial values: they are
// drawn for the normal law
   grocer_a=grand(grocer_nvar,1,'nor',0,1)
end
 
execstr('grocer_a'+string(1:grocer_nvar)+'=grocer_a('+string(1:grocer_nvar)+')')
global grocer_unknown grocer_listts grocer_predefined ;
 
grocer_predefined=[]
execstr('grocer_transeq='+grocer_eqt1)
if typeof(grocer_transeq) == 'ts' then
   grocer_prests=%t
 
// define the range of the series in the ts and, if necessary
// the bounds
   if ~exists('grocer_boundsvar') then
      grocer_nls_s=ts2vec(grocer_transeq)
      grocer_d=datets(grocer_transeq)
      grocer_fq=freqts(grocer_transeq)
      grocer_boundsnum='1:grocer_d(size(grocer_d,1))-grocer_d(1)+1'
      grocer_boundsvar=[num2date(grocer_d(1),grocer_fq) ;...
      num2date(grocer_d(size(grocer_d,1)),grocer_fq)]
 
   elseif isempty(grocer_boundsvar) then
      grocer_nls_s=ts2vec(grocer_transeq)
      grocer_d=datets(grocer_transeq)
      grocer_fq=freqts(grocer_transeq)
      grocer_boundsnum='1:grocer_d(size(grocer_d,1))-grocer_d(1)+1'
      grocer_boundsvar=[num2date(grocer_d(1),grocer_fq) ;...
      num2date(grocer_d(size(grocer_d,1)),grocer_fq)]
 
   else
      grocer_nls_s=ts2vec(grocer_transeq,grocer_boundsvar)
      grocer_d=datets(grocer_transeq)
      grocer_nper=size(grocer_boundsvar,1)/2
      grocer_d0=grocer_d(1)
      grocer_boundsnum='['
      for grocer_i=1:grocer_nper
         grocer_boundsnum=grocer_boundsnum+string(date2num(...
         grocer_boundsvar(2*grocer_i-1))-grocer_d0+1)+':'...
         +string(date2num(grocer_boundsvar(2*grocer_i))-...
         grocer_d0+1)+' '
      end
      grocer_boundsnum=grocer_boundsnum+']'
   end
 
   grocer_totransf=%t
   grocer_i=1
   while grocer_totransf then
      grocer_before=['+';'-';'/';'*';' ';'^';'(']
      grocer_after=['(';' ']
      [true_lagts,ind_lagts_def]=findobject(grocer_eqt1,'lagts',grocer_before,grocer_after,%f)
      [true_delts,ind_delts_def]=findobject(grocer_eqt1,'delts',grocer_before,grocer_after,%f)
      ind_all=gsort([ind_lagts_def ind_delts_def],'g','i')
 
      if isempty(ind_all) then
         grocer_totransf=%f
      else
         grocer_endeq=part(grocer_eqt1,ind_all(1):length(grocer_eqt1))
         [grocer_leftpar,grocer_rightpar,grocer_fuspar]=sci_find_parenth(grocer_endeq,['(';')'],11)
         grocer_closingpar=find(grocer_fuspar(4,:) == 0)
         grocer_endexpr=grocer_fuspar(1,grocer_closingpar(1))
         grocer_expr=part(grocer_eqt1,ind_all(1)+[0:grocer_endexpr-1])
         execstr('grocer_ts'+string(grocer_i)+'=ts2vec('+grocer_expr+',grocer_boundsvar)')
         grocer_eqt1=part(grocer_eqt1,1:ind_all(1)-1)+'grocer_ts'+string(grocer_i)+part(grocer_eqt1,ind_all(1)+grocer_endexpr:length(grocer_eqt1))
         grocer_i=grocer_i+1
      end
   end
 
   global grocer_variables
   grocer_reseq=analyse_eq(grocer_eqt1);
 
   for grocer_j=1:size(grocer_variables,1)
       if typeof(evstr(grocer_variables(grocer_j))) == 'ts' then
          execstr(grocer_variables(grocer_j)+'=ts2vec('+grocer_variables(grocer_j)+',grocer_boundsvar)')
       end
   end
 
   execstr('grocer_v='+grocer_eqt1)
   grocer_nobs=size(grocer_v,1)
//   grocer_cheq='deff(''grocer_vect=grocer_eqfunc(grocer_a)''...
//      ,[''execstr('transeq='+grocer_eqt2)'';...
//      ''grocer_vect=transeq(''''series'''')('+grocer_boundsnum+')''])'
 
 
else
   grocer_prests=%f
   grocer_nobs=size(grocer_transeq,1)
   grocer_eqt1=strsubst(grocer_eqt1,'/',' ./')
   grocer_eqt1=strsubst(grocer_eqt1,'. ./','./')
   grocer_reseq=analyse_eq(grocer_eqt1);
 
end
 
grocer_eqt2=grocer_eqt1
for grocer_i=1:grocer_nvar
   for grocer_k=1:size(grocer_speccara,1)
      for grocer_l=1:size(grocer_speccarb,1)
          grocer_eqt2=strsubst(grocer_eqt2,...
                     grocer_speccarb(grocer_l)+'grocer_a'+string(grocer_i)...
                     +grocer_speccara(grocer_k),grocer_speccarb(grocer_l)...
                    +'grocer_a('+string(grocer_i)+')'+grocer_speccara(grocer_k))
      end
   end
end
 
if grocer_unknown then
// define the function to minimize (sum of squared residuals)
// define the function corresponding to the equation
   str1='deff(''[grocer_f,grocer_g,ind]=grocer_func(grocer_a,ind)'',[''grocer_f=sum(('
   str2=')^2)'';''grocer_g=zeros('
   str3= ',1)'';''grocer_delta=%eps^(1/3)*grocer_a+sqrt(%eps)*(grocer_a==0)'';''grocer_dx=zeros('
   str4=',1)'';''for grocer_j=1:'
   str5=''';''grocer_dx(grocer_j)=grocer_delta(grocer_j)'';''grocer_a=grocer_a+grocer_dx'';''grocer_aux=sum(('
   str6= ')^2)'';''grocer_a=grocer_a-2*grocer_dx'';''grocer_g(grocer_j)=(grocer_aux-sum(('
   str7=')^2))/2/grocer_delta(grocer_j)'';''grocer_a=grocer_a+grocer_dx'';''grocer_dx(grocer_j)=0'';''end''])'
   grocer_chf=str1+grocer_eqt2+str2+string(grocer_nvar)+str3+string(grocer_nvar)+str4+...
   string(grocer_nvar)+str5+grocer_eqt2+str6+grocer_eqt2+str7
 
 
else
   grocer_deriv=emptystr(1,grocer_nvar)
   for grocer_i=1:grocer_nvar
      grocer_deriv_i=deriv_eq(grocer_reseq,'grocer_a'+string(grocer_i))
      for grocer_j=1:grocer_nvar
         grocer_deriv_i=strsubst(grocer_deriv_i,'grocer_a'+string(grocer_j),...
                        'grocer_a('+string(grocer_j)+')')
      end
      execstr('grocer_vi='+grocer_deriv_i)
      if size(grocer_vi,'*') == 1 then
         grocer_deriv(grocer_i)='('+grocer_deriv_i+')*ones('+string(grocer_nobs)+',1)'
      else
         grocer_deriv(grocer_i)='('+grocer_deriv_i+')'
      end
   end
 
   str1='deff(''[grocer_f,grocer_g,ind]=grocer_func(grocer_a,ind)'',[''grocer_f=sum(('
   str2=').^2)''; ''grocer_g=zeros('
   str3=',1)'';'
   str4=joinstr('''grocer_g(',string(1:grocer_nvar),')=2*('+grocer_eqt2+')''''*',grocer_deriv,''';')
   grocer_chf=str1+grocer_eqt2+str2+string(grocer_nvar)+str3+str4+'''])'
 
end
grocer_cheq='deff(''grocer_f=grocer_eqfunc(grocer_a)'',[''grocer_f='+grocer_eqt2+'''])'
execstr(grocer_chf)
 
grocer_chf='deff(''[grocer_f,index]=grocer_func2(grocer_a,index)'',[''grocer_f=sum(('+grocer_eqt2+').^2)''])'
execstr(grocer_chf)
 
select grocer_optfunc
 
case 'optim'
   execstr('[grocer_sigu,grocer_a,g] = optim(grocer_func,'+grocer_opt_optim('optim ineq')+',grocer_a'+grocer_opt_optim('optim')+')');
 
case 'optimg'
   [grocer_sigu,grocer_a,g] = optimg(grocer_func2,grocer_func,grocer_a,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
else
   error('not an available optimization function: '+grocer_optfun)
 
end
 
if grocer_unknown then
   execstr(grocer_cheq)
   grocer_grad=numz0(grocer_eqfunc,grocer_a,grocer_nvar,ones(grocer_nvar,grocer_nobs),sqrt(%eps))'
 
else
   grocer_grad=zeros(grocer_nobs,grocer_nvar)
   for grocer_i=1:grocer_nvar
      execstr('grocer_grad(:,'+string(grocer_i)+')='+grocer_deriv(grocer_i))
   end
end
 
execstr('resid = -('+grocer_eqt2+')')
 
// add the usual output (tstat, dw,...)
sige=grocer_sigu/(grocer_nobs-grocer_nvar)
 
vcovar=grocer_sigu/(grocer_nobs-grocer_nvar)*invxpx(grocer_grad)
tmp = sqrt(diag(vcovar));
 
tstat=grocer_a ./tmp
ediff = resid(2:grocer_nobs)-resid(1:grocer_nobs-1)
dw = ediff'*ediff/grocer_sigu
df=grocer_nobs-grocer_nvar
pvalue=[]
for i=1:grocer_nvar
   p=(1-cdft("PQ",abs(tstat(i)),df))*2
   pvalue=[pvalue ; p]
end
 
// store the results
rnls=tlist(['results';'meth';'namey';'namex';'prests';'nobs';...
'nvar';'resid';'ser';'sigu';'sige';'vcovar';'dw';'beta';...
'tstat';'pvalue';'prescte';'dropna'],'nls',grocer_eq,...
grocer_coef,grocer_prests,grocer_nobs,grocer_nvar,resid,...
sqrt(sige),grocer_sigu,sige,vcovar,dw,grocer_a,tstat,pvalue,%f,%f)
 
if grocer_prests then
   rnls(1)($+1) = 'bounds'
   rnls('bounds')=grocer_boundsvar
end
 
if grocer_prt then
   prt_nls(rnls,%io(2))
end
 
endfunction
