function [irf_med,irf_mean,irf_low,irf_up]=Hetero_TVP_VAR_irf(r,dates,nhor,pvalue,impulse_mode,plt)
 
// PURPOSE: Impulse response function for a Time varying
// structural VAR with with heteroskedastic covariance matrix
// ------------------------------------------------------------
// INPUT:
// * res = a tlist results from a Homo_TVOP_VAr estimation
// * dates = a string vector (standard Grocer dates) or a real
// vector (corresponding to the indexes of the observations)
// * nhor = the horizon for the IRF
// * pvalue = the p-value of the confidence band
// * impulse_mode = the mode used to calculate the impulse
//   response (optional):
//   - 'unitary' for unitary shocks (default)	
//   - 'std_dev' for 1 standard deviation shock calcualted at
//     each  date t
//   - 'av std' for 1 standard deviation shock averaged over the
//     whole estimation period
// * plt = the way irfs will be graphed (optional):
//  - 'noplt' if the user does not want to plot the IRF
//  - 'isolated' if the user wants to graph the irfs separately
//    at each period (and with their confidence bands)
//  - 'together' if the user wants to graph on the same graph
//    the irfs at the different periods (without their
//    confidence bands)
//  - 'all' if the user wants to graph according to both
//    options 'isolated' and 'together' (default)
// ------------------------------------------------------------
// OUTPUT:
// * irf_med = a (ndates x nendo x nendo x (nhor+1)) hypermatrix,
// collecting all median IRF
// * irf_mean = a (ndates x nendo x nendo x (nhor+1)) hypermatrix,
// collecting all average IRF
// * irf_low = a (ndates x nendo x nendo x (nhor+1)) hypermatrix,
// collecting all lower band IRF
// * irf_up = a (ndates x nendo x nendo x (nhor+1)) hypermatrix,
// collecting all upper band IRF
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted a lot from a Matlab program by Gary
// Koop and Dimitris Korobilis
// (http://personal.strath.ac.uk/gary.koop)
 
[nargout,nargin]=argn(0)
opt_plt=[%t %t]
if nargin == 6 then
   select plt
   case 'noplt' then
      opt_plt=[%f %f]
   case 'isolated' then
      opt_plt=[%t %f]
   case 'together' then
      opt_plt=[%f %t]
   case 'all' then
      opt_plt=[%t %t]
   end
end
if nargin < 5 then
   impulse_mode='unitary'
end
 
db_At=r('.dat At')
db_Bt=r('.dat Bt')
db_Htsd=r('.dat Htsd')
M=size(r('y'),2)
nlag=r('nlag')
namey=r('namey')
K = M+nlag*(M^2);
 
select impulse_mode
case 'unitary' then
   name_shock='a unit'
   size_shock=ones(M,1)
case 'std' then
   name_shock='std'
case 'av std' then
   name_shock= 'an average std'
   Sigt_postmean=r('Sigt_postmean')
   size_shock=mean(Sigt_postmean,1)'
else
   error('not an available option for impulse mode: '+impulse_mode)
end
 
 
if typeof(dates) == 'string' then
   boun=r('bounds')
   bound0=date2num(boun(1))
   daten=date2num_m(dates)-bound0
else
   daten=dates
   dates=string(dates)
end
 
irf_low=zeros(size(dates,'*'),M,M,nhor+1)
irf_med=irf_low
irf_mean=irf_low
irf_up=irf_low
 
 
res=tlist(['results' ; 'meth' ; 'estimation res' ],'tvp var irf',r)
irfs=zeros(M*(nhor+1),M,r('nrep'))
impresp = zeros(M,M*(nhor+1)); // matrix to store initial response at each period
ind_Bt=[1:K]
ind_Bt([1:M]*(M*nlag+1))=[]
 
for date_i = 1:size(dates,'*')
   ndb=0
   dat=daten(date_i)
 
   for db=1:size(db_Bt,1)
      load(db_Bt(db))
      Bt=Bt(:,dat,:)
      load(db_Htsd(db))
 
      for rep=1:size(Bt,3)
         bet=matrix(Bt(ind_Bt,1,rep),M*nlag,M)
         // ------------Identification code I:
         // st dev matrix for structural VAR
         shock = Htsd((dat-1)*M+1:dat*M,:,rep); // First shock is the Cholesky of the VAR covariance
         if impulse_mode ~= 'std' then
            diagonal = diag(diag(shock)./size_shock);
            shock = shock*inv(diagonal); // Initial shock
         end
         // Now get impulse responses for 1 through nhor future periods
         irfs(:,:,rep+ndb)=irf0(bet,nhor,M,nlag,shock)
      end
      ndb=ndb+size(Bt,3)
 
   end
 
   for j=1:M
      if opt_plt(1) then
         scf()
      end
      for k=1:M
         irf_jk=zeros(r('nrep'),nhor+1)
         irf_jk(:,:)=(matrix(irfs(k+[0:M:M*nhor],j,:),nhor+1,r('nrep')))'
         irf_low0=quantile(irf_jk,pvalue/2)
         irf_med0=quantile(irf_jk,0.5)
         irf_mean0=mean0(irf_jk,'r')
         irf_up0=quantile(irf_jk,1-pvalue/2)
         irf_low(date_i,j,k,:)=irf_low0
         irf_med(date_i,j,k,:)=irf_med0
         irf_mean(date_i,j,k,:)=irf_mean0
         irf_up(date_i,j,k,:)=irf_up0
 
         if opt_plt(1) then
            subplot(M,1,k)
            strleg='median;'+string(100*(1-pvalue))+'% confidence band'
 
            pltseries0([irf_med0' irf_low0' irf_up0'],[],...
                    dates(date_i)+': response of '+namey(k)+' to '+ name_shock+' shock to '+namey(j),...
                    string(0:nhor),-1,'leg='+strleg,'styleg=7','color=[1 2 2]','style=[1 2 2]')
         end
      end
   end
end
 
if opt_plt(2) then
    strleg='leg='+strcat(dates,';')
    for j=1:M
       scf()
       for k=1:M
          subplot(M,1,k)
          pltseries0(squeeze(irf_med(:,j,k,:))',[],'response of '+namey(k)+' to '+ name_shock+' shock to '+namey(j)+' at different dates',...
                     string(0:nhor),-1,strleg,'styleg=7')
        end
    end
end
 
endfunction
