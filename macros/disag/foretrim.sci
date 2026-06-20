function retal = foretrim(retal,pred)

retal(1)($+1) = 'high freq yhat'

x = retal('x trim aug') 
bet = retal('beta')
retal('high freq yhat') = x*bet + retal('high freq resid')

endfunction
