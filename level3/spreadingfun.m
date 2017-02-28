function [ x ] = spreadingfun( i, j, B219 )
%SPREADINGFUN This is the spreading function generated fot the
%psychoacoustics stage of the coder. It's purpose is to generate the whole
%matrix, instead of calling it multiple times during the execution of the
%coder

% NOTE: It has been noticed in the B219 tables that for i < j then bval(i)
% < bval(j). As a result, it doesn't matter if the indeces or the bark
% values are compared, instead of the actual bands

% if B219(i,5) >= B219(j,5)
if i >= j
    tmpx = 3*(B219(j,5)-B219(i,5)); % bval(j) - bval(i)
else
    tmpx = 1.5*(B219(j,5)-B219(i,5));  % bval(j) - bval(i)
end

tmpz = 8*min( (tmpx-0.5)^2 - 2*(tmpx-0.5), 0);
tmpy = 15.811389 + 7.5*(tmpx + 0.474) - 17.5*sqrt((1 + (tmpx + 0.474)^2));

if tmpy < -100
    x = 0;
else
    x = 10^((tmpz+tmpy)/10);
end

end
