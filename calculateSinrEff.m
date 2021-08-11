function [sinrEff] = calculateSinrEff(sinr,rbPerSc,mcs,a,b)
%from the ns-3 implementation:
%// it follows: SINReff = - beta * ln [1/b * (sum (exp (-sinr/beta)) + a)]
%// for HARQ-IR: b = sum (map.size()), a = sum_j(sum_n (exp (-sinr/beta))) (for previous retx, till j=q-1)
%// for HARQ-CC: b = map.size(), a = 0.0 (SINRs are already combined in sinr input)


betaTable = [1.6, 1.61, 1.63, 1.65, 1.67, 1.7, 1.73, 1.76, 1.79, 1.82,...
            3.97, 4.27, 4.71, 5.16, 5.66, 6.16, 6.5, 9.95, 10.97,...
            12.92, 14.96, 17.06, 19.33, 21.85, 24.51, 27.14, 29.94,...
            32.05, 34.28];

beta = betaTable(mcs+1);

sinrExpSum = rbPerSc*exp(-sinr/beta);%sinr in this function needs to be in linear, so a conversion may need to be done

sinrEff = -beta * log ((a + sinrExpSum)/b);

end

