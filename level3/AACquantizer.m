function [ S, sfc, G ] = AACquantizer(frameF, frameType, SMR)
%AAQUANTIZER Summary of this function goes here
%   Detailed explanation goes here
S = 0;
sfc = 0;
G = 0;
load('TableB219.mat');

if strcmp(frameType, 'ESH')
    NB  = 42;
    B219 = B219b;
else
    NB = 69;
    B219 = B219a;
end

% Calculate Acoustic Threshold
T = zeros(NB,1);
for b=1:NB
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    Pb = sum(frameF(w_low:w_high).^2);
    T(b) = Pb/SMR(b);
end

% Estimate scale factor gain, via sequential search
alpha_hat = 16/3*log2( (max(frameF)^(3/4))/8191)
a = alpha_hat*ones(NB,1);

flag = 1;
aFLAG = ones(NB,1);
while flag
    Pe = quantError(frameF, a, B219, 1024);
    
    flag = sum(aFLAG) > 0;
    
    for b= 1:NB
        if aFLAG(b) == 1  % a(b) has room for improvement
            if (Pe(b) < T(b))
                if b < NB
                    if a(b+1)-a(b) < 60
                        a(b) = a(b) + 1;
                    end
                else % The last a(b) doesnt can blow up all it wants...
                    a(b) = a(b) + 1;
                end
            else
                a(b) = a(b) - 1; % So that we that just barely Pe < T(b).
                aFLAG(b) = 0;  % a(b) is done
                disp(['a(',num2str(b),') is done', num2str([a(b), Pe(b), T(b)])]);
            end
            % Exit flag. If no sfc change for a full iteration, then the
            % calculation has come to an end.
        end
    end
end

Pe = quantError(frameF, a, B219, 1024);
plot(Pe)

end

function Pe = quantError(X, a, B219, N)
Pe = zeros(length(B219),1);
X_ = iQuant(quant(X,a, B219, N), a, B219,  N);
for b = 1:length(B219)
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    Pe(b) = sum( (X(w_low:w_high)- X_(w_low:w_high)).^2);
end
if isnan(Pe)
    disp(['FUCK']);
    X_
end
end

function S = quant(X, a, B219, N)
S = zeros(N,1);
for b = 1:length(B219)
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    aa = 2^(-a(b)/4);
    S(w_low:w_high) = sign(X(w_low:w_high)).* floor( power(abs(X(w_low:w_high))*aa, 3/4) + 0.4054);
end
end

function X_ = iQuant(S, a, B219,  N)
X_ = zeros(N,1);
for b = 1:length(B219)
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    w = (w_low:w_high);
    
    X_(w) = sign(S(w)).*(abs(S(w)).^(4/3)).*2^(a(b)/4);
end

end





