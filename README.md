# glpkAPI.DEA
The purpose of our work was to use the R package 'glpkAPI' for DEA models which have been programmed in gmpl (MathProg). This library is optimal for DEA models using .mod files; using glpkAPI for manually building the model and data from scratch is an arduous task better suited for other packages such as Benchmarking. Likewise, editing the model is easier done by editing the .mod file in an editor such as Gusek, or even R, than it is through glpkAPI.   

The wrapper function we have created allows for gmpl DEA models to use the glpkAPI interface to be solved by GLPK. 

However, our wrapper function enables one to input data into an R dataframe for inputs and outputs and calculate the efficiencies and dual weights by modifying the associated .mod and .dat files. 

The .mod files are separate from the data, specified in a .dat format. This decoupling allows for a general-use .mod file for running the same DEA problem with different datasets by specifying the data and permutations of the model (IE input-oriented VRS, input-oriented CRS, etc). The user will specify which permutations are to be used.  

The work done here is primarily a wrapper function written to separate some of the more difficult-to-use glpkAPI functionality from the end-user. The user, when prompted, selects the appropriate configuration of the .mod file to the task (for example, output-oriented CRS), and the data file, as a .dat. The function then loads the required glpkAPI library, and carries forward the model. It allocates the problem and workspace, reads the model file and data file the user selects, builds the problem, and solves it. The function returns primal values, and, if dual = TRUE is selected, also returns dual weights. 

The primal values are formatted as a list of thetas and as a lambda matrix, and duals as a list of duals and a dual matrix. These objects are returned to the user as dataframes. 
