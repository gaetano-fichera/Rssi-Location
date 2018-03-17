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