 function [SNR] = demoAAC3(fNameIn, fNameOut)

%%

disp('Audio Coding has started...');
tic;
[AACSeq, metadata] = AACoder2(fNameIn);
t = toc;
disp(['Audio Coding has finished: Coding time = ', num2str(t)]);

disp('Audio Decoding has started...');
tic;
x = iAACoder2(AACSeq, fNameOut, metadata);
t = toc;
disp(['Audio Coding has finished: Decoding time = ', num2str(t)]);


%% SNR Calculation

[y, Fs] = audioread(fNameIn);

if mod(length(y),2) == 1 % Number of Samples is ODD. 
    y = y(1:length(y)-1,:);
end

e = y-x;

Px = mean(x.^2);
Pe = mean(e.^2);
SNR = 10*log10(Px) - 10*log10(Pe)

plot(e);

 end