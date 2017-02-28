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
% quantization errors in the DPCM proccess...
G = a(1);
S = quant(frameF, a, B219);

%% Ploting the Pe and Acoustic Threshold of a random frame
% if (rand(1) > 0.8 )
%     NB = length(B219);
%     Pe = zeros(NB,1);
%     for b=1:NB
%        Pe(b) = quantError2(frameF, a(b), b, B219); 
%     end
%     plot(1:NB,10*log([Pe,T])) ;
%     title('Acoustic Threshold and quantization error');
%     xlabel('band index b')
%     ylabel('dB')
%     legend('Pe','T','Location', 'Best')
%     
%     % IMPORTANT: The plot of the T-Pe, was made with a BREAKING POINT.
%     % Otherwise the execution will go to butt...
%     disp('Heeehaaaw');
% end
end

function Pe = quantError2(X, a, b, B219)
% This function returns the Power of the Quantization Error, JUST for the
% band of index b. The input parameter a is JUST ONE scale factor gain, not
% the whole vector...
w_low = B219(b,2)+1;
w_high = B219(b,3)+1;
w = (w_low:w_high);

aa = 2^(-a/4);
S = sign(X(w)).* round( power(abs(X(w))*aa, 3/4) + 0.4054); % has a length of w
aa = 2^(a/4);
X_ = sign(S).*power(abs(S),4/3)*aa; % has a length of w

Pe = sum((X(w) - X_).^2);

end

%%
function sfc = optimizeSFC(frameF, a, T, B219)

NB = length(B219);
for b=1:NB
    while 1
        Pe = quantError2(frameF, a(b), b, B219);
        if Pe < T(b)
            a(b) = a(b) + 1;
        else
            a(b) = a(b) - 1; % We reduce the sfc gain just that Pe < T
            %The optimizer has done all it can. The quantization step cannot be
            %increased any further
            break;
        end
    end
end
% the sfc gains are now OPTIMAL, when it comes to Pe and the Acoustic
% Threshold. However we need to reduce the |a(b+1) - a(b)| for the DPCM
% efficiency. For this, we can ONLY reduce the each a(b), so that the Pe
% condition is met.
flag = 1;
while flag
    flag = 0;
    for b=1:(NB-1)
        if a(b+1) - a(b) > 60
            a(b+1) = a(b+1) - 1;
            flag = 1;
        elseif a(b+1) - a(b) < -60
            a(b) = a(b) - 1;
            flag = 1;
        end
    end
end


[Max, iMax] = max(abs(diff(a)));
if Max > 60
    disp(['done SFC optimization. Max = ', num2str(Max), ' b = ' num2str(iMax)])
end
sfc = a;
end






