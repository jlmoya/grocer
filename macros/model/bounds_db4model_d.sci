function b=bounds_db4model_d()
    
global GROCERDIR;
// load the model small:
load(GROCERDIR+'data\small.dat')
// load the database small_db:
load(GROCERDIR+'data\small_db.dat')
//now, find the admissible for the saall model and the small_db data base
b=bounds_db4model(small,small_db)
    
endfunction