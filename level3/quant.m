function S = quant(X, a, B219)
%QUANT Summary of this function goes here
%   Detailed explanation goes here
S = zeros(size(X));
for b = 1:length(B219)
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    w = (w_low:w_high);
    
    aa = 2^(-a(b)/4);
    S(w) = sign(X(w)).* round( power(abs(X(w))*aa, 3/4) + 0.4054);
end
end

