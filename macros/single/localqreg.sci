function [q] = localqreg(y,x,tau,xstar);
 
grocer_ieee=ieee();
ieee(2);
 
_localqreg = 1;
[nr,nc]=size(x)
 
if size(x,2) ~= 1;
    error("not implemented for multiple independent variables.");
end;
 
n = size(x,1);
m = size(tau,1); 
p = size(xstar,1);
hmean = _qreg_h * 1.364 * stdc(x) * n^(-0.2);
h = hmean * (matmul(matmul(tau , (1-tau)) , norm_pdf(cdfni(tau))^(-2)))^(div(1,5));
q = zeros(p,m);
 
for i=1:p
   for j=1:m;
      w = norm_pdf(div((xstar(i) - x),h(j)));
      if _qreg_mtd == 2 ;
        r = qreg1(y,[ones(n,1) (xstar(i)-x),(xstar(i)-x).^2],tau(j),w,_qreg_solvelp1);
      else;
        r = qreg1(y,[ones(n,1) (xstar(i)-x)],tau(j),w,_qreg_solvelp1);
      end;
      q(i,j) = r('beta')(1);
   end;
end;
 pause
 
  if __output;
 
    header("localqreg - local quantile regression  ",0,_qreg_ver);
    print_gauss(" ");;
 
    st = "total observations:                              %*.*lf  ";
    print_gauss( ftos(n,st,15,0));
    st = "number of x''s:                                   %*.*lf  ";
    print_gauss( ftos(p,st,15,0));
 
    mask = ones(1,m+1);
    fmt =[ (["- *.*lf",15,6]);matmul((["*.*lf",11,4]) , ones(m,1))];
    omat =[ xstar,q];
 
    st = "x / tau (in %)      ";
    i = 1;
    while ~( and(i > m));
      st = st  + ftos(100*tau(i),"%lf     ",5,3);
      i = i + 1;
    end;
 
    oldwidth = sysstate(11,256);
    print_gauss(" ");;
    print_gauss( st);
    print_gauss( ascii(45*ones(length(st),1)));
     printfm(omat,mask,fmt);
    print_gauss( "/flush "," ");
    oldwidth = sysstate(11,oldwidth);
 
  end;
 
  _localqreg = 0;
 
//ndpclex;;
 

 
ieee(grocer_ieee);
 
endfunction;
