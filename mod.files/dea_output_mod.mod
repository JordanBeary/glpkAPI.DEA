### SETS ###

set dmus;       # Decision Making Units (DMU)
set inputs;     # Input parameters
set outputs;    # Output parameters
  
### PARAMETERS ###

param input_data{dmus,inputs} >= 0; # Declare set of input data #
param output_data{dmus,outputs} >= 0; #Declare set of output data#

### PROGRAM ###

var phi{dmus} >= 0;#Declare set efficiency scores,oneforeach DMU #
var lambda{dmus, dmus} >= 0; #Declare 2D set of Envelopment multipliers, lambdas #

maximize inefficiency: sum{td in dmus} phi[td];  # Solve for all DMUs at once #

s.t. input_upper_limit{i in inputs, td in dmus}:
    sum{d in dmus} lambda[d,td]*input_data[d,i] <= input_data[td,i];
   # Each DMU's comparator's input (left hand side)  must be at least as small as the one studied #
s.t. output_lower_limit{o in outputs, td in dmus}:
    sum{d in dmus} lambda[d,td]*output_data[d,o] >= phi[td]*output_data[td,o];
   # Each DMU's comparator's output (left hand side)  must be no less than the one studied #
### RTS Constraint

### SOLVE AND PRINT SOLUTION ###

solve;

end;