glpkAPIDEA <- function(Mod_path, Data_path, RTS, Orientation, Dual = FALSE)
{
  # Steps:
  #
  #   1. Data Handling
  #
  #     a. If X and Y are null (data is in a .dat file somewhere)
  #        User chooses the .dat file
  #     b. If X and Y are not null (user wants to pass in their dataframe)
  #        Have the user choose the default .dat file
  #        Read in the .dat file and replace a string with the data
  #        Write the data to the default file
  #
  #       Note: 1. a. is currently done outside of this wrapper function
  #             to ensure the data is read in properly.
  #       Note: 1. b. is not yet supported.
  #
  #   2. Model Building
  #
  #     a. Read in the .mod file (input vs output mod files)
  #     b. Check which type of parameter RTS is desired
  #        Replace the string in .mod file that affects which set of constraints are used
  #
  #   3. Model Running
  #
  #     * Create the problem and workspace (see glpkAPI vignette)
  #     * Load the model
  #     * Load the data
  #     * Solve the problem

  #   4. Results
  #
  #     * Check if Dual = TRUE
  #       * If yes, get dual weights
  #
  #     * Get the Primal values
  #     * Decompose into Thetas and lambda matrix

  # Step 1
  # a.
  # b.

  # Step 2

  mod_filepath <- Mod_path #User passes in the mod and .dat filepaths.
  data_filepath <- Data_path

  rts_string <<- toupper(RTS) #provides some robustness against user inputs
  orientation_string <- toupper(Orientation)

  ### Returns to Scale strings to replace the "### RTS" character string in our mod file

  if (rts_string == "CRS")
  {
    rts_replace_string <<- "s.t. PI1{td in dmus}: sum{d in dmus} lambda[d,td] >= 0;"
  }

  if (rts_string == "VRS")
  {
    rts_replace_string <<- "s.t. PI1{td in dmus}: sum{d in dmus} lambda[d,td] = 1;"
  }

  if (rts_string == "DRS")
  {
    rts_replace_string <<- "s.t. PI1{td in dmus}: sum{d in dmus} lambda[d,td] >= 1;"
  }

  if (rts_string == "IRS")
  {
    rts_replace_string <<- "s.t. PI1{td in dmus}: sum{d in dmus} lambda[d,td] <= 1;"
  }


  # Step 2

  ### Read in the file

  mod_file <- readLines(mod_filepath)
  mod_file <- gsub(pattern = "### RTS Constraint", replace = rts_replace_string, x = mod_file)
  writeLines(mod_file, con= mod_filepath)

  # Step 3.

  ### Creating the glpkAPI model, as in the glpkAPI vignette.


  mip <- initProbGLPK()
  setProbNameGLPK(mip, "DEA Example")
  dea <- mplAllocWkspGLPK()
  ### Since the model and data are in separate files, it is necessary
  ### to read in both.
  result <- mplReadModelGLPK(dea, mod_filepath, skip=0)
  mplReadDataGLPK(dea, data_filepath)

  result <- mplGenerateGLPK(dea)
  result <- mplBuildProbGLPK(dea, mip)

  solveSimplexGLPK(mip)
  mplPostsolveGLPK(dea, mip, GLP_MIP)
  solution_list <- getColsPrimGLPK(mip)

  mod_file <- readLines(mod_filepath)

  mod_file[25] <- "### RTS Constraint" # Based on our file structure,
  ### line 25 is where our RTS constraint is.

  writeLines(mod_file, mod_filepath)

  # Step 4.

  # solution list returned by glpkAPI as list where first x elements are DMUs and the
  # next x^2 elements are  the lambda matrix as a list.
  # To get the number of DMUs, one needs to solve a simple quadratic equation
  # of the form x^2 + x = c for the positive root of x. x^2 + x = length of solution, so
  # for a = 1, b = 1, -c = length of solution. x = (-b + sqrt (b^2 - (4 *1 * -c) ) / 2a

  c <- length(solution_list)
  dmus <- (-1 + sqrt(1 + 4*c))/2

  if (Dual == "TRUE")
  {
    duals_solution_list <- getColsDualGLPK(mip)

    duals <- duals_solution_list[1:dmus]
    duals_mat_list <- round(duals_solution_list[dmus+1:length(duals_solution_list)], 6)

    duals_list <<- data.frame(c(1:dmus), duals_solution_list)
    duals_matrix <<- data.frame(matrix(duals_solution_list, nrow = dmus, ncol = dmus))
  }

  #first n elements are efficiency scores
  theta_list <<- solution_list[1:dmus]

  #rest next n^2 elements belong to n x n lambda matrix
  lambda_list <<- round(solution_list[dmus+1:length(solution_list)], 6)

  thetas <<- data.frame(c(1:dmus), theta_list)
  colnames(thetas) <<- c("DMU", "Efficiency")

  lambdas <<- data.frame(matrix(lambda_list, nrow = dmus, ncol = dmus))
  colnames(lambdas) <<- 1:dmus
  rownames(lambdas) <<- 1:dmus
}
