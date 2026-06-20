function small2=addeq_d()
    
global GROCERDIR
// load the model small
load(GROCERDIR+'data\small.dat')

// add the equation 'cb' to the model small, without recalculating all 
// stuff needed to simulate the model and save the result in a new model
// called small2
small2=addeq(small,'bottom','cb','cb=td_p6_d3-td_p7_d3','notransf')   
    
endfunction