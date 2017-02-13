function [ SMR ] = psycho(frameT, frameType, frameTprev1, frameTprev2)
%PSYCHO Summary of this function goes here
%   Detailed explanation goes here

% 1
load('TableSpread.mat');
load('TableB219.mat');

NT = length(frameT);
% 2 HANNING and FFT frame is NOT ESH
frameTw = frameT.*hann(NT);

Sw = fft(frameTw);
r = abs(Sw(1:1024));
f = angle(Sw(1:1024));

% 3
tempw = fft(frameTprev1.*hann(NT));
r1 = abs(tempw(1:1024));
f1 = angle(tempw(1:1024));
tempw = fft(frameTprev2.*hann(NT));
r2 = abs(tempw(1:1024));
f2 = angle(tempw(1:1024));

r_pred = 2*r1 - r2;
f_pred = 2*f1 - f2;


% 4 Predictability: % The norm of Sw and Sw_pred normallised by the sum
% |Sw| + |Sw_pred |
c_w = sqrt( (r.*cos(f) - r_pred.* cos(f_pred)).^2 + (r.*sin(f) - r_pred.*sin(f_pred)).^2 )./(r + abs(r_pred));

% 5 weighted energy
NB = length(B219a);
e_b = zeros(NB,1);
c_b = e_b;
for b=1:NB
    w_low = B219a(b,2)+1;
    w_high = B219a(b,3)+1;
    
    e_b(b) = sum( r(w_low:w_high).^2 );
    
    c_b(b) = sum ( c_w(w_low:w_high).*r(w_low:w_high).^2 );
end

spreadTable = SFa;
ecb = zeros(NB,1);
ct = zeros(NB,1);
% 6 spreading function compined with predictability
for b=1:NB
    ecb(b) = sum( e_b .* spreadTable(:,b) );
    ct(b) = sum( c_b .* spreadTable(:,b) );
end
% normalising:
cb = ct./ecb;

en = zeros(NB,1);
for b=1:NB
    en(b) = ecb(b)/ sum(spreadTable(:,b));
end

% 7 Tonality Index
tb = -0.299 - 0.43*log(cb);

% 8 SNR
TMN = 18; % dB
NMT = 6; % dB
SNR = tb*TMN + (1-tb)*NMT;

% 9 dB -> Power ratio
bc = 10.^(-SNR/10);

% 10 energy threshold
nb = en.*bc;

% 11 scalefactor bands
npart = zeros(NB,1);
q_thr_hat = npart;
for b=1:NB
    q_thr_hat(b) = eps*NT/2*10^((B219a(b,6)/10));
    npart(b) = max(nb(b), q_thr_hat(b));
end

% plot(r_pred)

% 12
SMR = e_b./npart;



end

