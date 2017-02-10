function a_hat = TNSQuantizer(a)
%% Symmetric 4bit quantizer, with step of 0.1.
% The Q will have 16 different levels and  generates 16 symbols:
% S = {0,1,2....15}. These symbols are to be coded in the AACSeq and
% decoded later in the inverse procedure.

% Decision Levels:
d = [-0.7:0.1:0.7] ;

% The set of symbols that Q[] maps out the TNS coeffs
s = [0:1:15];

a_hat = zeros(size(a));

for n=1:length(a)
    
    if a(n) < d(1)
        a_hat(n) = s(1);
    elseif a(n) >= d(15)
        a_hat(n) = s(16);
    else
        for i=1:length(s)-1
            if d(i) <= a(n) && a(n) < d(i+1)
                a_hat(n) = s(i+1);
                break;
            end
        end
    end
end

