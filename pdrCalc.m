%% setup
RRI = 100;%ms
tau = 1000/RRI;%Hz
PKeep = 0.0;
T0 = 100;%ms
T0Proc = 1;%slots
T1 = 3;%slots
T2 = 53;%slots
mu = 0;%numerology indicator, mu=[0,1,2,3] = subcarrier spacing = [15,30,60,120] kHz
fc = 5.89;%GHz
Pt = 23;%dBm
rbPerSubchannel = 50;
subchannelsPerChannel = 4;
pathLossModel = "3GPP-V2V-Highway";
sensingThreshold = -70;%dBm,
N0 = 10^((30-101)/10);
N0dBm = 10*log10(N0) - 30;
ueSeparation = 5;%m
laneSeparation = 4;%m
numLanes = 2;
rhoUe = 1/(ueSeparation*laneSeparation);


Nr = subchannelsPerChannel*(T2-T1+1);%size of the selection window
T = formT(Nr);

dStep = ueSeparation;
dMax = 3000;
d = dStep:dStep:dMax;%m
%% deltaHd

lambda = (tau/(1-PKeep))/((1/(1-PKeep) + (1/(1000*2^mu))*((T1+T2)/2)));

deltaHd = lambda/1000;

%% deltaFTR

pathLoss = 32.4 + 20*log10(d) + 20*log10(fc);%d in meters, fc in GHz
meanPr = Pt-pathLoss;
sigmaSF = 3.3;

deltaFTR = .5*(1 - erf((Pt-pathLoss-sensingThreshold)/(sigmaSF*sqrt(2))));%= normcdf(d,Pt-pathLoss-sensingThreshold,sigmaSF);


%% deltaCol


if strcmp(pathLossModel,"3GPP-V2V-Highway")
    txPathLoss = 32.4 + 20*log10(d) + 20*log10(fc);%d in meters, fc in GHz
    intPathLoss = 32.4 + 20*log10(d) + 20*log10(fc);%d in meters, fc in GHz
    meanTxPr = Pt-txPathLoss;
    meanIntPr = Pt-intPathLoss;
    sigmaSF = 3.3;
    
    
    pSinr = zeros(length(d));
    
    
    
    for i = 1:length(meanTxPr)
        i
        for j = 1:length(meanIntPr)
            
            s = linspace(meanPr(i)-10*log10(10^(meanIntPr(j)/10)+N0/1000)-12*sigmaSF,meanPr(i)-10*log10(10^(meanIntPr(j)/10)+N0/1000)+12*sigmaSF,2000);
            
            fSINR = normpdf(s,meanPr(i)-10*log10(10^(meanIntPr(j)/10)+N0/1000),sqrt(2)*sigmaSF);
            
            temp = SINR2BLER(s,rbPerSubchannel,200*8,14).*fSINR;
            
            pSinr(i,j) = trapz(s,temp);%row it d_{tx,rx}, column is d_{int,rx}
            
        end
    end
    
    pInt = pSinr;
    
else
    disp("path loss model not supported")
    return
end

dtint = d;


C1 = lambda*(T2-T1+1)*(1/1000)*rhoUe*(2*laneSeparation*numLanes);
C2 = lambda*((T2-T1+1)^2)/(100)*(1/1000)*rhoUe*(2*laneSeparation*numLanes);
Nrx = trapz(d,C1*(1-deltaFTR));
TB = formT(subchannelsPerChannel*round(((T2-T1+1)^2)/(100)));


Nrxt = zeros(1,length(dtint));%number recieved exclusively by UEtx
NrxB = zeros(1,length(dtint));%number sensed by both UEtx and UEint
CEx = zeros(1,length(dtint));%number of resources excluded by both UEtx and UEint
NExt = zeros(1,length(dtint));
OEx = zeros(1,length(dtint));

for i = 1:length(dtint)
    
    dtemp = 1:dStep:(dMax+dStep*i);
    
    deltaSenShifted = [zeros(1,i),deltaFTR];
    deltaSenPadded = [deltaFTR,ones(1,i)];
    
    deltaSenFlippedandshifted = [ones(1,i),fliplr(deltaFTR)];
    
    if i > 1
        Nrxt(i) = trapz(dtemp,C1/2*(1 - deltaSenPadded).*(deltaSenShifted)) + ...
                trapz(dtemp(1:i),C1/2*(1 - deltaSenPadded(1:i)).*(deltaSenFlippedandshifted(1:i))) + ...
                trapz(dtemp(i:end),C1/2*(deltaSenShifted(i:end)).*(1 - deltaSenPadded(i:end)));
    else
        Nrxt(i) = trapz(dtemp,C1/2*(1 - deltaSenPadded).*(deltaSenShifted)) + ...
                trapz(dtemp(i:end),C1/2*(deltaSenShifted(i:end)).*(1 - deltaSenPadded(i:end)));
    end
    
    if i > 1
        NrxB(i) = trapz(dtemp,C2/2*(1 - deltaSenPadded).*(1 - deltaSenShifted)) + ...
                trapz(dtemp(1:i),C2/2*(1 - deltaSenPadded(1:i)).*(1 - deltaSenFlippedandshifted(1:i))) + ...
                trapz(dtemp(i:end),C2/2*(1 - deltaSenShifted(i:end)).*(1 - deltaSenPadded(i:end)));
    else
        NrxB(i) = trapz(dtemp,C2/2*(1 - deltaSenPadded).*(1 - deltaSenShifted)) + ...
                trapz(dtemp(i:end),C2/2*(1 - deltaSenShifted(i:end)).*(1 - deltaSenPadded(i:end)));
    end
    
    PExCEx = TB^round(NrxB(i));
    
    CEx(i) = sum([0:(subchannelsPerChannel*round(((T2-T1+1)^2)/(100)))].*PExCEx(1,:));
    
    PExNExt = T^round(Nrxt(i));
    
    NExt(i) = sum([0:(Nr)].*PExNExt(round(CEx(i))+1,:)) - CEx(i);
    
    OEx(i) = (NExt(i)^2)/(Nr - CEx(i));
    
end

PExNEx = T^round(Nrx);

NEx = sum([0:(Nr)].*PExNEx(1,:));

pSim = (1 - (1 - (1 - PKeep)/(tau))*(1 - deltaFTR)).*((Nr - CEx - OEx)./(Nr - Nrx).^2);

temp = ones(length(d),1);
for i = 1:length(d)
    for j = 1:length(d)
        if i + j > length(d) && abs(i-j) < 1
            temp(i) = temp(i)*(1 - pInt(i,j)*pSim(end))^2*(1 - pInt(i,j)*pSim(1))^2;
        elseif abs(i-j) < 1
            temp(i) = temp(i)*(1 - pInt(i,j)*pSim(i+j))^2*(1 - pInt(i,j)*pSim(abs(1)))^2;
        elseif i + j > length(d)
            temp(i) = temp(i)*(1 - pInt(i,j)*pSim(end))^2*(1 - pInt(i,j)*pSim(abs(i-j)))^2;
        else
            temp(i) = temp(i)*(1 - pInt(i,j)*pSim(i+j))^2*(1 - pInt(i,j)*pSim(abs(i-j)))^2;
        end
    end
end

deltaCol = 1-temp;

%% final touches
pdr = (1 - deltaHd)*(1 - deltaFTR).*(1 - deltaCol');




