To obtain the base version of the code to patch, you must request access (see https://5g-lena.cttc.es/download/) to the NR V2X software 
then install following the directions here: https://gitlab.com/cttc-lena/nr/-/blob/5g-lena-v2x-v0.1.y/README.md 
	 
After getting access and installing ns-3 it can be patched with the supplied patch file. Note that to generate the patch, the version of 
ns-3 used was "v2x-lte-dev" (from Feb 22 2022) while for NR the branch used was "5g-lena-v2x-v0.1.y". 
	 
When building, make sure to enable examples as the simulation file (./waf configure --build-profile=optimized --enable-examples is the configure command I use), 
titled "Modeling-of-NR-C-V2X-Mode-2-Throughput-Simulation.cc", is in contrib/nr/examples/nr-v2x-examples and can not be run without enabling them.
