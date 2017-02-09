function [ frameFout, TNScoeffs ] = TNS( frameFin, frameType )
%TNS Summary of this function goes here
%   Detailed explanation goes here
load('G:\Savvas\Documents\AUTH\9o εξάμηνο\Συστήματα Πολυμέσων και Εικονική Πραγματικότητα\Εργασία\Multimedia-assignment\TableB219.mat');
%% MDCT coeff Normalisation

if strcmp(frameType, 'ESH')
    % Number of Bands
    NB = 42;
    %% TODO
else
    % Number of Bands
    NB = 69; % For LONG_WINDOWS
    N = length(frameFin);
    Sw = ones(N,1);

    for n=1:NB
        % Calculate Energy of MDCT Coeffs per band
        bandStart = B219a(n,2) + 1;
        bandEnd = B219a(n,3) + 1;
        bandwidth = B219a(n,4); % = bEnd - bStart + 1;

        % Calculate MDCT normalasation coeff
        energy = sum(frameFin(bandStart:bandEnd).^2);
        Sw(bandStart:bandEnd) = energy*ones(bandwidth, 1);
    end
    
    %Smoothing of MDCT normalization coeff
    for k = N:-1:1
        Sw(k) = (Sw(k)+Sw(k+1))/2;
    end
    for k = 2:1:N
        Sw(k) = (Sw(k)+Sw(k-1))/2;
    end
    
    frameFw = frameFin./Sw;
    
end
%% Wiener-Hopf Equation Solution

r = autocorr_vector(frameFw,5);
rr = r(1:4);
R =toeplitz(rr); % NOTE: The *1/N coeff of E[] operator has been OMMITED 
% for better scalability reasons. The WH equation remains unchanged.

a = R\r(2:5); % Unquantisizes TNS Coeffs



%% Quantization



%% FIR filtering



end

function a_hat = TNSQuantizer(a)

end

function r = autocorr_vector(x, m)
%% returns the autocorrelation vector r = [r(0), r(1), ... r(m-1)]
%  r(i) = E[x(n),x(n-i)], i=0,1,...m-1

% NOTE: circshift is used
r = zeros(m,1);
N = length(x);
for i=0:(m-1)
    %x = [x;zeros(m,1)];
    x2 = circshift(x,i);
    xx = x.*x2;
    r(i+1) = sum(xx(1:N));
end


end

