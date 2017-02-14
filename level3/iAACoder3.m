function x = iAACoder3(AACSeq3, fNameOut, metadata)
%IAACODER2 Decodes the signal
%   x = iAACoder2(AACSeq1, fNameOut, metadata)
%

N = length(AACSeq3);
x = zeros((N+1)*1024,2);

for i=1:N
    prog = floor(i*100/N);
    if ismember(prog, [25,50,75,90])
        disp(['Coder has completed ', num2str(prog),'% of the signal']);
    end
    
    frameType = AACSeq3(i).frameType;
    
    % Huffman decoding
    S1 = decodeHuff( AACSeq3(i).chl.stream, AACSeq3(i).chl.codebook, loadLUT());
    S2 = decodeHuff( AACSeq3(i).chr.stream, AACSeq3(i).chr.codebook, loadLUT());
    sfc1 = decodeHuff(AACSeq3(i).chl.sfc, 12, loadLUT());
    sfc2 = decodeHuff(AACSeq3(i).chr.sfc, 12, loadLUT());
    % WARNING: For ESH frames, decoded sfc and mdct coeffs are vectorised!
    % size = [1024x1]. 
    
    %Inverse Quantizing
    frameF1 = iAACquantizer(S1, sfc1, AACSeq3(i).chl.G, frameType);
    frameF2 = iAACquantizer(S2, sfc2, AACSeq3(i).chr.G, frameType);
    
    if strcmp(frameType, 'ESH')
        frameF = zeros(128,16);
        for k=1:8
            %Inverse TNS filtering
            frameF(:,k)   = iTNS(frameF1(:,k), frameType, AACSeq3(i).chl.TNScoeffs(:,k));
            frameF(:,k+8) = iTNS(frameF2(:,k), frameType, AACSeq3(i).chr.TNScoeffs(:,k));
            % frameF is 128x16. The columns 1 to 8 contain the LEFT channel and
            % the rest are the rest contain the RIGHT. This is needed for
            % the iFilterbank stage
        end
    else
        frameF = zeros(1024,2);
        
        %Inverse TNS filtering
        frameF(:,1) = iTNS(frameF1, frameType, AACSeq3(i).chl.TNScoeffs);
        frameF(:,2) = iTNS(frameF2, frameType, AACSeq3(i).chr.TNScoeffs);
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

