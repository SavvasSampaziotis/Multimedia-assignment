function x = iAACoder2(AACSeq2, fNameOut)
%IAACODER1 Decodes the signal
%   x = iAACoder1(AACSeq1, fNameOut, metadata)
%
%
%
%
%
N = length(AACSeq2);
x = zeros((N+1)*1024,2);

for i=1:N
    frameType = AACSeq2(i).frameType;
    %Inverse TNS
    if strcmp(frameType, 'ESH')
        frameF = zeros(128,16);
        for k=1:8
            frameF(:,k) = iTNS(AACSeq2(i).chl.frameF(:,k), frameType, AACSeq2(i).chl.TNScoeffs(:,k), i);
            frameF(:,k+8) = iTNS(AACSeq2(i).chr.frameF(:,k), frameType, AACSeq2(i).chr.TNScoeffs(:,k), 0);
            % frameF is 128x16. The columns 1 to 8 contain the LEFT channel and
            % the rest are the rest contain the RIGHT
        end
    else
        frameF = zeros(1024,2);
        frameF(:,1) = iTNS(AACSeq2(i).chl.frameF, frameType, AACSeq2(i).chl.TNScoeffs, i);
        frameF(:,2) = iTNS(AACSeq2(i).chr.frameF, frameType, AACSeq2(i).chr.TNScoeffs, 0);
    end
    
    frameT = iFilterbank(frameF, AACSeq2(i).frameType, AACSeq2(i).winType);
    % ESH frames are now in 128x8x2 format again. 
    
    if strcmp(frameType, 'ESH')
        frameT_TEMP = zeros(2048,2);
        for k=1:8
            startIndex = 448 + (k-1)*128 + 1;
            endIndex = startIndex + 256-1;
            frameT_TEMP(startIndex:endIndex,1) = frameT_TEMP(startIndex:endIndex,1) + frameT(:,k,1);
            frameT_TEMP(startIndex:endIndex,2) = frameT_TEMP(startIndex:endIndex,2) + frameT(:,k,2);
        end
    else
        frameT_TEMP = frameT;
    end
    startIndex = (i-1)*1024+1;
    endIndex = startIndex+2048-1;
    x(startIndex:endIndex,:) = x(startIndex:endIndex,:) + frameT_TEMP;
   
    
    if max(abs(x(:,1))) > 3
%         disp(num2str(i))
        
    end
end


% audiowrite(fNameOut, x, 48000);

% there is a zero padding of 1024 samples right on the beginning and the end of the signal
% length(x)
% x = x(1025:(length(x)-1024),:);

end

