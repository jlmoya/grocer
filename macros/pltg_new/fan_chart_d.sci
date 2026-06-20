function [x]=fan_chart_d()
 
 
 
//x0=[0.2 0.0 0.3]
// x0 is median of the distribution
x0=[0.1 0.1 0.3]
x=[]
for i=1:19
   n=cdfnor('X',0,1,0.05*i,1-0.05*i)
   x=[x ; x0+[0.28 0.33 0.37] * n]
end
// the bands have been taken from the normal distribution
x=[0.64*ones(19,1) x]
// add the starting point and draw the fan chart
fan_chart(x,'2007T'+string(1:4),15,'blue')
 
endfunction
