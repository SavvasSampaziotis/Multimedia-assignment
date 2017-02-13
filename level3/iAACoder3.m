function x = iAACoder3(AACSeq3, fNameOut, metadata)
%IAACODER2 Decodes the signal
%   x = iAACoder2(AACSeq1, fNameOut, metadata)
%

N = length(AACSeq3);
x = zeros((N+1)*1024,2);

for i=1:N
    frameType = AACSeq3(i).frameType;
   
    %Inverse TNS filtering
    if strcmp(frameType, 'ESH')
        frameF = zeros(128,16);
        for k=1:8
            frameF(:,k) = iTNS(AACSeq3(i).chl.frameF(:,k), frameType, AACSeq3(i).chl.TNScoeffs(:,k));
            frameF(:,k+8) = iTNS(AACSeq3(i).chr.frameF(:,k), frameType, AACSeq3(i).chr.TNScoeffs(:,k));
            % frameF is 128x16. The columns 1 to 8 contain the LEFT channel and
            % the rest are the rest contain the RIGHT. This is needed for
            % the iFilterbank stage
        end
    else
        frameF = zeros(1024,2);
        frameF(:,1) = iTNS(AACSeq3(i).chl.frameF, frameType, AACSeq3(i).chl.TNScoeffs);
        frameF(:,2) = iTNS(AACSeq3(i).chr.frameF, frameType, AACSeq3(i).chr.TNScoeffs);
    end
    
 
    frameT = iFilterbank(frameF, AACSeq3(i).frameType, AACSeq3(i).winType);
    % ESH frames are now in 128x8x2 format again. 
    
    % Reconstructing the signal with the decoded frames
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
   
end

% extract the padding
n1 = metadata.padding+1;
n2 = length(x) - metadata.padding;
x = x(n1:n2,:);

audiowrite(fNameOut, x, metadata.Fs);

end

