function [AACSeq2]= AACoder2(fNameIn)
%AACODER1 Summary of this function goes here
%   Detailed explanation goes here

winType = 'SIN';

if nargin==0
    load('level3.mat');
else
    [y,~] = audioread(fNameIn);
    if mod(length(y),2) == 1 % Number of Samples is ODD
        y = y(1:length(y)-1,:);
    end
end

[frames1,~] = linframe(y(:,1), 1024, 2048, 'sym');
[frames2,~] = linframe(y(:,2), 1024, 2048, 'sym');

[~, numOfFrames] =size(frames1);

for i=1:numOfFrames
    
    frameT = [frames1(:,i), frames2(:,i)];
    
    if i == 1 % FIRST FRAME
        prevFrameType = 'OLS';
    else
        prevFrameType = AACSeq2(i-1).frameType;
    end
    if i == numOfFrames % LAST FRAME
        nextFrame = [0,0];
    else
        nextFrame =  [frames1(:,i+1),frames2(:,i+1)];
    end
    
    % Seqcuence Segmentation
    frameType = SSC(frameT, nextFrame, prevFrameType);
    
    % FilterBank - Windowing and MDCT
    frameF = filterbank(frameT, frameType, winType);
    
    % TNS and channel struct
    if strcmp(frameType, 'ESH')
        disp([ frameType, num2str(i)]);
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
    
    AACSeq2(i) = struct('frameType', frameType, 'winType', winType, 'chl', chl, 'chr', chr);
end


end

