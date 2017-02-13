clear; clc;

%%
[y, Fs] = audioread('songs\alex_jones_modernstudio.wav');
if mod(length(y),2) == 1 % Number of Samples is ODD
    y = y(1:length(y)-1,:);
end
N = length(y);

if mod(N,1024) ~= 0 % Signal needs additional zero padding for proper sequence segmentation
    padNum = 1024*2  - ceil(mod(N,1024))/2; % a total of Zero pad 1024 samples at the start and at the end of the signal.
    padding = zeros(padNum, 2);
    y = [padding; y ;padding];
    numOfFrames = length(y)/1024;
end

% Emulate the coder and generate some frames and frametypes...
n = (1:2048) + 0*1024*15;
frameTprev2 = 0*y(n,:);
frameTprev1 = 0*y(n+1024,:);
frameT = y(n+2048,:);

frameType2 = SSC(frameTprev2, frameTprev1,  'OLS');
frameType1 = SSC(frameTprev1, frameT,       frameType2);
frameType  = SSC(frameTprev2, frameTprev1,  frameType1);

% Take only ONE channel...
frameTprev2 = frameTprev2(:,1);
frameTprev1 = frameTprev1(:,1);

SMR = psycho(frameT(:,1), frameType, frameTprev1, frameTprev2);

frameF = filterbank(frameT, frameType, 'SIN');
[frameFout1, TNSCoeffs1] = TNS(frameF(:,1), frameType);
[frameFout2, TNSCoeffs2] = TNS(frameF(:,2), frameType);

frameF = frameFout1; % For the quantizer...
%% Quantizer

[ S, sfc, G ] = AACquantizer(frameFout1, frameType, SMR);


% alpha = 1;
% sym symk
% S = sign(frameF)*


% 13 -> This is implemented at the Quantizer...





