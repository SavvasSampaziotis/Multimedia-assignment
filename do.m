clear; clc;

% [AACSeq] = AACoder1('alex_jones_modernstudio.wav');
% [AACSeq] = AACoder1('LicorDeCalandraca.wav');
% AACSeq = AACoder1();

% [y, fs] = audioread('alex_jones_modernstudio.wav');
% [y, fs] = audioread('LicorDeCalandraca.wav');
% load('level3.mat');
fNameIn = 'alex_jones_modernstudio';
fNameIn = 'LicorDeCalandraca';
% fNameIn = 'alex_jones_modernstudio.wav';
fNameOut = [fNameIn,'_SAVVAS_1'];

[AACSeq] = AACoder1(['songs\',fNameIn, '.wav']);


i = 120;
plot([AACSeq(i).chl.frameF, AACSeq(i).chr.frameF]);

%snr = demoAAC1([fNameIn, '.wav'], ['exports\', fNameOut, '.wav'])

