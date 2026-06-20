function [yy,yy_m,yy_med,yy_s,yy_cov,yy_cor] = MSVAR_Sample(M_data,d_option);
 
// PURPOSE: Transforms data in their demeaned or studentized
// values and calculate some statistics on the transformed data
// ------------------------------------------------------------
// INPUT:
// * M_mat = a (T x N) matrix
// * d_option = a string
//   d_option = 'none if the data are not transformed
//   d_option = 'dem' if the data are demeaned
//   d_option = 'stu' if the data are studentized
// ------------------------------------------------------------
// OUTPUT:
// * yy = a (T x N) vector of transformed data
// * yy_m = a (1 x N) vector of their means
// * yy_med = a (1 x N) vector of their medians
// * yy_s = a (1 x N) vector of their standard deviation
// * yy_cov = a (N x N) matrix of their covariance matrix
// * yy_cor = a (N x N) matrix of their corelation matrix
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
if M_data == [] then
   yy=[]
   yy_m=[]
   yy_med=[]
   yy_s=[]
   yy_cov=[]
   yy_cor=[]
 
else
 
   d_option=strsubst(d_option,' ','')
 
   if d_option == 'stud' then
   //  d_option= 'stu' Standardized variables
   // deal the case of a constant variable: a constant cannot be studentized,
   // since its variance is 0
      indcte=search_cte(M_data)
      yy=M_data
      [N,p]=size(M_data)
      r=[1:p]
      r(indcte)=[]
      if r ~= [] then
         yyn=studentize(M_data(:,r));
         yy(:,r)=yyn
      end
 
   elseif d_option == 'dem' then
   // demeaned variables
      indcte=search_cte(M_data)
      yy=M_data
      [N,p]=size(M_data)
      r=[1:p]
      r(indcte)=[]
      if r ~= [] then
         yy(:,r)=M_data(:,r)- (mean0(M_data(:,r),'r') .*. ones(N,1))
      end
 
   else
   //  no transformation
      yy=M_data;
   end
 
   yy_med=median(yy,'r');
   yy_m=mean0(yy,'r');
   yy_s=st_dev(yy,'r');
   yy_cov=mvvacov(yy);
 
   if and(yy_cov ~= 0) then
      yy_cor=var2cor(yy_cov);
   else
      yy_cor=[]
   end
end
endfunction
