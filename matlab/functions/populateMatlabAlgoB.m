function y = populateMatlabAlgoB(BlindAlgoB, A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec)
    for i = 1:size(BlindAlgoB);
        MatlabAlgoB(i,:) = BlindAlgoB(i,:);
        y = AlgoB(BlindAlgoB(i, 1), A1BeaconRec, A2BeaconRec, A3BeaconRec, A4BeaconRec);
        MatlabAlgoB(i, 3) = y(1);
        MatlabAlgoB(i, 4) = y(2);
    end
    
    y = MatlabAlgoB;
end