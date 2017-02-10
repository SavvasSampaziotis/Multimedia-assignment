function a_bar = TNSDequantizer(s)
    % The dequantized values of s can be easily extracted from a lookup
    % table:
    levels = [-0.75:0.1:0.75];
    a_bar = zeros(size(s));
    for i=1:length(s)
        a_bar(i) = levels(s(i)+1); % The +1 is due to the 1-based indexing of matlab. Pay no mind to it
    end
    
end