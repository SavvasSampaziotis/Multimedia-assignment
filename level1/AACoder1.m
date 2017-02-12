function [AACSeq1, metadata]= AACoder1(fNameIn, metadata)
%AACODER1 Summary of this function goes here
%   Detailed explanation goes here

winType = 'SIN';

[y, Fs] = audioread(fNameIn);
if mod(length(y),2) == 1 % Number of Samples is ODD
    y = y(1:length(y)-1,:);
end

N = length(y);
if mod(N,1024) ~= 0 % Signal needs additional zero padding for proper sequence segmentation
    padNum = 1024 + 1024/2 - ceil(mod(N,1024))/2; % a total of Zero pad 1024 samples at the start and at the end of the signal.
    padding = zeros(padNum, 2);
    y = [padding; y ;padding];
    numOfFrames = length(y)/1024;
end
length(y)
metadata = struct('Fs', Fs, 'padding', padNum);

n = 1:2048;
for i=1:(numOfFrames-1)
    
    frameT = y(n+(i-1)*1024,:);
    
    if i == 1 % FIRST FRAME
        prevFrameType = 'OLS';
    else
        prevFrameType = AACSeq1(i-1).frameType;
    end
    
    if i == numOfFrames-1 % Currently proccessing LAST FRAME
        nextFrame = [0,0];
    else        
        nextFrame =  y(n + i*1024, :);
    end
    
    frameType = SSC(frameT, nextFrame, prevFrameType);
    
    frameF = filterbank(frameT, frameType, winType);
    
    if strcmp(frameType, 'ESH')
%         disp([ frameType, num2str(i)]);
        chl = struct('frameF',frameF(:,:,1));
        chr = struct('frameF',frameF(:,:,2));
    else
        chl = struct('frameF',frameF(:,1));
        chr = struct('frameF',frameF(:,2));
    end
    
    AACSeq1(i) = struct('frameType', frameType, 'winType', winType, 'chl', chl, 'chr', chr);
    
end


end

