function [baseGraphType] = getBaseGraphType(tbSizeBits,mcs)

mcsEcrTable = [0.12, 0.15, 0.19, 0.25, 0.30, 0.37, 0.44, 0.51, 0.59, 0.66,... // ECRs of MCSs, QPSK (M=2)
                0.33, 0.37, 0.42, 0.48, 0.54, 0.60, 0.64,... %ECRs of MCSs, 16QAM (M=4)
                0.43, 0.46, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.89, 0.93]; %ECRs of MCSs,64QAM (M=6)

ecr = mcsEcrTable(mcs+1);

baseGraphType = 1;
if tbSizeBits <= 292 || ecr <= 0.25 || (tbSizeBits <= 3824 && ecr <= 0.67)
    baseGraphType = 2;
end

end

