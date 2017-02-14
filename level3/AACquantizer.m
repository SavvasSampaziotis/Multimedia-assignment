function [ S, sfc, G, T ] = AACquantizer(frameF, frameType, SMR)
%AAQUANTIZER Summary of this function goes here
%   Detailed explanation goes here

load('TableB219.mat');

if strcmp(frameType, 'ESH')
    NB = length(B219b);
    S = zeros(size(frameF));
    sfc = zeros(NB-1,8);
    G = zeros(1,8);
    T = zeros(NB,8);
    for i=1:8
        [ S(:,i), sfc(:,i), G(:,i), T(:,i) ] = AACquantizerSingleFrame(frameF(:,i), SMR(:,i), B219b);
    end
else
    [ S, sfc, G, T ] = AACquantizerSingleFrame(frameF, SMR, B219a);
end
% Calculate Acoustic Threshold


% Pe = quantError(frameF, a, B219, 1024);
end

function [ S, sfc, G, T ] = AACquantizerSingleFrame(frameF, SMR, B219)

NB = length(B219);

T = zeros(NB,1);
Pb = zeros(NB,1);
for b=1:NB
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    Pb(b) = sum(frameF(w_low:w_high).^2);
    T(b) = Pb(b)/SMR(b);
end

% plot([Pb,T]);

% Estimate scale factor gain, via sequential search
alpha_hat = floor(16/3*log2( (max(frameF)^(3/4))/8191));
% alpha_hat = -60;
a = alpha_hat*ones(NB,1);

a = optimizeSFC(frameF, a, T, B219);

sfc = diff(a); 
% DPCM -> sfc's are pure signed integers! so there is no fear of 
% quantization errors in the coding proccess...
G = a(1);
S = quant(frameF, a, B219);
end

function Pe = quantError(X, a, B219)
Pe = zeros(length(B219),1);
X_ = iQuant(quant(X,a, B219), a, B219);
for b = 1:length(B219)
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    Pe(b) = sum( (X(w_low:w_high)- X_(w_low:w_high)).^2);
end
if any(isnan(Pe))
    disp(['FUCK']);
    %     X_
end
end

function sfc = optimizeSFC(frameF, a, T, B219)
flag = 1;
NB = length(B219);
aFLAG = ones(NB,1);
while flag
    Pe = quantError(frameF, a, B219);
    
    flag = sum(aFLAG) > 0;
    % Exit flag. If all sfc's are markedas done, then the quantizer has
    % done all ti can...
    
%     if max(diff(a)) >= 60 % TODO: investigateif it needs removal
%         break;
%     end
    for b=2:(NB-1)
        if aFLAG(b) == 1  % a(b) has room for improvement
            if (Pe(b) < T(b)) && (abs(a(b+1)-a(b)) < 60) && (abs(a(b-1)-a(b)) < 60)
                a(b) = a(b) + 1;
            else
%                 a(b) = a(b) - 1; % So that we that just barely Pe < T(b).
                aFLAG(b) = 0;  % a(b) is done: no more increasing                
            end
        end
    end
    b = NB;
    if aFLAG(b) == 1  % a(b) has room for improvement
        if Pe(b) < T(b) && (abs(a(b-1)-a(b)) < 60)
            a(b) = a(b) + 1;
        else
%             a(b) = a(b) - 1; % So that we that just barely Pe < T(b).
            aFLAG(b) = 0;  % a(b) is done 
        end
    end
    b = 1;
    if aFLAG(b) == 1  % a(b) has room for improvement
        if Pe(b) < T(b) && (abs(a(b+1)-a(b)) < 60)
            a(b) = a(b) + 1;
        else
%             a(b) = a(b) - 1; % So that we that just barely Pe < T(b).
            aFLAG(b) = 0;  % a(b) is done 
        end
    end
end

sfc= a;
end






