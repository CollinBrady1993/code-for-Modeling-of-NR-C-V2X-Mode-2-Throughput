function [PRRCalc] = prrCalcFunc(RRI,PKeep,T1,T2,ueSeparation,numLanes)

%% setup
%RRI = 100;%ms
tau = 1000/RRI;%Hz
%PKeep = 0.0;
%T1 = 2;%slots
%T2 = 33;%slots
mu = 0;%numerology indicator, mu=[0,1,2,3] = subcarrier spacing = [15,30,60,120] kHz
fc = 5.89;%GHz
Pt = 23;%dBm
PtWpHzPSCCH = 10^((Pt-30)/10)/(180000*10);%power spectral density in one PSCCH RB as calculated by ns-3, 10 RB used for PSCCH
rbPerSubchannel = 50;%total number
subchannelsPerChannel = 4;
sensingThreshold = 10*log10(4.5*10^(-17));%dBm,
gammaSPS = sensingThreshold;%can conceptually be set separately
N0dBm = -174;
%ueSeparation = 10;%m
%laneSeparation = 4;%m
%numLanes = 2;
rhoUe = 1/(ueSeparation);


Nr = subchannelsPerChannel*(T2-T1+1);%size of the selection window

dStep = ueSeparation;
dMax = 2000;
d = dStep:dStep:dMax;%m
%% deltaHd

deltaHd = tau/(1000*2^mu);

%% deltaFTR

pathLoss = 32.4 + 20*log10(d) + 20*log10(fc);%d in meters, fc in GHz
meanPr = 10*log10(PtWpHzPSCCH)-pathLoss;
sigmaSF = 3;

deltaFTR = .5*(1 - erf((meanPr-sensingThreshold)/(sigmaSF*sqrt(2))));%
deltaFTR2 = .5*(1 - erf((meanPr-gammaSPS)/(sigmaSF*sqrt(2))));%this is for the deltaCol calculation, needed if gammaSPS ~= gammaFTR

%% deltaPhy

meanSNR = meanPr - N0dBm;
deltaPhy = zeros(1,length(d));

for i = 1:length(meanPr)
    s = linspace(meanSNR(i)-12*sigmaSF,meanPr(i)-meanIntPr(j)+12*sigmaSF,2000);
    fSNR = normpdf(s,meanSNR(i),sqrt(2)*sigmaSF);
    
    temp = SINR2BLER(s,rbPerSubchannel,1774*8,14).*fSNR;
    deltaPhy(i) = trapz(s,temp)*(1-deltaFTR(i));
end

%% deltaCol

txPathLoss = 32.4 + 20*log10(d) + 20*log10(fc);%d in meters, fc in GHz
intPathLoss = 32.4 + 20*log10(d) + 20*log10(fc);%d in meters, fc in GHz

meanTxPr = 10*log10(PtWpHzPSCCH)-txPathLoss;
meanIntPr = 10*log10(PtWpHzPSCCH)-intPathLoss;

pSinr = zeros(length(d));

for i = 1:length(meanTxPr)
    for j = 1:length(meanIntPr)
        
        meanSINR = meanPr(i) - 10*log10(10^(meanIntPr(j)/10) + 10^((N0dBm-30)/10));
        
        s = linspace(meanSINR-12*sigmaSF,meanPr(i)-meanIntPr(j)+12*sigmaSF,2000);
        fSINR = normpdf(s,meanSINR,sqrt(2)*sigmaSF);
        
        temp = SINR2BLER(s,rbPerSubchannel,1774*8,14).*fSINR;
        
        
        pSinr(i,j) = trapz(s,temp)*(1-deltaPhy(i));%row it d_{tx,rx}, column is d_{int,rx}
    end
end

pInt = pSinr;

Nsh = (T2-T1+1)^2/(2*(T2-T1)+1);%average overlap between resource pools given there is overlap
C1 = tau*(Nsh/(1000*2^mu))*rhoUe*(numLanes);
TB = formT(round(subchannelsPerChannel*Nsh));

Nrxt = zeros(1,length(d));%number recieved exclusively by UEtx
NrxB = zeros(1,length(d));%number sensed by both UEtx and UEint
CEx = zeros(1,length(d));%number of resources excluded by both UEtx and UEint
NExt = zeros(1,length(d));
OEx = zeros(1,length(d));

for i = 1:length(d)
    
    dtemp = 1:dStep:(2*dMax+1);
    
    deltaFTRM = [fliplr(deltaFTR2),0,deltaFTR2];%0 is at d = 0
    deltaFTRMS = circshift(deltaFTRM,i);
    deltaFTRMS(1:i) = ones(1,i);%no shift right logical for doubles
    
    Nrxt(i) = trapz(dtemp,C1*(1-deltaFTRM).*(deltaFTRMS));
    NrxB(i) = trapz(dtemp,C1*(1-deltaFTRM).*(1-deltaFTRMS));
    
    
    PExCEx = TB^round(NrxB(i));
    
    CEx(i) = sum([0:(round(subchannelsPerChannel*Nsh))].*PExCEx(1,:));
    
    PExNExt = TB^round(Nrxt(i));
    
    NExt(i) = sum([0:(round(subchannelsPerChannel*Nsh))].*PExNExt(round(CEx(i))+1,:)) - CEx(i);
    
    OEx(i) = (NExt(i)^2)/(Nr - CEx(i));
    
end

Psh = (subchannelsPerChannel*Nsh/Nr)^2;
pSim = ((2*(T2-T1+1)-1)/(RRI))*(1 - (1 - (1 - PKeep)/(tau))*(1 - deltaFTR2)).*Psh.*((subchannelsPerChannel*Nsh - CEx - OEx)./(subchannelsPerChannel*Nsh - CEx - NExt).^2);

temp = ones(length(d));
for i = 1:length(d)%d_{t,r}
    for j = 1:length(d)%d_{t,i}
        dri1 = i+j;
        dri2 = abs(i-j);
        if dri1 > length(d) && dri2 < 1
            temp(i,j) = temp(i,j)*(1 - pInt(i,end)*pSim(j))^(numLanes)*(1 - pInt(i,1)*pSim(j))^(numLanes);
        elseif dri2 < 1
            temp(i,j) = temp(i,j)*(1 - pInt(i,dri1)*pSim(j))^(numLanes)*(1 - pInt(i,1)*pSim(j))^(numLanes);
        elseif dri1 > length(d)
            temp(i,j) = temp(i,j)*(1 - pInt(i,end)*pSim(j))^(numLanes)*(1 - pInt(i,dri2)*pSim(j))^(numLanes);
        else
            temp(i,j) = temp(i,j)*(1 - pInt(i,dri1)*pSim(j))^(numLanes)*(1 - pInt(i,dri2)*pSim(j))^(numLanes);
        end
    end
end

deltaCol = 1-prod(temp,2);

%% final touches
PRRCalc = (1 - deltaHd)*(1 - deltaFTR).*(1 - deltaPhy).*(1 - deltaCol');


end
