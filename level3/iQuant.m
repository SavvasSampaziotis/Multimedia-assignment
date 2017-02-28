function X_ = iQuant(S, a, B219)
%IQUANT This is the inverse quantizer of the AACoder. 
%Parameter 'a' is the scale factor gain. 

X_ = zeros(size(S));
for b = 1:length(B219)
    w_low = B219(b,2)+1;
    w_high = B219(b,3)+1;
    w = (w_low:w_high);
    
    aa = 2^(a(b)/4);
    X_(w) = sign(S(w)).*power(abs(S(w)),4/3)*aa;
end

end
