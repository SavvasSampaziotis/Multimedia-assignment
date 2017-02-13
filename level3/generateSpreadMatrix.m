
load('TableB219.mat')

Na = length(B219a);
Nb = length(B219b);
SFa = zeros(Na);
SFb = zeros(Nb);

% disp('This scripts generates the psychoacoustic''s model spreading function look up matrices for LONG and SHORT windows.');

for i=1:Na
    for j=1:Na
        SFa(i,j) = spreadingfun(i,j, B219a);
    end
end

for i=1:Nb
    for j=1:Nb
        SFb(i,j) = spreadingfun(i,j, B219b);
    end
end

save('TableSpread.mat', 'SFa', 'SFb')

disp('Matrices have been saved in root folder: TableSpread.mat');



