function [WL, WR] = KBDWindow(N,a)

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

% W = kaiser(N,a);
% WL=W(1:(N/2))';
% WR=W((N/2+1):N)';
end

% function [WL, WR] = KBDWindow(N,a)
% if a == 6
%     a = 4;
% elseif a == 4
%     a = 6;
% end
%
%
% w = kaiser(N/2, a);
%
% SW = sum(w);
% WL = zeros(N/2,1)';
% WR = zeros(N/2,1)';
% for n = 1:(N/2)
%     WL(n) = sqrt( sum(w(1:(n))) / SW );
% end
%
% for n = (N/2+1):(N)
%     WR(n-N/2) = sqrt( sum(w(1:(N-n+1))) / SW  );
% end
%
% % W = kaiser(N,a);
% % WL=W(1:(N/2))';
% % WR=W((N/2+1):N)';
% end