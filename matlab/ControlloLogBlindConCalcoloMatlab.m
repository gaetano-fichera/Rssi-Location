clc;
clear;
clear all;

%% Leggo il file di Input e di Output

%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        %
% Leggo il file di Input %
%                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%

fileID1 = fopen('LogBlindBeaconRec.txt', 'r');
formatSpecLog = '%d %d %d %d %d';
sizeLog = [5 Inf];
LogBlindBeaconRec = fscanf(fileID1, formatSpecLog, sizeLog);
fclose(fileID1);
LogBlindBeaconRec = LogBlindBeaconRec';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %
% Leggo il file di Output %
%                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileID = fopen('LogBlindAlgo.txt', 'r');
formatSpecLog2 = '%d %d %d %d %d %d';
sizeLog = [6 Inf];
LogBlindAlgo = fscanf(fileID, formatSpecLog2, sizeLog);
fclose(fileID);
LogBlindAlgo = LogBlindAlgo';

%% Separo il file di input in 4 blocchi

%%%%%%%%%%%%%%%%
%              %
% Primo Blocco %
%              %
%%%%%%%%%%%%%%%%

z = 1;
i = 2;
while LogBlindBeaconRec(i,1) ~= 10 && LogBlindBeaconRec(i,2) ~= 0
    for j = 1 : 5
            T1BeaconRec(z,j) = LogBlindBeaconRec(i,j);
    end
    z = z + 1;
    i = i + 1;
end

%%%%%%%%%%%%%%%%%%
%                %
% Secondo Blocco %
%                %
%%%%%%%%%%%%%%%%%%


z = 1;
i = i +1;

while LogBlindBeaconRec(i,1) ~= 10 && LogBlindBeaconRec(i,2) ~= 10
    for j = 1 : 5
            T2BeaconRec(z,j) = LogBlindBeaconRec(i,j);
    end
    z = z + 1;
    i = i + 1;
end

%%%%%%%%%%%%%%%%
%              %
% Terzo Blocco %
%              %
%%%%%%%%%%%%%%%%

z = 1;
i = i +1;
while LogBlindBeaconRec(i,1) ~= 0 && LogBlindBeaconRec(i,2) ~= 10
    for j = 1 : 5
            T3BeaconRec(z,j) = LogBlindBeaconRec(i,j);
    end
    z = z + 1;
    i = i + 1;
end

%%%%%%%%%%%%%%%%%
%               %
% Quarto Blocco %
%               %
%%%%%%%%%%%%%%%%%

z = 1;
i = i +1;
while i ~= size(LogBlindBeaconRec)+1 
    for j = 1 : 5
            T4BeaconRec(z,j) = LogBlindBeaconRec(i,j);
    end
    z = z + 1;
    i = i + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                      %
% Separo il primo blocco per le ancore %
%                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index1 = 1;
index2 = 1;
index3 = 1;
index4 = 1;
for i = 1 : size(T1BeaconRec)
    if T1BeaconRec(i,1) == 1
            for j = 1 : 5
                T1A1BeaconRec(index1,j) = T1BeaconRec(i,j);
            end
            index1 = index1 + 1;
    elseif T1BeaconRec(i,1) == 2
            for j = 1 : 5
                T1A2BeaconRec(index2,j) = T1BeaconRec(i,j);
            end
            index2 = index2 + 1;
    elseif T1BeaconRec(i,1) == 3
            for j = 1 : 5
                T1A3BeaconRec(index3,j) = T1BeaconRec(i,j);
            end
            index3 = index3 + 1;
    elseif T1BeaconRec(i,1) == 4
            for j = 1 : 5
                T1A4BeaconRec(index4,j) = T1BeaconRec(i,j);
            end
            index4 = index4 + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                        %
% Separo il secondo blocco per le ancore %
%                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index1 = 1;
index2 = 1;
index3 = 1;
index4 = 1;
for i = 1 : size(T2BeaconRec)
    if T2BeaconRec(i,1) == 1
            for j = 1 : 5
                T2A1BeaconRec(index1,j) = T2BeaconRec(i,j);
            end
            index1 = index1 + 1;
    elseif T2BeaconRec(i,1) == 2
            for j = 1 : 5
                T2A2BeaconRec(index2,j) = T2BeaconRec(i,j);
            end
            index2 = index2 + 1;
    elseif T2BeaconRec(i,1) == 3
            for j = 1 : 5
                T2A3BeaconRec(index3,j) = T2BeaconRec(i,j);
            end
            index3 = index3 + 1;
    elseif T2BeaconRec(i,1) == 4
            for j = 1 : 5
                T2A4BeaconRec(index4,j) = T2BeaconRec(i,j);
            end
            index4 = index4 + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                      %
% Separo il terzo blocco per le ancore %
%                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index1 = 1;
index2 = 1;
index3 = 1;
index4 = 1;
for i = 1 : size(T3BeaconRec)
    if T3BeaconRec(i,1) == 1
            for j = 1 : 5
                T3A1BeaconRec(index1,j) = T3BeaconRec(i,j);
            end
            index1 = index1 + 1;
    elseif T3BeaconRec(i,1) == 2
            for j = 1 : 5
                T3A2BeaconRec(index2,j) = T3BeaconRec(i,j);
            end
            index2 = index2 + 1;
    elseif T3BeaconRec(i,1) == 3
            for j = 1 : 5
                T3A3BeaconRec(index3,j) = T3BeaconRec(i,j);
            end
            index3 = index3 + 1;
    elseif T3BeaconRec(i,1) == 4
            for j = 1 : 5
                T3A4BeaconRec(index4,j) = T3BeaconRec(i,j);
            end
            index4 = index4 + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                       %
% Separo il quarto blocco per le ancore %
%                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index1 = 1;
index2 = 1;
index3 = 1;
index4 = 1;
for i = 1 : size(T4BeaconRec)
    if T4BeaconRec(i,1) == 1
            for j = 1 : 5
                T4A1BeaconRec(index1,j) = T4BeaconRec(i,j);
            end
            index1 = index1 + 1;
    elseif T4BeaconRec(i,1) == 2
            for j = 1 : 5
                T4A2BeaconRec(index2,j) = T4BeaconRec(i,j);
            end
            index2 = index2 + 1;
    elseif T4BeaconRec(i,1) == 3
            for j = 1 : 5
                T4A3BeaconRec(index3,j) = T4BeaconRec(i,j);
            end
            index3 = index3 + 1;
    elseif T4BeaconRec(i,1) == 4
            for j = 1 : 5
                T4A4BeaconRec(index4,j) = T4BeaconRec(i,j);
            end
            index4 = index4 + 1;
    end
end

%% Separo il file di Output in 4 blocchi:

%%%%%%%%%%%%%%%%
%              %
% Primo Blocco %
%              %
%%%%%%%%%%%%%%%%
z = 1;
i = 2;

while LogBlindAlgo(i,1) + LogBlindAlgo(i,4) ~= 10
    for j = 1 : 6
        T1BlindAlgo(z,j) = LogBlindAlgo(i,j);
    end
    z = z + 1;
    i = i + 1;
end

%%%%%%%%%%%%%%%%%%
%                %
% Secondo Blocco %
%                %
%%%%%%%%%%%%%%%%%%

z = 1;
i = i +1;

while LogBlindAlgo(i,1) + LogBlindAlgo(i,4) ~= 10
    for j = 1 : 6
            T2BlindAlgo(z,j) = LogBlindAlgo(i,j);
    end
    z = z + 1;
    i = i + 1;
end

%%%%%%%%%%%%%%%%
%              %
% Terzo Blocco %
%              %
%%%%%%%%%%%%%%%%

z = 1;
i = i +1;
while LogBlindAlgo(i,1) + LogBlindAlgo(i,4) ~= 0
    for j = 1 : 6
            T3BlindAlgo(z,j) = LogBlindAlgo(i,j);
    end
    z = z + 1;
    i = i + 1;
end

%%%%%%%%%%%%%%%%%
%               %
% Quarto Blocco %
%               %
%%%%%%%%%%%%%%%%%

z = 1;
i = i +1;
while i ~= size(LogBlindAlgo)+1 
    for j = 1 : 6
            T4BlindAlgo(z,j) = LogBlindAlgo(i,j);
    end
    z = z + 1;
    i = i + 1;
end

clear LogBlindBeaconRec LogBlindAlgo sizeLog T1BeaconRec T2BeaconRec T3BeaconRec T4BeaconRec i j z formatSpecLog formatSpecLog2 fileID1 fileID index1 index2 index3 index4;

%% Valori Predefiniti
iterazioni = 0;
idAlgoritmoA = 0;
idAlgoritmoB = 1;
statoInizio = 0;
statoFine = 1;
minX = 0;
maxX = 10;
minY = 0;
maxY = 10;

%% Struttura Pacchetto contenuto nel file Log
posLogIter = 1;
posLogIdAlgoritmo = 2;
posLogStatoAlgoritmo = 3;
posLogTimestamp = 4;
posLogCoordinataX = 5;
posLogCoordinataY = 6;

%% Creazione e Popolamento matrici contenenti i dati degli Algoritmi A e B
%Struttura Dati Algoritmi
colonnaTimestampInizioIter = 1;
colonnaTimestampFineIter = 2;
colonnaCoordinataX = 3;
colonnaCoordinataY = 4;

indexA = 0;
indexB = 0;

for i = 1:2:size(T1BlindAlgo)
    if T1BlindAlgo(i, posLogIdAlgoritmo) == idAlgoritmoA
        indexA = indexA + 1;
        T1BlindAlgoA(indexA, colonnaTimestampInizioIter) = T1BlindAlgo(i, posLogTimestamp);
        T1BlindAlgoA(indexA, colonnaTimestampFineIter) = T1BlindAlgo(i + 1, posLogTimestamp);
        T1BlindAlgoA(indexA, colonnaCoordinataX) = T1BlindAlgo(i + 1, posLogCoordinataX);
        T1BlindAlgoA(indexA, colonnaCoordinataY) = T1BlindAlgo(i + 1, posLogCoordinataY);
    else
        indexB = indexB + 1;
        T1BlindAlgoB(indexB, colonnaTimestampInizioIter) = T1BlindAlgo(i, posLogTimestamp);
        T1BlindAlgoB(indexB, colonnaTimestampFineIter) = T1BlindAlgo(i + 1, posLogTimestamp);
        T1BlindAlgoB(indexB, colonnaCoordinataX) = T1BlindAlgo(i + 1, posLogCoordinataX);
        T1BlindAlgoB(indexB, colonnaCoordinataY) = T1BlindAlgo(i + 1, posLogCoordinataY);
    end
end

indexA = 0;
indexB = 0;

for i = 1:2:size(T2BlindAlgo)
    if T2BlindAlgo(i, posLogIdAlgoritmo) == idAlgoritmoA
        indexA = indexA + 1;
        T2BlindAlgoA(indexA, colonnaTimestampInizioIter) = T2BlindAlgo(i, posLogTimestamp);
        T2BlindAlgoA(indexA, colonnaTimestampFineIter) = T2BlindAlgo(i + 1, posLogTimestamp);
        T2BlindAlgoA(indexA, colonnaCoordinataX) = T2BlindAlgo(i + 1, posLogCoordinataX);
        T2BlindAlgoA(indexA, colonnaCoordinataY) = T2BlindAlgo(i + 1, posLogCoordinataY);
    else
        indexB = indexB + 1;
        T2BlindAlgoB(indexB, colonnaTimestampInizioIter) = T2BlindAlgo(i, posLogTimestamp);
        T2BlindAlgoB(indexB, colonnaTimestampFineIter) = T2BlindAlgo(i + 1, posLogTimestamp);
        T2BlindAlgoB(indexB, colonnaCoordinataX) = T2BlindAlgo(i + 1, posLogCoordinataX);
        T2BlindAlgoB(indexB, colonnaCoordinataY) = T2BlindAlgo(i + 1, posLogCoordinataY);
    end
end

indexA = 0;
indexB = 0;

for i = 1:2:size(T3BlindAlgo)
    if T3BlindAlgo(i, posLogIdAlgoritmo) == idAlgoritmoA
        indexA = indexA + 1;
        T3BlindAlgoA(indexA, colonnaTimestampInizioIter) = T3BlindAlgo(i, posLogTimestamp);
        T3BlindAlgoA(indexA, colonnaTimestampFineIter) = T3BlindAlgo(i + 1, posLogTimestamp);
        T3BlindAlgoA(indexA, colonnaCoordinataX) = T3BlindAlgo(i + 1, posLogCoordinataX);
        T3BlindAlgoA(indexA, colonnaCoordinataY) = T3BlindAlgo(i + 1, posLogCoordinataY);
    else
        indexB = indexB + 1;
        T3BlindAlgoB(indexB, colonnaTimestampInizioIter) = T3BlindAlgo(i, posLogTimestamp);
        T3BlindAlgoB(indexB, colonnaTimestampFineIter) = T3BlindAlgo(i + 1, posLogTimestamp);
        T3BlindAlgoB(indexB, colonnaCoordinataX) = T3BlindAlgo(i + 1, posLogCoordinataX);
        T3BlindAlgoB(indexB, colonnaCoordinataY) = T3BlindAlgo(i + 1, posLogCoordinataY);
    end
end

indexA = 0;
indexB = 0;

for i = 1:2:size(T4BlindAlgo)
    if T4BlindAlgo(i, posLogIdAlgoritmo) == idAlgoritmoA
        indexA = indexA + 1;
        T4BlindAlgoA(indexA, colonnaTimestampInizioIter) = T4BlindAlgo(i, posLogTimestamp);
        T4BlindAlgoA(indexA, colonnaTimestampFineIter) = T4BlindAlgo(i + 1, posLogTimestamp);
        T4BlindAlgoA(indexA, colonnaCoordinataX) = T4BlindAlgo(i + 1, posLogCoordinataX);
        T4BlindAlgoA(indexA, colonnaCoordinataY) = T4BlindAlgo(i + 1, posLogCoordinataY);
    else
        indexB = indexB + 1;
        T4BlindAlgoB(indexB, colonnaTimestampInizioIter) = T4BlindAlgo(i, posLogTimestamp);
        T4BlindAlgoB(indexB, colonnaTimestampFineIter) = T4BlindAlgo(i + 1, posLogTimestamp);
        T4BlindAlgoB(indexB, colonnaCoordinataX) = T4BlindAlgo(i + 1, posLogCoordinataX);
        T4BlindAlgoB(indexB, colonnaCoordinataY) = T4BlindAlgo(i + 1, posLogCoordinataY);
    end
end

%% Calcolo MatlabAlgoA & MatlabAlgoB per ogni Test

T1MatlabAlgoA = populateMatlabAlgoA(T1BlindAlgoA, T1A1BeaconRec, T1A2BeaconRec, T1A3BeaconRec, T1A4BeaconRec);
T1MatlabAlgoB = populateMatlabAlgoB(T1BlindAlgoB, T1A1BeaconRec, T1A2BeaconRec, T1A3BeaconRec, T1A4BeaconRec);

T2MatlabAlgoA = populateMatlabAlgoA(T2BlindAlgoA, T2A1BeaconRec, T2A2BeaconRec, T2A3BeaconRec, T2A4BeaconRec);
T2MatlabAlgoB = populateMatlabAlgoB(T2BlindAlgoB, T2A1BeaconRec, T2A2BeaconRec, T2A3BeaconRec, T2A4BeaconRec);

T3MatlabAlgoA = populateMatlabAlgoA(T3BlindAlgoA, T3A1BeaconRec, T3A2BeaconRec, T3A3BeaconRec, T3A4BeaconRec);
T3MatlabAlgoB = populateMatlabAlgoB(T3BlindAlgoB, T3A1BeaconRec, T3A2BeaconRec, T3A3BeaconRec, T3A4BeaconRec);

T4MatlabAlgoA = populateMatlabAlgoA(T4BlindAlgoA, T4A1BeaconRec, T4A2BeaconRec, T4A3BeaconRec, T4A4BeaconRec);
T4MatlabAlgoB = populateMatlabAlgoB(T4BlindAlgoB, T4A1BeaconRec, T4A2BeaconRec, T4A3BeaconRec, T4A4BeaconRec);

%% Confrontiamo MatlabAlgo e BlindAlgo per ogni Test e Algo

T1ConfrontoA = populateConfronto(T1MatlabAlgoA, T1BlindAlgoA);
T1ConfrontoB = populateConfronto(T1MatlabAlgoB, T1BlindAlgoB);

T2ConfrontoA = populateConfronto(T2MatlabAlgoA, T2BlindAlgoA);
T2ConfrontoB = populateConfronto(T2MatlabAlgoB, T2BlindAlgoB);

T3ConfrontoA = populateConfronto(T3MatlabAlgoA, T3BlindAlgoA);
T3ConfrontoB = populateConfronto(T3MatlabAlgoB, T3BlindAlgoB);

T4ConfrontoA = populateConfronto(T4MatlabAlgoA, T4BlindAlgoA);
T4ConfrontoB = populateConfronto(T4MatlabAlgoB, T4BlindAlgoB);

clear T1BlindAlgo T2BlindAlgo T3BlindAlgo T4BlindAlgo posLogIter posLogIdAlgoritmo posLogStatoAlgoritmo posLogTimestamp posLogCoordinataX posLogCoordinataY iterazioni idAlgoritmoA idAlgoritmoB statoInizio statoFine i indexA indexB colonnaCoordinataX colonnaCoordinataY colonnaTimestampFineIter colonnaTimestampInizioIter;

clear T1A1BeaconRec T1A2BeaconRec T1A3BeaconRec T1A4BeaconRec T1BlindAlgoA T1BlindAlgoB T1MatlabAlgoA T1MatlabAlgoB T2A1BeaconRec T2A2BeaconRec T2A3BeaconRec T2A4BeaconRec T2BlindAlgoA T2BlindAlgoB T2MatlabAlgoA T2MatlabAlgoB T3A1BeaconRec T3A2BeaconRec T3A3BeaconRec T3A4BeaconRec T3BlindAlgoA T3BlindAlgoB T3MatlabAlgoA T3MatlabAlgoB T4A1BeaconRec T4A2BeaconRec T4A3BeaconRec T4A4BeaconRec T4BlindAlgoA T4BlindAlgoB T4MatlabAlgoA T4MatlabAlgoB;
%% Funzioni

function y = populateConfronto(MatlabAlgo, BlindAlgo)
    for i = 1:size(BlindAlgo)
        Confronto(i, 1) = BlindAlgo(i, 1);
        Confronto(i, 2) = BlindAlgo(i, 2);
        Confronto(i, 3) = MatlabAlgo(i, 3);
        Confronto(i, 4) = MatlabAlgo(i, 4);
        Confronto(i, 5) = BlindAlgo(i, 3);
        Confronto(i, 6) = BlindAlgo(i, 4);
    end
    y = Confronto;
end

function y = populateMatlabAlgoA(BlindAlgoA, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec)
    for i = 1:size(BlindAlgoA);
        MatlabAlgoA(i,:) = BlindAlgoA(i,:);
        y = AlgoA(BlindAlgoA(i, 1), A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec);
        MatlabAlgoA(i, 3) = y(1);
        MatlabAlgoA(i, 4) = y(2);
    end
    
    y = MatlabAlgoA;
end

function y = populateMatlabAlgoB(BlindAlgoB, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec)
    for i = 1:size(BlindAlgoB);
        MatlabAlgoB(i,:) = BlindAlgoB(i,:);
        y = AlgoB(BlindAlgoB(i, 1), A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec);
        MatlabAlgoB(i, 3) = y(1);
        MatlabAlgoB(i, 4) = y(2);
    end
    
    y = MatlabAlgoB;
end

function y = AlgoA(timestampInizioIterazione, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec)
    LUT = [1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 5, 5, 6, 7, 7, 8, 10, 11, 12, 14, 15, 17, 19, 22, 25, 28, 31, 35, 39, 44, 50, 56, 63, 70, 79, 89, 100, 112, 125, 141, 158, 177, 199, 223, 251, 281, 316, 354, 398, 446, 501, 562, 630, 707, 794, 891, 1000, 1122, 1258, 1412, 1584, 1778, 1995, 2238, 2511, 2818, 3162, 3548, 3981, 4466, 5011, 5623, 6309, 7079, 7943, 8912];
    y1 = [0 0];
    
    avg_RSSI = avgRSSI(timestampInizioIterazione, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec);
    
    pos_anchors = [0 0; 10 0; 10 10; 0 10];
    
    min_ds = 65535;
    devstd = 0;
    
    minX = 0;
    maxX = 10;
    minY = 0;
    maxY = 10;
    
    for xsp = minX:maxX
        for ysp = minY:maxY
            for j = 1:4
                dist(j) = 1 + (xsp - pos_anchors(j, 1))^2 + (ysp - pos_anchors(j, 2))^2;
            end
            
            for j = 1:4
                qual(j) = LUT(avg_RSSI(j)) * dist(j);
            end
            
            average = 0;
            for j = 1:4
                average = average + qual(j);
            end
            average = average / 4;
            
            sum = 0;
            for j = 1:4
                sum = sum + (qual(j) - average)^2;
            end
            
            devstd = uint64((sum / 4)^(1/2));
            
            if(devstd < min_ds)
                min_ds = devstd;
                y1 = [xsp ysp];
            end
        end
    end
    
    y = y1;
end

function y = AlgoB(timestampInizioIterazione, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec)
    LUT = [1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 5, 5, 6, 7, 7, 8, 10, 11, 12, 14, 15, 17, 19, 22, 25, 28, 31, 35, 39, 44, 50, 56, 63, 70, 79, 89, 100, 112, 125, 141, 158, 177, 199, 223, 251, 281, 316, 354, 398, 446, 501, 562, 630, 707, 794, 891, 1000, 1122, 1258, 1412, 1584, 1778, 1995, 2238, 2511, 2818, 3162, 3548, 3981, 4466, 5011, 5623, 6309, 7079, 7943, 8912];
    y1 = [0 0];
    
    avg_RSSI = avgRSSI(timestampInizioIterazione, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec);
    
    pos_anchors = [0 0; 10 0; 10 10; 0 10];
    
    min_ds = 65535;
    devstd = 0;
    
    minX = 0;
    maxX = 10;
    minY = 0;
    maxY = 10;
    
    for xsp = minX:maxX
        for j = 1:4
            dist(j) = 1 + (xsp - pos_anchors(j, 1))^2;
        end

        for j = 1:4
            qual(j) = LUT(avg_RSSI(j)) * dist(j);
        end

        average = 0;
        for j = 1:4
            average = average + qual(j);
        end
        average = average / 4;

        sum = 0;
        for j = 1:4
            sum = sum + (qual(j) - average)^2;
        end

        devstd = uint64((sum / 4)^(1/2));

        if(devstd < min_ds)
            min_ds = devstd;
            y1(1) = xsp;
        end
    end
    
    min_ds = 65535;
    devstd = 0;
    
    for ysp = minY:maxY
        for j = 1:4
            dist(j) = 1 + (ysp - pos_anchors(j, 2))^2;
        end

        for j = 1:4
            qual(j) = LUT(avg_RSSI(j)) * dist(j);
        end

        average = 0;
        for j = 1:4
            average = average + qual(j);
        end
        average = average / 4;

        sum = 0;
        for j = 1:4
            sum = sum + (qual(j) - average)^2;
        end

        devstd = uint64((sum / 4)^(1/2));

        if(devstd < min_ds)
            min_ds = devstd;
            y1(2) = ysp;
        end
    end
    
    y = y1;
end

function y = avgRSSI(timestampInizioIterazione, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec)
    offsetRSSI = 50;
    avg_RSSI = [0 0 0 0];
    i = 1;
    while A1BeaconRec(i, 2) < timestampInizioIterazione
        i = i + 1;
    end
    for j = 1:10
        avg_RSSI(1) = avg_RSSI(1) + A1BeaconRec(i - j, 3) + offsetRSSI;
    end
    avg_RSSI(1) = uint64(avg_RSSI(1) / 10);
    
    i = 1;
    while A2BeaconRec(i, 2) < timestampInizioIterazione
        i = i + 1;
    end
    for j = 1:10
        avg_RSSI(2) = avg_RSSI(2) + A2BeaconRec(i - j, 3) + offsetRSSI;
    end
    avg_RSSI(2) = uint64(avg_RSSI(2) / 10);
    
    i = 1;
    while A3BeaconRec(i, 2) < timestampInizioIterazione
        i = i + 1;
    end
    for j = 1:10
        avg_RSSI(3) = avg_RSSI(3) + A3BeaconRec(i - j, 3) + offsetRSSI;
    end
    avg_RSSI(3) = uint64(avg_RSSI(3) / 10);   
    
    i = 1;
    while A4BeaconRec(i, 2) < timestampInizioIterazione
        i = i + 1;
    end
    for j = 1:10
        avg_RSSI(4) = avg_RSSI(1) + A4BeaconRec(i - j, 3) + offsetRSSI;
    end
    avg_RSSI(4) = uint64(avg_RSSI(4) / 10);
    
    y = avg_RSSI;
end