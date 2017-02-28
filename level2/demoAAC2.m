 function [SNR,xP,e] = demoAAC2(fNameIn, fNameOut)

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

e = y-x;

Px = mean(x.^2);
Pe = mean(e.^2);
SNR = 10*log10(Px) - 10*log10(Pe)

% subplot(2,1,1); plot(e(:,1));
% xlabel('samples');
% title('Error signal, channels Left')
% ylabel('e=y-x')
% 
% subplot(2,1,2); plot(e(:,2));
% xlabel('samples');
% title('Error signal, channels Right')
% ylabel('e=y-x')

 end