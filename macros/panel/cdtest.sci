function res=cdtest(grocer_namey,varargin)
 
// PURPOSE: tests for cross-sectional dependence
//  in homegeneous or heterogeneous panels
//  (Bias-adjusted LM tests and Pesaran 2004 test)
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a real (nx1) vector or a string equal to
// the name of a time series or a (nx1) real vector between
// quotes (this last case is the only one authorized if you
// are using a 'panel data' tlist, see below)
// * first input of varargin:
//   - either a 'panel data' tlist
//   - or an endogenous variable taking the form of a time
//     series, a real (nx1) vector or a string equal to the
//     name of a time series or a (nx1) real vector between
//     quotes
// * other input of varargin:
//   - if first input of varargin was a 'panel data' tlist
//   then:
//      other input are optional and can be:
//      * either 'x=name1;...;namep' where name1,...,namep are
//      a subset of the names of the variables that are in the
//      database
//      * the string 'nameid=name1,..., namen' where name1,...
//      are names of individuals present in the database
//      * or the string 'noprint' if the user does not want to
//      print the estimation results
//   - if first input of varargin was an endegnous variable
//   then either:
//      * a time series
//      * a real (nxk) matrix
//      * a (kx1) string vector of names of time series, vectors
//      or matrices
//      * the string 'id=v' where v is the vector of individuals
//      attached to the y and x data (this argument must be
//      present somewhere in the list of variables arguments)
//      * the string 'noprint' if the user doesn't want the
//      to print the results of the regression
//   - the string 'cd', 'lm_homo' or 'lm_hetero' with (see grocer manual
//      for further technical details)
//      * 'cd_hetero for Pesaran (2004) cross section dependence test for
//        heterogeneous panel (default)
//      * 'lm_homo' for the Baltagi et alii (2012) LM-adjusted test
//        for homogeneous panels
//      * 'lm_hetero' for Pesaran et alii (2008)  LM-adjusted test
//        for heterogeneous panels
// ------------------------------------------------------------
// OUTPUT:
//  - res = a tlist with
//  . res('meth')='LM-adj CD'
//  . res('cd_stat') = test statistic
//  . res('cd_pvalue') = test p-value
// ------------------------------------------------------------
// REFERENCE:
// - Pesaran M. Hashem, A. Ullah, T. Yamagata (2008), "A bias-adjusted
//   LM test of error cross-section independence",
//   Econometrics Journal, 11, pp. 105-127
// - Pesaran, M. H. (2004). General diagnostic tests for cross section dependence in panels.
//      University of Cambridge, Faculty of Economics, Cambridge Working Papers in
//      Economics No. 0435.
// - Baltagi B. H., Q. Feng and C. Kao (2012), "A Lagrange Multiplier
//    test for cross-sectional dependence in a fixed effects panel
//    data model", Journal of Econometrics, 170, 164–177
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux (2012)
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt=%t
grocer_arg1=varargin(1)
grocer_subnameid=%f
grocer_nargin=length(varargin)
grocer_duc=%t
grocer_type=1;
if typeof(grocer_arg1) == 'panel data' then
   grocer_namep=grocer_arg1('namex')
// grocer_namep is the vector of names in the data base
 
   grocer_xp=grocer_arg1('x')
// grocer_xp is the vector of values in the data base
 
   grocer_findendo=(grocer_namep == grocer_namey)
   grocer_y=grocer_xp(:,grocer_findendo)
   grocer_x=grocer_xp(:,~grocer_findendo)
   grocer_namex=grocer_namep(~grocer_findendo)
// grocer_namex is the vector of names other than the endogenous
// one
 
   grocer_id=grocer_arg1('id')
// grocer_id is the vector of individuals
 
 
   for grocer_i=grocer_nargin:-1:2
      argi=strsubst(varargin(grocer_i),' ','')
      if part(argi,1:2) == 'x=' then
          // the user has given the name of the variables, which is a subset
          // of the names in the database
         grocer_namex=str2vec(varargin(grocer_i))
         grocer_x=[]
         for grocer_j=1:size(grocer_namep,1)
            if or(grocer_namex == grocer_namep(grocer_j)) then
               grocer_x=[grocer_x grocer_xp(:,grocer_j)]
            end
         end
 
 
      elseif part(argi,1:7) == 'nameid=' then
          // the user has given the name of the individuals, which is a subset
          // of the names in the database
         grocer_subnameid=%T
         grocer_nameid0=grocer_nameid
         grocer_nameid=str2vec(varargin(grocer_i))
      elseif argi == 'noprint' then
         grocer_prt=%f
      elseif part(argi,1:7)=='cd_hetero' then
         grocer_type=1
      elseif part(argi,1:7)=='lm_homo' then
         grocer_type=3
      elseif part(argi,1:9)=='lm_hetero' then
         grocer_type=2
      end
   end
 
   if grocer_subnameid then
 
      [grocer_B,grocer_ind]=gsort(vec2col(grocer_id),'g','d')
      grocer_dB=[grocer_B(2:$)-grocer_B(1:$-1) ; 1]
      // eliminates the redundant values
      grocer_binv=grocer_B(grocer_dB ~= 0)
      // take the inverse of binv to obtain the increasing order
      grocer_uniq=grocer_binv($:-1:1)
 
      for grocer_j=1:size(grocer_nameid0,1)
         if and(grocer_nameid ~= grocer_nameid0(grocer_j)) then
            f=find(grocer_id ==grocer_uniq(grocer_j))
            grocer_id(f)=[]
            grocer_y(f)=[]
            grocer_x(f,:)=[]
 
         end
      end
   end
 
   if grocer_type==1 then
      grocer_x=[grocer_x 0*grocer_y+1]
      grocer_namex=[grocer_namex ; 'const']
   end
 
 
else
 
 
   grocer_lx=varargin
   for grocer_i=grocer_nargin:-1:2
      argi=strsubst(varargin(grocer_i),' ','')
      if part(argi,1:3) == 'id=' then
         execstr('grocer_'+argi)
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:3)=='lm_homo' then
         grocer_type=3
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:9)=='lm_hetero' then
         grocer_type=2
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:9)=='cd_hetero' then
         grocer_type=1
         grocer_lx(grocer_i) = null()
      elseif argi == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
      end
   end
 
 
   if grocer_type==1 then
      grocer_lx($+1)='const'
   end
   [grocer_y,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvarb]=explouniv(grocer_namey,grocer_lx)
end
 
if grocer_type==1 then
  [stat,pval]=cdtest_he0(grocer_y,grocer_id,grocer_x)
  meth='heterogeneous panel CD'
elseif grocer_type==2 then
  [stat,pval]=cdtest_lmadj_he0(grocer_y,grocer_id,grocer_x)
  meth='heterogeneous panel LM-adj CD'
elseif grocer_type==3 then
  [stat,pval]=cdtest_lmadj_ho0(grocer_y,grocer_id,grocer_x)
  meth='homogeneous panel LM-adj CD'
end
 
res=tlist(['results';'meth';'stat';'pvalue'],meth,stat,pval)
 
if grocer_prt then
   prtcdtest(res,%io(2))
end
endfunction
