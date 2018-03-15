clc;
clear;
clear all;

%% Tutti i valori che afferiscono al tempo sono misurati in millisecondi (ms)

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
%Posizioni navigate durante i test (lungo le ancore partendo da (0,0) e
%andando in senso antiorario più il centro della griglia
posizioniValuate = [minX minY; maxX minY; maxX maxY; minX maxY; (maxX - minX)/2 (maxY - minY)/2];

%% Struttura Pacchetto contenuto nel file Log
posLogIter = 1;
posLogIdAlgoritmo = 2;
posLogStatoAlgoritmo = 3;
posLogTimestamp = 4;
posLogCoordinataX = 5;
posLogCoordinataY = 6;

%% Lettura file Log (si presuppone che i dati non siano incompleti)
fileID = fopen('LogBlind.txt', 'r');
formatSpecLog = '%d %d %d %d %d';
sizeLog = [6 Inf];
Log = fscanf(fileID, formatSpecLog, sizeLog);
fclose(fileID);
Log = Log';

[sizeRigheLog sizeColonneLog] = size(Log);

iterazioni = Log(sizeRigheLog, 1);
%% Creazione e Popolamento matrici contenenti i dati degli Algoritmi A e B
%Struttura Dati Algoritmi
colonnaTimestampInizioIter = 1;
colonnaTimestampFineIter = 2;
colonnaCoordinataX = 3;
colonnaCoordinataY = 4;

AlgoritmoA = zeros(iterazioni, 4);
AlgoritmoB = AlgoritmoA;

%utilizzo di datetime (al momento non necessario)
%refTime = datenum([2018,01,01,00,00,00]);
%datestr(refTime,'yyyy-mm-dd HH:MM:SS.FFF');

indexA = 0;
indexB = 0;

for i = 1:2:sizeRigheLog
    if Log(i, posLogIdAlgoritmo) == idAlgoritmoA
        indexA = indexA + 1;
        AlgoritmoA(indexA, colonnaTimestampInizioIter) = Log(i, posLogTimestamp);
        AlgoritmoA(indexA, colonnaTimestampFineIter) = Log(i + 1, posLogTimestamp);
        AlgoritmoA(indexA, colonnaCoordinataX) = Log(i + 1, posLogCoordinataX);
        AlgoritmoA(indexA, colonnaCoordinataY) = Log(i + 1, posLogCoordinataY);
    else
        indexB = indexB + 1;
        AlgoritmoB(indexB, colonnaTimestampInizioIter) = Log(i, posLogTimestamp);
        AlgoritmoB(indexB, colonnaTimestampFineIter) = Log(i + 1, posLogTimestamp);
        AlgoritmoB(indexB, colonnaCoordinataX) = Log(i + 1, posLogCoordinataX);
        AlgoritmoB(indexB, colonnaCoordinataY) = Log(i + 1, posLogCoordinataY);
    end
end

%% Tempo Esecuzione Totale Simulazione
tempoEsecuzioneTotale = AlgoritmoB(iterazioni, colonnaTimestampFineIter);

%% Tempo Esecuzione Totale Algoritmo A
tempoEsecuzioneTotaleAlgoritmoA = 0;
for i=1:(iterazioni - 1)
    tempoEsecuzioneTotaleAlgoritmoA = tempoEsecuzioneTotaleAlgoritmoA + AlgoritmoA(i, colonnaTimestampFineIter) - AlgoritmoA(i, colonnaTimestampInizioIter);
end

%% Tempo Esecuzione Medio Algoritmo A
tempoEsecuzioneMedioAlgoritmoA = tempoEsecuzioneTotaleAlgoritmoA / iterazioni;

%% Tempo Esecuzione Totale Algoritmo B
tempoEsecuzioneTotaleAlgoritmoB = 0;
for i=1:(iterazioni - 1)
    tempoEsecuzioneTotaleAlgoritmoB = tempoEsecuzioneTotaleAlgoritmoB + AlgoritmoB(i, colonnaTimestampFineIter) - AlgoritmoA(i, colonnaTimestampInizioIter);
end

%% Tempo Esecuzione Medio Algoritmo A
tempoEsecuzioneMedioAlgoritmoB = tempoEsecuzioneTotaleAlgoritmoB / iterazioni;

%% Plotting spostamenti Algoritmo A e B
t = 0;
linewidth = 2;

figure('Name','Algoritmo A');
hold on
xlim([minX maxX])
ylim([minY maxY])
for j = 1:indexA
    %pause((AlgoritmoA(j, colonnaTimestampFineIter) - t) / 10000)
    t = AlgoritmoA(j, colonnaTimestampFineIter);
    plot(AlgoritmoA(j, colonnaCoordinataX), AlgoritmoA(j, colonnaCoordinataY), '-o', 'linewidth', linewidth)
end
line(AlgoritmoA(:, colonnaCoordinataX), AlgoritmoA(:, colonnaCoordinataY))

figure('Name','Algoritmo B');
hold on
xlim([minX maxX])
ylim([minY maxY])
for j = 1:indexB
    %pause((AlgoritmoB(j, colonnaTimestampFineIter) - t) / 10000)
    t = AlgoritmoB(j, colonnaTimestampFineIter);
    plot(AlgoritmoB(j, colonnaCoordinataX), AlgoritmoB(j, colonnaCoordinataY), '-o', 'linewidth', linewidth)
end
line(AlgoritmoB(:, colonnaCoordinataX), AlgoritmoB(:, colonnaCoordinataY))

%% Altra tipologia di plotting dello spostamento infittendo i punti
step = 50;
AlgoritmoAPlotValue = zeros(iterazioni * step, 4);
indexAPlotValue = 1;
for i=1:(iterazioni - 1)
    startPoint = [AlgoritmoA(i, colonnaCoordinataX), AlgoritmoA(i, colonnaCoordinataY)];
    endPoint = [AlgoritmoA(i + 1, colonnaCoordinataX), AlgoritmoA(i + 1, colonnaCoordinataY)];
    valuesX = linspace(AlgoritmoA(i, colonnaCoordinataX), AlgoritmoA(i + 1, colonnaCoordinataX), step + 1);
    valuesY = linspace(AlgoritmoA(i, colonnaCoordinataY), AlgoritmoA(i + 1, colonnaCoordinataY), step + 1);
    for j=1:step
        AlgoritmoAPlotValue(indexAPlotValue, 1) =  valuesX(j);
        AlgoritmoAPlotValue(indexAPlotValue, 2) =  valuesY(j);
        indexAPlotValue = indexAPlotValue + 1;
    end
end
AlgoritmoAPlotValue(indexAPlotValue, 1) =  AlgoritmoA(i + 1, colonnaCoordinataX);
AlgoritmoAPlotValue(indexAPlotValue, 2) =  AlgoritmoA(i + 1, colonnaCoordinataY);

figure('Name','Algoritmo A Bis');
hold on
xlim([minX maxX])
ylim([minY maxY])
%plot(AlgoritmoAPlotValue(:, 1), AlgoritmoAPlotValue(:, 2), '-o', 'linewidth', linewidth)
for j = 1:indexAPlotValue
    plot(AlgoritmoAPlotValue(j, 1), AlgoritmoAPlotValue(j, 2), '-o', 'linewidth', linewidth)
end