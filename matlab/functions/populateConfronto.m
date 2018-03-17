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