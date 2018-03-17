function y = populateMatlabAlgoA(BlindAlgoA, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec)
    for i = 1:size(BlindAlgoA);
        MatlabAlgoA(i,:) = BlindAlgoA(i,:);
        y = AlgoA(BlindAlgoA(i, 1), A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec);
        MatlabAlgoA(i, 3) = y(1);
        MatlabAlgoA(i, 4) = y(2);
    end
    
    y = MatlabAlgoA;
end