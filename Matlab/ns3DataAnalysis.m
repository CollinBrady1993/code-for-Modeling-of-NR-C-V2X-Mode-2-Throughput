separation=20;%m
numLanes = 2;
laneSeparation = 4;%m
numUe = 400;
speed = 0;%m/s
RRI = .1;%s
rho = 1/RRI;%hz
deadTime = 200*RRI;%this is the amount of time to throw away at the begining of the trace, due to the transient effects of starting the simulation. it allows for each UE to have gone through reselection a MINIMUM of 50 times
endTime = 20 + deadTime;%this is because if the records are too long then it can take forever to process the data

%replace with local path
conn = sqlite('D:\CV2XConfFinalData\dIVD20,T217.db');


%find PDR
disp('fetching time')
sqlquery = 'SELECT timeSec FROM pktTxRx';
time = fetch(conn, sqlquery);
time = cell2mat(time);

disp('fetching txRx')
sqlquery = 'SELECT txRx FROM pktTxRx';
txRx = fetch(conn, sqlquery);
txRx = strcmp(txRx,'tx');

disp('fetching sourceIp')
sqlquery = 'SELECT srcIp FROM pktTxRx';
srcIp = fetch(conn, sqlquery);
srcIp = split(srcIp,'.');
srcIp = 256*str2double(srcIp(:,3)) + str2double(srcIp(:,4))-2;%-2 converts from ip to node id

disp('fetching nodeId')
sqlquery = 'SELECT nodeId FROM pktTxRx';
nodeId = fetch(conn, sqlquery);
nodeId = double(cell2mat(nodeId));

disp('fetching pktSeqNum')
sqlquery = 'SELECT pktSeqNum FROM pktTxRx';
pktSeqNum = fetch(conn, sqlquery);
pktSeqNum = double(cell2mat(pktSeqNum));

txRecord = [time(txRx),nodeId(txRx),pktSeqNum(txRx)];%time,sender,seqNum
rxRecord = [time(not(txRx)),srcIp(not(txRx)),nodeId(not(txRx)),pktSeqNum(not(txRx))];%time, sender,reciever,seqNum

clear('time','txRx','decoded','nodeId','pktSeqNum','srcIp','conn','sqlquery')

%erasing dead data
txRecord(txRecord(:,1) < min(txRecord(:,1))+deadTime,:) = [];
rxRecord(rxRecord(:,1) < min(txRecord(:,1)),:) = [];

txRecord(txRecord(:,1) > endTime,:) = [];
rxRecord(rxRecord(:,4) > max(txRecord(:,3))+1,:) = [];

disp('inputs found')

%placing UE
initialPos = zeros(numUe,2);
for i = 1:numLanes
    for j = 1:numUe/numLanes%this will always be a whole number
        initialPos((i-1)*numUe/numLanes + j,1) = (j-1)*separation;
        initialPos((i-1)*numUe/numLanes + j,2) = (i-1)*laneSeparation;
    end
end

%deterimining relevant UE. Relevant UE are ones central to the simulation,
%no edge effects. Right now that means UE which will remain within the
%central 200 meters the whole sim.

disp('determining receptions')

rawData = zeros(size(txRecord*numUe,1),5);
a = 1;
for i = 1:size(txRecord,1)
    temp = rxRecord(rxRecord(:,2)==txRecord(i,2),:);%all receptions with matching seqNum and transmitter
    temp = temp(temp(:,4)==txRecord(i,3),:);%all receptions with matching seqNum and transmitter
    if mod(i,1000) == 0 || i == 1
        i;
        disp(['transmission ',num2str(i),' of ',num2str(size(txRecord,1))])
        datestr(now)
    end
    
    rtx = initialPos(txRecord(i,2)+1,:);%current tx Pos
    rxList = [0:(numUe-1)]';
    if ~isempty(temp)
        rrx = initialPos;%current rx Pos
    else
        rrx = initialPos;%current rx Pos
    end
    
    rxBool = rxList~=(txRecord(i,2)) & rrx(:,1) <= max(initialPos(:,1)) + separation - 500 & rrx(:,1) >= min(initialPos(:,1)) + 500;%only consider central UE as recievers

    dr = vecnorm((rtx-rrx)')';

    

    receptions = ismember(rxList,temp(:,3));
    dataTime = zeros(length(rxList),1);
    
    dataTime(temp(:,3)+1) = repmat(min(temp(:,1)),length(temp(:,3)),1);

    if isempty(temp(:,3))%if NOBODY recieved the packet
        dataTime(dataTime == 0) = txRecord(i,1);
    else
        dataTime(dataTime == 0) = min(temp(:,1));
    end

    rawData(a:(a+sum(rxBool)-1),:) = [dataTime(rxBool),repmat(txRecord(i,2),sum(rxBool),1),rxList(rxBool),dr(rxBool),receptions(rxBool)];
    a = a + sum(rxBool);
end

rawData(a:end,:) = [];

binEdges = separation/2:separation:1780;

%% PDR
disp('calculating PDR')
PDR = zeros(length(binEdges)-1,3);

for i = 1:length(binEdges)-1
    binData = rawData(rawData(:,4) <= binEdges(i+1) & rawData(:,4) > binEdges(i),5);
    
    if isempty(binData)
        PDR(i,1) = 0;
        PDR(i,2) = 0;
        PDR(i,3) = 0;
    else
        PDR(i,1) = mean(binData);
        PDR(i,2) = std(binData);
        PDR(i,3) = length(binData);
    end
end
clear('binData')

%% throughput
disp('calculating per-UE throughput')
throughputData = cell((numUe)^2 - numUe,length(binEdges)-1);
for i = 1:numUe
    if mod(i,10) == 0 || i == 1
        disp(['Calculating throughput ',num2str(i),' of ',num2str(numUe)])
        datestr(now)
    end
    
    throughputTemp = rawData(rawData(:,2)==i-1,:);%the reciever is the reference
    
    for j = 1:numUe
        if i~=j
            throughputTemp2 = throughputTemp(throughputTemp(:,3)==j-1,:);%the reciever is the reference
            arrivalTimes = throughputTemp2(:,1);
            
            rtx = double([initialPos(i,1) + (-1)^((i-1) < numUe/2)*speed*arrivalTimes,repmat(initialPos(i,2),length(arrivalTimes),1)]);%current tx Pos
            rrx = double([initialPos(j,1) + (-1)^((j-1) < numUe/2)*speed*arrivalTimes,repmat(initialPos(j,2),length(arrivalTimes),1)]);%current rx Pos
            dr = vecnorm((rtx-rrx)')';
            
            for k = 1:length(binEdges)-1
                binData = throughputTemp2(dr <= binEdges(k+1) & dr > binEdges(k),:);
                
                if isempty(binData)%if the UE's were never in this range
                    throughputData{numUe*(i-1) + j,k} = [];
                else
                    throughputData{numUe*(i-1) + j,k} = sum(binData(:,5))/(max(binData(:,1)) - min(binData(:,1)));
                end
            end
        end
    end
end

clear('throughputTemp','arrivalTimes','rtx','rrx','dr','dt','binData')

throughput = zeros(length(binEdges)-1,3);
for i = 1:length(binEdges)-1
    
    binData = cell2mat(throughputData(:,i));
    
    if isempty(binData)
        throughput(i,1) = 0;
        throughput(i,2) = 0;
        throughput(i,3) = 0;
    else
        throughput(i,1) = mean(binData);
        throughput(i,2) = std(binData);
        throughput(i,3) = length(binData);
    end
end
clear('binData','throughputData')




