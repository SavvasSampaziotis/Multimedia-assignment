function [WL, WR] = KBDWindow(N,a)
% KBDWINDOW This function returns the right and left halves of a Kaizer
% Bessel Derived window of N points.

w = kaiser(N/2 + 1, a*pi);

SW = sum(w);

WL = zeros(N/2,1)';
WR = zeros(N/2,1)';

for n = 1:(N/2)
    WL(n) = sqrt( sum(w(1:(n))) / SW );
end

for n = (N/2+1):N
    WR(n-N/2) = sqrt( sum(w(1:(N-n+1))) / SW  );
end

end
