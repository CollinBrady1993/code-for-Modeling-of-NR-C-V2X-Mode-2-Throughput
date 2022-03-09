RRI = 100;
PKeep = 0;
mu = 0;
T1 = 2;
numLanes = 2;

tau = 1/RRI;

%generating the caluated curves
[dCalcDivd10T233,prrCalcDivd10T233] = prrCalcFunc(RRI,PKeep,mu,T1,33,10,numLanes);
[dCalcDivd20T233,prrCalcDivd20T233] = prrCalcFunc(RRI,PKeep,mu,T1,33,20,numLanes);
[dCalcDivd40T233,prrCalcDivd40T233] = prrCalcFunc(RRI,PKeep,mu,T1,33,40,numLanes);
[dCalcDivd20T217,prrCalcDivd20T217] = prrCalcFunc(RRI,PKeep,mu,T1,17,20,numLanes);
[dCalcDivd20T265,prrCalcDivd20T265] = prrCalcFunc(RRI,PKeep,mu,T1,65,20,numLanes);

TCalcDivd10T233 = tau*prrCalcDivd10T233;
TCalcDivd20T233 = tau*prrCalcDivd20T233;
TCalcDivd40T233 = tau*prrCalcDivd40T233;
TCalcDivd20T217 = tau*prrCalcDivd20T217;
TCalcDivd20T265 = tau*prrCalcDivd20T265;

%loading simulation curves, These can be generated yourself using the ns-3
%simulations and the data analysis tools provided (ns3DataAnalysis.m)
prrSimDivd10T233 = csvread('PRRDivd10T233.csv');
prrSimDivd20T233 = csvread('PRRDivd20T233.csv');
prrSimDivd40T233 = csvread('PRRDivd40T233.csv');
prrSimDivd20T217 = csvread('PRRDivd20T217.csv');
prrSimDivd20T265 = csvread('PRRDivd20T265.csv');

TSimDivd10T233 = csvread('TDivd10T233.csv');
TSimDivd20T233 = csvread('TDivd20T233.csv');
TSimDivd40T233 = csvread('TDivd40T233.csv');
TSimDivd20T217 = csvread('TDivd20T217.csv');
TSimDivd20T265 = csvread('TDivd20T265.csv');



%fig 4
figure
hold on
grid on
xlabel 'd_{t,r} (m)'
ylabel 'P_{PRR}(d_{t,r})'
errorbar(10:10:1770,prrSimDivd10T233(:,1),1.96*prrSimDivd10T233(:,2)./sqrt(prrSimDivd10T233(:,3)),'linewidth',3,'capSize',15)
errorbar(20:20:1770,prrSimDivd20T233(:,1),1.96*prrSimDivd20T233(:,2)./sqrt(prrSimDivd20T233(:,3)),'linewidth',3,'capSize',15)
errorbar(40:40:1770,prrSimDivd40T233(:,1),1.96*prrSimDivd40T233(:,2)./sqrt(prrSimDivd40T233(:,3)),'linewidth',3,'capSize',15)
plot(dCalcDivd10T233,prrCalcDivd10T233,'linewidth',3)
plot(dCalcDivd20T233,prrCalcDivd20T233,'linewidth',3)
plot(dCalcDivd40T233,prrCalcDivd40T233,'linewidth',3)
legend('Simulated P_{PRR}(d_{t,r}) w/ 95% Confidence Interval, d_{t,r}=10 m','Simulated P_{PRR}(d_{t,r}) w/ 95% Confidence Interval, d_{t,r}=20 m','Simulated P_{PRR}(d_{t,r}) w/ 95% Confidence Interval, d_{t,r}=40 m','Calculated P_{PRR}(d_{t,r}), d_{t,r}=10 m','Calculated P_{PRR}(d_{t,r}), d_{t,r}=20 m','Calculated P_{PRR}(d_{t,r}), d_{t,r}=40 m')


%fig 4
figure
hold on
grid on
xlabel 'd_{t,r} (m)'
ylabel 'P_{PRR}(d_{r,t})'
errorbar(10:10:1770,TDivd10T233(:,1),1.96*TDivd10T233(:,2)./sqrt(TDivd10T233(:,3)),'linewidth',3,'capSize',15)
errorbar(20:20:1770,TDivd20T233(:,1),1.96*TDivd20T233(:,2)./sqrt(TDivd20T233(:,3)),'linewidth',3,'capSize',15)
errorbar(40:40:1770,TDivd40T233(:,1),1.96*TDivd40T233(:,2)./sqrt(TDivd40T233(:,3)),'linewidth',3,'capSize',15)
plot(dCalcDivd10T233,prrCalcDivd10T233,'linewidth',3)
plot(dCalcDivd20T233,prrCalcDivd20T233,'linewidth',3)
plot(dCalcDivd40T233,prrCalcDivd40T233,'linewidth',3)
legend('Simulated P_{PRR}(d_{t,r}) w/ 95% Confidence Interval, T_2=17','Simulated P_{PRR}(d_{t,r}) w/ 95% Confidence Interval, T_2=33','Simulated P_{PRR}(d_{t,r}) w/ 95% Confidence Interval, T_2=65','Calculated P_{PRR}(d_{t,r}), T_2=17','Calculated P_{PRR}(d_{t,r}), T_2=33','Calculated P_{PRR}(d_{t,r}), T_2=65')


%fig 6
figure
hold on
grid on
xlabel 'd_{t,r} (m)'
ylabel '\Lambda(d_{r,t})'
errorbar(10:10:1770,TDivd10T233(:,1),1.96*TDivd10T233(:,2)./sqrt(TDivd10T233(:,3)),'linewidth',3,'capSize',15)
errorbar(20:20:1770,TDivd20T233(:,1),1.96*TDivd20T233(:,2)./sqrt(TDivd20T233(:,3)),'linewidth',3,'capSize',15)
errorbar(40:40:1770,TDivd40T233(:,1),1.96*TDivd40T233(:,2)./sqrt(TDivd40T233(:,3)),'linewidth',3,'capSize',15)
plot(dCalcDivd10T233,prrCalcDivd10T233,'linewidth',3)
plot(dCalcDivd20T233,prrCalcDivd20T233,'linewidth',3)
plot(dCalcDivd40T233,prrCalcDivd40T233,'linewidth',3)
legend('Simulated \Lambda(d_{t,r}) w/ 95% Confidence Interval, d_{t,r}=10 m','Simulated \Lambda(d_{t,r}) w/ 95% Confidence Interval, d_{t,r}=20 m','Simulated \Lambda(d_{t,r}) w/ 95% Confidence Interval, d_{t,r}=40 m','Calculated \Lambda(d_{t,r}), d_{t,r}=10 m','Calculated \Lambda(d_{t,r}), d_{t,r}=20 m','Calculated \Lambda(d_{t,r}), d_{t,r}=40 m')


