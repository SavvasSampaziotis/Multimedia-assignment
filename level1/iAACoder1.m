function x = iAACoder1(AACSeq1, fNameOut, metadata)
%IAACODER1 Decodes the signal
%   x = iAACoder1(AACSeq1, fNameOut, metadata)
%   
%   
%
N = length(AACSeq1);
x = zeros((N+1)*1024,2);

for i=1:N
    frameF = [AACSeq1(i).chl.frameF, AACSeq1(i).chr.frameF];
    
    frameT = iFilterbank(frameF, AACSeq1(i).frameType, AACSeq1(i).winType);
    
    if strcmp(AACSeq1(i).frameType, 'ESH')
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
x(1025:(length(x)-1024),:);

end

