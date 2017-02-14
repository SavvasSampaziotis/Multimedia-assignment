function [ frameF ] = iAACquantizer( S, sfc, G, frameType )
%IAACQUANTIZER Implements the inverse quantising stage of the AACoder3
%
% WARNING: ESH frames need to be in [1x1024] form.
%
% This function will return a 128x8 matrix
%
load('TableB219.mat');

if strcmp(frameType, 'ESH')
    % ESH frames, sfc and mdct coeffs are vectorised.
    frameF = zeros(128,8);
    n=1:128;
    m=1:41; %NB: number of bands for ESH frames
    
    %iDPCM
    for k=1:8
        a = zeros(42,1);
        a(1) = G(k);
        for i=1:41;
            a(i+1) = a(i) + sfc(i + 41*(k-1));
        end

        %  a = [G(k), sfc(m + 41*(k-1))]; % TODO: Implement inverse DPCM
        frameF(:,k) = iQuant(S(n + 128*(k-1)), a, B219b);
    end
else
    a = zeros(69,1);
    a(1) = G;
    for i=1:68;
        a(i+1) = a(i) + sfc(i);
    end
    frameF = iQuant(S, a, B219a);
end

end

