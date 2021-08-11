# code-for-Modeling-of-NR-C-V2X-Mode-2-Packet-Delivery-Ratio
Code used to produce results featured in "Modeling of NR C-V2X Mode 2 Packet Delivery Ratio" by Collin Brady and Sumit Roy

pdrCalc.m is the main file to produce our model of packet delivery ratio
formT.m produces the markov chain transition matrix based on the parmaeters set in pdrCalc.m
calculateSinrEff.m, getBaseGraphType.m, getSinr2BlerMap.m, and SINR2BLER.m are all used to calculate the BLER as a function of SINR (and SNR) based on the error model in "New Radio Physical Layer Abstraction for System-Level Simulations of 5G Networks" by Lagen et al.
