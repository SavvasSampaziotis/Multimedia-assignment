clear; clc;

%fName = 'alex_jones_modernstudio';
fName =  'LicorDeCalandraca';
fNameIn = ['songs\',fName,'.wav'];
fNameOut = ['exports\',fName,'_SAVVAS_1.wav'];
%
snr = demoAAC2(fNameIn, fNameOut);
snr




% clf;
% hold on;
% subplot(1,2,1); plot(frameF, 'r'); plot(1./Sw, 'g')
% subplot(1,2,2); plot(frameFw);
% hold off;
% %snr = demoAAC1([fNameIn, '.wav'], ['exports\', fNameOut, '.wav'])

