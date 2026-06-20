function prtquali_R2(res,out)

matspec(1)='McFadden R2 = '+string(res('r2mf'))
write(out,matspec)
matspec(1)='Estrella R2 = '+string(res('rsqr'))
write(out,matspec)
write(out,'log-likelihood = '+string(res('llike')));
write(out,'LR-ratio = 2*(Lu-Lr) = '+string(res('lratio')))
write(out,'LR p-value  = '+string(1-cdfchi('PQ',res('lratio'),res('nvar')-1)))

endfunction
