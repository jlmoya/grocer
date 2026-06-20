function compare_dblist(listvar,threshold,base1,base2)
 
// PURPOSE: compare 2 the values of a set of variables between
// 2 databases and lists those which differ by an amount
// greater than a threshold
// ------------------------------------------------------------
// INPUT:
// * listvar = a string vetcor, the namesof the variables
//   to compare
// * threshold = the threhsold used to assess that variables
//   are different
// * base1 = a tsmat
// * base2 = a tsmat
// ------------------------------------------------------------
// OUTPUT:
// NOTHING: names of variables that are sufficently different
// arre displayed on screen
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
name1=base1('names')
name2=base2('names')
 
index1=[]
index2=[]
// find the column corresponding to the variables in both tsmats
for i=1:size(listvar,'*')
   index1=[index1 find(name1 == listvar(i)) ]
   index2=[index2 find(name2 == listvar(i)) ]
end
 
base1_dates=base1('dates')
base2_dates=base2('dates')
date1=max(base1_dates(1),base2_dates(1))
date2=min(base1_dates($),base2_dates($))
 
data1=base1('series')([date1:date2]-base1_dates(1)+1,index1)
data2=base2('series')([date1:date2]-base2_dates(1)+1,index2)
 
delta_base=max(abs(data2-data1),'r')
delta_base_sup=find(delta_base > threshold)
 
mat2prt=["variables with problem    " "max difference" ; name1(index1(delta_base_sup)) string(delta_base(delta_base_sup))]
printmat(mat2prt,%io(2))
 
endfunction
