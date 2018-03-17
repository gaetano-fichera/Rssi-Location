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
        avg_RSSI(4) = avg_RSSI(4) + A4BeaconRec(i - j, 3) + offsetRSSI;
    end
    avg_RSSI(4) = uint64(avg_RSSI(4) / 10);
    
    y = avg_RSSI;
end