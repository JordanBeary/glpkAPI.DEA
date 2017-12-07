setwd("C:\\Users\\J-Blazer\\Documents\\glpkAPI.DEA\\data-raw")
airline_datapath <- file("C:\\Users\\J-Blazer\\Documents\\glpkAPI.DEA\\dat.files\\airline.dat.dat")
devtools::use_data(airline_datapath)
