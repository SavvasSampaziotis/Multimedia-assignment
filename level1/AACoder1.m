function [AACSeq1]= AACoder1(fNameIn)
%AACODER1 Summary of this function goes here
%   Detailed explanation goes here

winType = 'KBD';


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
        prevFrameType = AACSeq1(i-1).frameType;
    end
    
    if i == numOfFrames % LAST FRAME
        nextFrame = [0,0];
    else
        nextFrame =  [frames1(:,i+1),frames2(:,i+1)];
    end
    
    frameType = SSC(frameT, nextFrame, prevFrameType);
    
    frameF = filterbank(frameT, frameType, winType);
    
    if strcmp(frameType, 'ESH')
        % disp([ frameType, num2str(i)]); rR 
        chl = struct('frameF',frameF(:,:,1));
        chr = struct('frameF',frameF(:,:,2));
    else
        chl = struct('frameF',frameF(:,1));
        chr = struct('frameF',frameF(:,2));
    end
    
    AACSeq1(i) = struct('frameType', frameType, 'winType', winType, 'chl', chl, 'chr', chr);
    
end

end
