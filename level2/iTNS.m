function frameFout = iTNS(frameFin, frameType, TNScoeffs, KK)

a_bar = TNSDequantizer(TNScoeffs)';


A = [1, -a_bar];
H = tf(1, A,  1, 'Variable', 'z^-1');

if ~isstable(H)
    %       disp(['[TNS] Filter UNSTABLE ', frameType]);
    
    Poles= pole(H)
    
    newPoles=zeros(1,4);
    for k=1:length(Poles)
        if abs(Poles(k))>=1 %Unstable pole
            newPole = 0.95*exp(1i*angle( Poles(k)));
        else
            newPole = Poles(k);
        end
        newPoles(k) = newPole;
    end
    
    % we replace the unstable pole, with a slighty more stable:
    % new pole has same phase and a magnitude of 0.95
    % New filter
    H2 = zpk([0,0,0,0], newPoles , 1, 1);
    H2 = tf(H2);
    if ~isstable(H2)
%         disp('FUCK'); 
    end
%     A = H2.den{1};
end

frameFout = filter(1, A, frameFin);

if KK==26
%    H
%    H2
%    Poles
%    newPoles
end

end