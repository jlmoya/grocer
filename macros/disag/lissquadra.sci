function retal = lissquadra(retal)

// PURPOSE: realizes:
//       Min sum[ ut(t)-ut(t-1) ]^2
//         w.r sum[ ut(t) ] = ua
// with ut high frequency residuals and ua low frequency ones
// ------------------------------------------------------------

ua = retal('forecasted lf resid')

N = size(ua,1)
s = retal('freq ratio')

MT=s*tril(ones(N,N),-1).*.ones(1,s)+eye(N,N).*.[s:-1:1];

// Lagrangian is:                   
//            L = (d*ut)'(d*ut) + 2*lambda'*[d*t*(ut(1,1) d*ut)' - ua]                 
//                  = (d*ut)'(d*ut) + 2*lambda'*[m1*ut(1,1)+mt*(d*ut)- ua]              


m1 =MT(:,1)
mt = MT(:,2:$)

//    First order conditions are:                        
//        (1) lambda'*m1 = 0                   
//        (2) d*ut = mt'*lambda       
//        (3) m1*ut(1,1)+mt*(d*ut) = ua                                            
//        hence:                     
//        (3') lambda = inv(mt*mt')*[ua-m1*ut(1,1)]                    


mtmtp_inv_m1=(mt*mt')\m1
ut11 = (mtmtp_inv_m1'* ua)/(m1'*mtmtp_inv_m1 )
lambda = (mt * mt')\(ua - m1*ut11)
mx = mt'*lambda

ut = cumsum([ut11 ; mx])

retal(1)($+1) = 'hf resid'
retal('hf resid') = ut

endfunction
