function SNR = demoAAC1(fNameIn, fNameOut)

%% 

disp('Audio Coding has started...');
tic;
[AACSeq,metadata] = AACoder1(fNameIn);
t = toc;
disp(['Audio Coding has finished: Coding time = ', num2str(t)]);

disp('Audio Decoding has started...');
tic;
x = iAACoder1(AACSeq, fNameOut,metadata);
t = toc;
disp(['Audio Coding has finished: Decoding time = ', num2str(t)]);

%% SNR Calculation
[y, fs] = audioread(fNameIn);
length(y)
length(x)
if mod(length(y),2) == 1 % Number of Samples is ODD
    y = y(1:length(y)-1,:);
end
% Check if signal got padding...
e = y-x;
Px = mean(y.^2);
Pe = mean(e(1:length(e)-2048,:).^2);
SNR = 10*log10(Px) - 10*log10(Pe)

% plot(e)
end