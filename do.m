clear; clc;
load('G:\Savvas\Documents\AUTH\9o εξάμηνο\Συστήματα Πολυμέσων και Εικονική Πραγματικότητα\Εργασία\Multimedia-assignment\TableB219.mat');

%fName = 'alex_jones_modernstudio';
fName =  'LicorDeCalandraca';
fNameIn = ['songs\',fName,'.wav'];
% fNameOut = ['exports\',fName,'_SAVVAS_1.wav'];
% 
% snr = demoAAC1(fNameIn, fNameOut);
% snr



[AACSeq] = AACoder1();
i = 120;
frameF = AACSeq(i).chl.frameF;
tns(frameF, 'OLS');

% clf;
% hold on;
% subplot(1,2,1); plot(frameF, 'r'); plot(1./Sw, 'g')
% subplot(1,2,2); plot(frameFw);
% hold off;
% %snr = demoAAC1([fNameIn, '.wav'], ['exports\', fNameOut, '.wav'])

