% function [SNR,xP,e] = demoAAC2(fNameIn, fNameOut)

%%

disp('Audio Coding has started...');
tic;
[AACSeq] = AACoder2();
t = toc;
disp(['Audio Coding has finished: Coding time = ', num2str(t)]);

disp('Audio Decoding has started...');
tic;
x = iAACoder2(AACSeq, fNameOut);
t = toc;
disp(['Audio Coding has finished: Decoding time = ', num2str(t)]);


%% SNR Calculation

% [y, ~] = audioread(fNameIn);
load('level3.mat')
if mod(length(y),2) == 1 % Number of Samples is ODD
    y = y(1:length(y)-1,:);
end

% Check if signal got padding...
% The coder uses a symmetric padding. 
L = length(x) - length(y);
if L > 0
    % the signal was zero-padded. We chop two L/2-samples and we are good to go
    xP = x((L/2+1):(length(x)-L/2),:);
else
    xP = x;
end
e = y-xP;

Px = mean(x.^2);
Pe = mean(e.^2);
SNR = 10*log10(Px) - 10*log10(Pe);

plot(e(:,1));

% end