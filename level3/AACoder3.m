function [AACSeq3, metadata]= AACoder3(fNameIn)
%AACODER1 Summary of this function goes here
%   Detailed explanation goes here

winType = 'SIN';
winType = 'KBD';

[y, Fs] = audioread(fNameIn);
extra = 0;
if mod(length(y),2) == 1 % Number of Samples is ODD
%     y = y(1:length(y)-1,:);
    y = [y; [0,0]];
    extra = 1;
end

N = length(y);
if mod(N,1024) ~= 0 % Signal needs additional zero padding for proper sequence segmentation
    padNum = 1024  - ceil(mod(N,1024))/2; % a total of Zero pad 1024 samples at the start and at the end of the signal.
    padding = zeros(padNum, 2);
    y = [padding; y ;padding];
    numOfFrames = length(y)/1024;
end

metadata = struct('Fs', Fs, 'padding', padNum, 'extra', extra);

n = 1:2048;
frameTprev1 =zeros(2048, 2);
frameTprev2 =zeros(2048, 2);
for i=1:(numOfFrames-1)
    
    prog = floor(i*100/numOfFrames);
    if ismember(prog, [25,50,75,90])
        disp(['Coder has completed ', num2str(prog),'% of the signal']);
    end
    
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
    frameIsESH = strcmp(frameType, 'ESH');
    % FilterBank - Windowing and MDCT
    frameF = filterbank(frameT, frameType, winType);
    
    % TNS and channel struct
    if frameIsESH
%       disp([ frameType, num2str(i)]);
        frameFout1 = zeros(128,8);
        frameFout2 = zeros(128,8);
        TNSCoeffs1 = zeros(4,8);
        TNSCoeffs2 = zeros(4,8);
        for k=1:8
            [frameFout1(:,k), TNSCoeffs1(:,k)] = TNS(frameF(:,k,1), frameType);
            [frameFout2(:,k), TNSCoeffs2(:,k)] = TNS(frameF(:,k,2), frameType);
        end
    else
        [frameFout1, TNSCoeffs1] = TNS(frameF(:,1), frameType);
        [frameFout2, TNSCoeffs2] = TNS(frameF(:,2), frameType);
    end
    
    % Psychoacoustic Stage:
    SMR1 = psycho(frameT(:,1), frameType, frameTprev1(:,1),frameTprev2(:,1));
    SMR2 = psycho(frameT(:,2), frameType, frameTprev1(:,2),frameTprev2(:,2));
    frameTprev1 = frameT;
    frameTprev2 = frameTprev1;
    
    % Quantizing
    [S1, sfc1, G1, T1] = AACquantizer(frameFout1, frameType, SMR1);
    [S2, sfc2, G2, T2] = AACquantizer(frameFout2, frameType, SMR2);
    
    if frameIsESH
        sfc1 = [sfc1(:,1); sfc1(:,2); sfc1(:,3); sfc1(:,4); sfc1(:,5); sfc1(:,6); sfc1(:,7); sfc1(:,8)];
        sfc2 = [sfc2(:,1); sfc2(:,2); sfc2(:,3); sfc2(:,4); sfc2(:,5); sfc2(:,6); sfc2(:,7); sfc2(:,8)];
        S1 = [S1(:,1); S1(:,2); S1(:,3); S1(:,4); S1(:,5); S1(:,6); S1(:,7); S1(:,8)];
        S2 = [S2(:,1); S2(:,2); S2(:,3); S2(:,4); S2(:,5); S2(:,6); S2(:,7); S2(:,8)];
    end
    
    [sfc1_huff, ~] = encodeHuff(sfc1, loadLUT, 12);
    [sfc2_huff, ~] = encodeHuff(sfc2, loadLUT, 12); % huffCodebook == 12
    [frameF1_huff, huffCodebook1] = encodeHuff(S1, loadLUT);
    [frameF2_huff, huffCodebook2] = encodeHuff(S2, loadLUT);
    
    chl = struct('TNScoeffs', TNSCoeffs1, 'T', T1, 'G', G1, 'sfc', sfc1_huff, 'stream', frameF1_huff, 'codebook', huffCodebook1);
    chr = struct('TNScoeffs', TNSCoeffs2, 'T', T2, 'G', G2, 'sfc', sfc2_huff, 'stream', frameF2_huff, 'codebook', huffCodebook2);
    
    %     if ( i == 15 )
    %         subplot(1,2,1); plot( [frameF(:,1),frameFout1]);
    %         subplot(1,2,2); plot( frameFout1-frameF(:,1));
    %         %     [ S, sfc, G ] = AACquantizer(frameF, frameType, SMR);
    %         NB = 69;
    %     end
    
    AACSeq3(i) = struct('frameType', frameType, 'winType', winType, 'chl', chl, 'chr', chr);
end


end

