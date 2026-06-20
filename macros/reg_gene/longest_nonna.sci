function per=longest_nonna(y,dir)


indna=find(sum(isnan(y),dir)~=0)
nobs=size(y,3-dir)
seq=1:nobs
seq(indna)=[]
seq=[0 , seq , nobs+1]
del_seq=seq(2:$)-seq(1:$-1)-1
ind_break=[find(del_seq~=0) ]
length_break=[0 , cumsum(del_seq(ind_break))]
start_nonna= [1 , ind_break]+length_break
end_nonna=[ind_break-1+length_break(1:$-1) ,nobs]
[junk,ind_maxnonna]=max(end_nonna-start_nonna)
per=start_nonna(ind_maxnonna):end_nonna(ind_maxnonna)

endfunction
