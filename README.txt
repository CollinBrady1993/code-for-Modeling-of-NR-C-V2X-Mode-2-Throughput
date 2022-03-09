This GitHub contains all code necessary to reproduce the results of "Modeling of NR C-V2X Mode 2 Throughput" by Collin Brady, Liu Cao and Sumit Roy. 

The folder titled Matlab contains all Matlab scripts and functions to 
	1) Generate the curves of the model presented in "Modeling of NR C-V2X Mode 2 Throughput."
	2) Process the ns-3 data, which can be generated using the patch contained therein
The folder also contains the post-processed curves (not the raw data) for the simulated data.
	
The folder titled ns-3 contains a patch to generate my version of CTTC's NR C-V2X model (described in "3GPP NR V2X Mode 2: Overview, Models and System-Level Evaluation" by Ali et al.)
This allows the generation of raw data to create the simulation curves in "Modeling of NR C-V2X Mode 2 Throughput". The folder also contains instructions on obtaining the base code to patch. 
The raw data cannot be shared on GitHub due to file size limits (the .db files range from .42 gb to 1.41 gb). If the reader is truly interested in getting the raw .db files contact the owner 
of this repo (CollinBrady1993 on github), and we can try to work something out.
