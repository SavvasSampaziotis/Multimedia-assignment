function [SNR, bitrate, compression] = demoAAC3(fNameIn, fNameOut)
% DEMOAAC3 Codes andDecodes a given wav file...
% bitrate is a VECTOR, containing the bitrate per frame for both channels.
% compression is calculated as the compressedSize/uncompressedSize*100%  
%%
% load('AACSeq3.mat');
disp('Audio Coding has started...');
tic;
[AACSeq, metadata] = AACoder3(fNameIn);
t = toc;
disp(['Audio Coding has finished: Coding time = ', num2str(t)]);



%%

disp('Audio Decoding has started...');
tic;
x = iAACoder3(AACSeq, fNameOut, metadata);
t = toc;
disp(['Audio Coding has finished: Decoding time = ', num2str(t)]);


%% SNR Calculation

[y, Fs] = audioread(fNameIn);
padding = zeros(metadata.padding, 2);

if mod(length(y),2) == 1 % Number of Samples is ODD.
    y = y(1:length(y)-1,:);
end

e = y-x;

Px = mean(x.^2);
Pe = mean(e.^2);
SNR = 10*log10(Px) - 10*log10(Pe);

sound(x,metadata.Fs);


bitrate = calcBitrate(AACSeq);

f = audioinfo(fNameIn);
originalBitrate = f.BitsPerSample*f.SampleRate*f.NumChannels;

compression = originalBitrate/mean(bitrate);


save('AACSeq3.mat');
end


function [bitrate] = calcBitrate(AACSeq)
% bits/frame = MDCTstream_huff + SFCstream_huff + GlobalGainBits
% + TNSCoeffsBits + huffCodeBook(==4bits)
% TNS coeffs are coded with 4 bits . As a result TNSCoeffsBits = 4bits*4
% for LONG windows, and 4bits*4*8 for ESH windows
%
% As for global gain, I assume 8bits are enough and that there will be 
% info on a header about it's position and length on the bit stream... 
% 2-3 bits more isn't big a deal anyway.

BitPerFrame = zeros(length(AACSeq),1);
for i=1:length(AACSeq)
    
    GlobalGainBits2 = 8*length(AACSeq(i).chr.G);
    GlobalGainBits1 = 8*length(AACSeq(i).chl.G); % ==8 for ESH and ==1 for OLS/LSS/LSP
    
    chr_bits = length(AACSeq(i).chr.stream) + length(AACSeq(i).chr.sfc) + GlobalGainBits2 + 4*numel(AACSeq(i).chr.TNScoeffs) + 4;
    chl_bits = length(AACSeq(i).chl.stream) + length(AACSeq(i).chl.sfc) + GlobalGainBits1 + 4*numel(AACSeq(i).chl.TNScoeffs) + 4;
    
    BitPerFrame(i) = (chr_bits + chl_bits);

end

%bitrate = bits/sec = samples/sec * frames/sample * bits/frame
bitrate = 48000*BitPerFrame/1024;

end