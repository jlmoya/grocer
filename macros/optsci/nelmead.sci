function [grocer_nm_b0,grocer_nm_f0,grocer_ended]=nelmead(grocer_nm_fkt,grocer_nm_x,grocer_nm_epsilon,grocer_nm_nitermax,varargin);
 
[nargout,nargin] = argn(0)
if nargin == 2 then
   grocer_nm_epsilon=1E-10;
   grocer_nm_nitermax=%inf;
end
 
select typeof(grocer_nm_fkt)
case 'list' then
   varargin=grocer_nm_fkt
   varargin(1)=null()
   grocer_nm_fkt=grocer_nm_fkt(1)
 
case 'function' then
   varargin=list()
 
else
   error(typeof(grocer_nm_fkt)+' not a valid type for first argument')
end
 
grocer_nm_alpha=1;
grocer_nm_bet=0.5;
grocer_nm_gam=2;
grocer_nm_p = size(grocer_nm_x,1);
 
// Step A: Intialisation of simplex
// and computing function values
 
grocer_nm_s = [grocer_nm_x (ones(1,grocer_nm_p).*.grocer_nm_x + 0.1*eye(grocer_nm_p,grocer_nm_p))]
grocer_nm_f = zeros(grocer_nm_p+1,1);
 
for grocer_nm_i=1:grocer_nm_p+1
   grocer_nm_f(grocer_nm_i)=real(grocer_nm_fkt(grocer_nm_s(:,grocer_nm_i),varargin(:)))
end
[grocer_nm_f0,grocer_nm_ind0]=min(real(grocer_nm_f))
grocer_nm_b0=grocer_nm_s(:,grocer_nm_ind0)
 
grocer_nm_niter=1
grocer_nm_stdev_i=sqrt(sum(grocer_nm_f -sum(grocer_nm_f/grocer_nm_p)).^2/(grocer_nm_p-1))
grocer_nm_stdev=grocer_nm_stdev_i
loop=%f
 
while real(grocer_nm_stdev_i - grocer_nm_epsilon) > 0 & ~loop & real(grocer_nm_niter - grocer_nm_nitermax) < 0
   grocer_nm_niter=grocer_nm_niter+1
   grocer_nm_fs=[grocer_nm_f grocer_nm_s']
 
// Step B: Ordering
   [grocer_nm_v,grocer_nm_indv]=gsort(grocer_nm_fs(:,1),'g','i')
   grocer_nm_f=grocer_nm_fs(grocer_nm_indv,1)
   grocer_nm_s=grocer_nm_fs(grocer_nm_indv,2:$)'
   grocer_nm_xo=sum(grocer_nm_s(:,1:grocer_nm_p),'c')/grocer_nm_p
 
// Step C: Compute Centroid
   grocer_nm_xr=(1+grocer_nm_alpha)*grocer_nm_xo - grocer_nm_alpha*grocer_nm_s(:,grocer_nm_p+1)
   grocer_nm_fr=grocer_nm_fkt(grocer_nm_xr,varargin(:))
 
// Step D: Reflection
   if real(grocer_nm_fr - grocer_nm_f(1)) < 0 then
 
// Step E: Comparison of fo with min-f and substitution of edge with max-f
      grocer_nm_xe=(1-grocer_nm_gam)*grocer_nm_xo+grocer_nm_gam*grocer_nm_xr
      grocer_nm_fe=grocer_nm_fkt(grocer_nm_xe,varargin(:))
 
      if real(grocer_nm_fe - grocer_nm_f(1)) < 0 then
         grocer_nm_s(:,grocer_nm_p+1)=grocer_nm_xe;
         grocer_nm_f(grocer_nm_p+1)=grocer_nm_fe;
      else
// if improvement occurs
         grocer_nm_s(:,grocer_nm_p+1)=grocer_nm_xr;
         grocer_nm_f(grocer_nm_p+1)=grocer_nm_fr;
      end
 
   elseif real(grocer_nm_fr - grocer_nm_f(grocer_nm_p)) < 0 then
      grocer_nm_s(:,grocer_nm_p+1)=grocer_nm_xr
      grocer_nm_f(grocer_nm_p+1)=grocer_nm_fr
 
   else
      if real(grocer_nm_fr - grocer_nm_f(grocer_nm_p+1)) < 0 then
 
// Step F: Contraction
         grocer_nm_s(:,grocer_nm_p+1)=grocer_nm_xr
         grocer_nm_f(grocer_nm_p+1)=grocer_nm_fr;
      end
      grocer_nm_xc=grocer_nm_xo + grocer_nm_bet*(grocer_nm_s(:,grocer_nm_p+1)-grocer_nm_xo)
      grocer_nm_fc=grocer_nm_fkt(grocer_nm_xc,varargin(:))
 
      if real(grocer_nm_fc - grocer_nm_f(grocer_nm_p+1)) < 0 then
 
// Step G: Comparison
         grocer_nm_s(:,grocer_nm_p+1)=grocer_nm_xc
         grocer_nm_f(grocer_nm_p+1)=grocer_nm_fc
      else
// Step H: Reducing the size
         grocer_nm_s=0.5*(grocer_nm_s(:,1) .*. ones(1,grocer_nm_p+1)+grocer_nm_s(:,1:grocer_nm_p+1));
         for grocer_nm_i=2:grocer_nm_p+1;
            grocer_nm_f(grocer_nm_i)=grocer_nm_fkt(grocer_nm_s(:,grocer_nm_i),varargin(:))
         end
      end
   end
   grocer_nm_stdev_i=real(sqrt(sum(grocer_nm_f -sum(grocer_nm_f/grocer_nm_p)).^2/(grocer_nm_p-1)))
   if or(grocer_nm_stdev_i == grocer_nm_stdev) then
       loop=%t
   else
      grocer_nm_stdev=[grocer_nm_stdev ; grocer_nm_stdev_i]
      [grocer_nm_fi,grocer_nm_indi]=min(real(grocer_nm_f))
      if real(grocer_nm_fi - grocer_nm_f0) < 0 then
         grocer_nm_f0=grocer_nm_fi
         grocer_nm_b0=grocer_nm_s(:,grocer_nm_indi)
      end
   end
end
 
grocer_ended=%t
if grocer_nm_niter == grocer_nm_nitermax & real(grocer_nm_stdev_i - grocer_nm_epsilon) > 0 then
   grocer_ended=%f
   write(%io(2),'warning: nelmead function has stopped because the maximum number of iterations has been reached','(a)')
end
 
endfunction
