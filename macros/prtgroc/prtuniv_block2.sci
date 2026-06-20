function prtuniv_block2(res,out)
    
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'DW(0) ='+string(res('dw')))    
    
    
endfunction