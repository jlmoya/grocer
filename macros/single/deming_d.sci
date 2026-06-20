function deming_d()


// provides the deming regression presented at:
// http://www.real-statistics.com/regression/deming-regression/deming-regression-basic-concepts/
global GROCERDIR;
load(GROCERDIR+'\data\deming_d.dat')
res = deming('y','x','lambda=0.4')

endfunction
