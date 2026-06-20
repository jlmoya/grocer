function [dx,lagx]=diffandlag(x,lag)
 
dx = x(2:$,:)-x(1:$-1,:);
exo=trimr([mlag(dx,grocer_k) exo_ct],grocer_k+1,0)
lagx = trimr([[0 ; x(1:$-1)] exo_lt],grocer_k+1,0)
dx=dx(grocer_k+2:$,:)
 
endfunction
