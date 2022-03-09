This github contains all code nescesary to reproduce the results of "Modeling of NR C-V2X Mode 2 Throughput" by Collin Brady, Liu Cao abd Sumit Roy. 

The folder titled Matlab contains all matlab scripts and functions to 
	1) Generate the curves of the model presented in "Modeling of NR C-V2X Mode 2 Throughput"
	2) Process the ns-3 data which can be generated using the patch contained therein
The folder also contains the post processed curves (not the raw data) for the simulated data.
	
The folder titled ns-3 contains a patch to generate my version of CTTC's NR C-V2X model (described in "3GPP NR V2X Mode 2: Overview, Models and System-Level Evaluation" by Ali et al.)
which allows the generation of raw data used to create the simulation curves in "Modeling of NR C-V2X Mode 2 Throughput". The folder also contains instructions on obtaining the base  code to patch. 
The raw data cannot be shared on github due to file size limits (the .db files range in size from .42 gb to 1.41 gb). If the reader is truely interested in getting the raw .db files contact the owner 
of this repo (CollinBrady1993 on github) and we can try to work something out.