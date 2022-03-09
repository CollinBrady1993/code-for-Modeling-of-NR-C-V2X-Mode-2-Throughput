This folder contains all matlab files used to calculate the models 
presented in Modeling of NR C-V2X Mode 2 Throughput by Brady et al.

FigureGenerator.m will generate the three figures which appear in the paper
while pdrCalc.m can be used to generate your own curves using the various 
parameters discussed in the paper.

ns3DataAnalysis.m can process the data from the ns-3 simulations which can 
be run separately (see the other folder of this repo). We have included 
some csv files which contain the curves that appear in the paper as the raw 
data is significantly larger than Github's file size limit (400 MB for the 
smallest)