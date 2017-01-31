clear

[WL,WR] = KBDWindow(2048, 4);
% [WL,WR] = SineWindow(2048);

W =  [WL,WR];

x = rand(3072,1); %, 1);

x1 = W'.*x(1:2048);
x2 = W'.*x(1025:3072);    
X1 = mdct4(x1);
X2 = mdct4(x2);



x1_ = W'.*imdct4(X1);
x2_ = W'.*imdct4(X2);

xx = [x1_(1:1024); x1_(1025:2048) + x2_(1:1024); x2_(1025:2048)];

e = x - xx ;
max(e.^2)

snr = 10 * log10( mean(x(1025:2048).^2) / mean(e(1025:2048).^2))

figure(1)
clf;
hold on; 
%  plot(W); 
% plot(WW, 'g'); 
% plot(ix_)
subplot(2,1,1); plot([X1; flipud(X1)]);
subplot(2,1,2); plot(W);
hold off;