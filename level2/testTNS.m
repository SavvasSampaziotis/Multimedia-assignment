%% Make Window
[WL,WR] = KBDWindow(2048, 4);
% [WL,WR] = SineWindow(2048);
W =  [WL,WR];



%% Code signal
x = rand(3072,1); %, 1);

x1 = W'.*x(1:2048); % frameT1
x2 = W'.*x(1025:3072);    
frameF1 = mdct4(x1);
frameF2 = mdct4(x2);

%TNS

%% Decode

% iTNS

x1_ = W'.*imdct4(frameF1);
x2_ = W'.*imdct4(frameF2);

xx = [x1_(1:1024); x1_(1025:2048) + x2_(1:1024); x2_(1025:2048)];


%% Evaluate
e = x - xx ;
max(e.^2)

snr = 10 * log10( mean(x(1025:2048).^2) / mean(e(1025:2048).^2))