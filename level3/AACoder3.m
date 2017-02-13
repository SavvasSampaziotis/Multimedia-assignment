function [AACSeq3, metadata]= AACoder3(fNameIn)
%AACODER1 Summary of this function goes here
%   Detailed explanation goes here

winType = 'SIN';

[y, Fs] = audioread(fNameIn);
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

metadata = struct('Fs', Fs, 'padding', padNum);

n = 1:2048;
for i=1:(numOfFrames-1)
    
    frameT = y(n+(i-1)*1024,:);
    
    if i == 1 % FIRST FRAME
        prevFrameType = 'OLS';
    else
        prevFrameType = AACSeq3(i-1).frameType;
    end
    
    if i == numOfFrames-1 % Currently proccessing LAST FRAME
        nextFrame = [0,0];
    else
        nextFrame =  y(n + i*1024, :);
    end
    
    % Seqcuence Segmentation
    frameType = SSC(frameT, nextFrame, prevFrameType);
    
    % FilterBank - Windowing and MDCT
    frameF = filterbank(frameT, frameType, winType);
    
    % TNS and channel struct
    if strcmp(frameType, 'ESH')
        %         disp([ frameType, num2str(i)]);
        frameFout1 = zeros(128,8);
        frameFout2 = zeros(128,8);
        TNSCoeffs1 = zeros(4,8);
        TNSCoeffs2 = zeros(4,8);
        for k=1:8
            [frameFout1(:,k), TNSCoeffs1(:,k)] = TNS(frameF(:,k,1), frameType);
            [frameFout2(:,k), TNSCoeffs2(:,k)] = TNS(frameF(:,k,2), frameType);
        end
        chl = struct('frameF',frameFout1, 'TNScoeffs', TNSCoeffs1);
        chr = struct('frameF',frameFout2, 'TNScoeffs', TNSCoeffs2);
    else
        [frameFout1, TNSCoeffs1] = TNS(frameF(:,1), frameType);
        [frameFout2, TNSCoeffs2] = TNS(frameF(:,2), frameType);
        chl = struct('frameF',frameFout1, 'TNScoeffs', TNSCoeffs1);
        chr = struct('frameF',frameFout2, 'TNScoeffs', TNSCoeffs2);
    end
    
    % Psychoacoustic Stage:
    if i > 2
        SMR1 = psycho(frameT(:,1), frameType, frameTprev1(:,1),frameTprev2(:,1));
        SMR2 = psycho(frameT(:,2), frameType, frameTprev1(:,2),frameTprev2(:,2));
    else
        NB = 69;
        if strcmp(frameType, 'ESH')
            NB = 49;
        end
        % SMR1 = 1*ones(NB,1);
        % SMR2 = 1*ones(NB,1);
        fZ = zeros(length(frameT), 1)
        SMR1 = psycho(frameT(:,1), frameType, fZ, fZ);
        SMR2 = psycho(frameT(:,2), frameType, fZ, fZ);
    end
    
%     [ S, sfc, G ] = AACquantizer(frameF, frameType, SMR);
    
    AACSeq3(i) = struct('frameType', frameType, 'winType', winType, 'chl', chl, 'chr', chr);
end


end

