
% Demo of Window Types
figure(1);
clf;
[WR,WL]=KBDWindow(2048, 6);
[wr,wl]=KBDWindow(256, 4);
subplot(2,2,1); plot([WR,WL]);
title('KBD Window - OLS frames');
xlabel('samples');

subplot(2,2,2); plot([WR,ones(1,448),wl,zeros(1,448)]);
title('KBD Window - LSS frames');
xlabel('samples');


[WR,WL]=SineWindow(2048);
[wr,wl]=SineWindow(256);
subplot(2,2,3); plot([WR,WL]);
title('Sine Window - OLS frames');
xlabel('samples');

subplot(2,2,4); plot([WR,ones(1,448),wl,zeros(1,448)]);
title('Sine Window - LSS frames');
xlabel('samples');

%% TNS Quantiser Demo
x= -1.5:0.0001:1.5;
s = TNSQuantizer(x);
y = TNSDequantizer(s);
figure(2);
plot(x,s)
grid on;
title('TNS Coefficient Quantizer Symbols Characteristic')
xlabel('TNS Coeff');
ylabel('Quantizer Symbols');

figure(3);
clf;
plot(x,y)
grid on;
title('TNS Coefficient Quantizer Characteristic')
xlabel('TNS Coeff');
ylabel('TNS Coeff DeQuantized');

%% Spreading function
load('level3\TableSpread.mat');
figure(4);
plot(SFa(:,[5,10,50]))
title('Spreading Function')
xlabel('bands')
ylabel('spread factor')
legend('band No.6','band No.11','band No.51')

%% Acoustic Quantizer Characteristic

load('level3\TableB219.mat')
X = -10:0.001:10;
a = -6;
aa = 2^(-a/4);
S1 = sign(X).* round( power(abs(X)*aa, 3/4) + 0.4054);
aa = 2^(a/4);
X1 = sign(S1).*power(abs(S1),4/3)*aa;

a = -1;
aa = 2^(-a/4);
S2 = sign(X).* round( power(abs(X)*aa, 3/4) + 0.4054);
aa = 2^(a/4);
X2 = sign(S2).*power(abs(S2),4/3)*aa;

a = 3;
aa = 2^(-a/4);
S3 = sign(X).* round( power(abs(X)*aa, 3/4) + 0.4054);
aa = 2^(a/4);
X3 = sign(S3).*power(abs(S3),4/3)*aa;

figure(5);
plot(X,S1,X,S2,X,S3);
title('Quantizer Symbols characteristic')
xlabel('input')
ylabel('Symbols')
legend('sfc = -3','sfc = -1','sfc = 1', 'Location' , 'Best');

figure(6);
plot(X,X1,X,X2,X,X3);
title('Quantizer characteristic')
xlabel('input')
ylabel('DeQuantized input')
legend('sfc = -3','sfc = -1','sfc = 1', 'Location' , 'Best');



