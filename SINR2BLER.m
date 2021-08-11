function [BLER] = SINR2BLER(sinr,rbPerSc,tbSizeBits,mcs)
%This function is the top level implementation of the model in "New Radio 
%Physical Layer Abstraction for System-Level Simulations of 5G Networks,"
%by Lagen et al. This code is heavily influenced by the ns-3
%implementation. It ignores the sinr history as it's only being used for
%modeling not simulations. It also changes the variable "map" to be
%"rbPerSc" (resource blocks per subchannel) as the SINR is assumed flat 
%over one subchannel, but the model cares about the number of RBs used for
%transmission which in a sidelink context is rbPerSc.

%need to get the cbSize (code block size in bits) before this
baseGraphType = getBaseGraphType(tbSizeBits,mcs);%can be first or second (1 or 2), the graph type is related to the LDPC coding, two types are supported in NR

SINR = calculateSinrEff(sinr,rbPerSc,mcs,0,rbPerSc);

B = tbSizeBits + 24;%input to code block segmentation plus crc attachment

cbler = mappingSinrBler(SINR,mcs,B);
if baseGraphType ~= 1
    BLER = 1 - (1-cbler).^baseGraphType;
else
    BLER = cbler;
end
end
















