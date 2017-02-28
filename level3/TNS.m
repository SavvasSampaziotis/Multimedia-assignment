function [ frameFout, TNScoeffs ] = TNS( frameFin, frameType )
%TNS Summary of this function goes here
%   Detailed explanation goes here
load('TableB219.mat');
%% MDCT coeff Normalisation

if strcmp(frameType, 'ESH')
    % Number of Bands
    NB = 42; % For SHORT_WINDOWS
    B219 = B219b;
else
    % Number of Bands
    NB = 69; % For LONG_WINDOWS
    B219 = B219a;
end

N = length(frameFin);
Sw = ones(N,1);

% if(sum(abs(frameFin)) == 0)
%     disp('FrameFin == 0');
% else
for n=1:NB
    % Calculate Energy of MDCT Coeffs per band
    bStart = B219(n,2) + 1;
    bEnd = B219(n,3) + 1;
    bWidth = B219(n,4); % = bEnd - bStart + 1;
    
    % Calculate MDCT normalasation coeff
    energy = sqrt(sum(frameFin(bStart:bEnd).^2));
    Sw(bStart:bEnd) = energy*ones(bWidth, 1);
end

%Smoothing of MDCT normalization coeff
for k = (N-1):-1:1
    Sw(k) = (Sw(k)+Sw(k+1))/2;
end
for k = 2:1:N
    Sw(k) = (Sw(k)+Sw(k-1))/2;
end

frameFw = frameFin./Sw;
if any(isnan(frameFw))
    disp('[TNS]: frameSw is NAN. Possible reason is that whole frameIn is zero');
end


%% Wiener-Hopf Equation Solution

r = autocorr_vector(frameFw,5);
rr = r(1:4);
R =toeplitz(rr); % NOTE: The *1/N coeff of E[] operator has been OMMITED
% for better scalability reasons. The WH equation remains unchanged.

% if any(any(isinf(R))) % Detect badly scaled or singular R..
%     R
%     det(R)
% end
a = R\r(2:5);

% Quantization
TNScoeffs = TNSQuantizer(a);

% FIR filtering
a_ = TNSDequantizer(TNScoeffs); % Unquantisizes TNS Coeffs
frameFout = filter([1;-a_], 1, frameFin);

% Checking stability of inverse filter:
% den = [1;-a_]; %Denominator of inverse filter H(z)^-1
% poles = roots(den);
% mag = abs(poles); % Calculating the magnitude of wach pole
% for i=1:length(mag)
%     if mag > 1
%         % System is unstable.
%         disp('Unstable pole');
%     elseif mag == 1
%         % System if marginally stable
%         % After some experimentation, it is cocnluded that it doesn;'t cause
%         % any problems, so the filter is ok with marginally stable poles for now.
%     else
%         % System is stable. No worries.
%     end 
% end

end

function r = autocorr_vector(x, m)
%% returns the autocorrelation vector r = [r(0), r(1), ... r(m-1)]
%  r(i) = E[x(n),x(n-i)], i=0,1,...m-1

% NOTE: circshift is used
r = zeros(m,1);
N = length(x);
% x = [x;zeros(m,1)];
for i=0:(m-1)
    x2 = circshift(x,i);
    xx = x.*x2;
    r(i+1) = sum(xx);
end
r = r/N;

end

