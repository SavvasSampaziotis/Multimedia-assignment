function frameFout = iTNS(frameFin, frameType, TNScoeffs)

a_bar = TNSDequantizer(TNScoeffs)';

A = [1, -a_bar];

frameFout = filter(1, A, frameFin);

end