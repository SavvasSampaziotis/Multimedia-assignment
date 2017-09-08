function [SNR, bitrate, compression] = demoAAC3(fNameIn, fNameOut)
% DEMOAAC3 Codes andDecodes a given wav file...
% bitrate is a VECTOR, containing the bitrate per frame for both channels.
% compression is calculated as the compressedSize/uncompressedSize*100%
%%
% load('AACSeq3.mat');
disp('Audio Coding has started...');
tic;
[AACSeq, metadata] = AACoder3(fNameIn);
t1 = toc;

%%
disp('Audio Decoding has started...');
tic;
x = iAACoder3(AACSeq, fNameOut, metadata);
t2 = toc;
disp(['Audio decoding has finished:']);

%% SNR Calculation
[y, Fs] = audioread(fNameIn);
e = y-x;
Px = mean(x.^2);
Pe = mean(e.^2);
SNR = 10*log10(Px) - 10*log10(Pe);

%% Bitrate and Compression
[bitrate, compressedSize] = calcBitrate(AACSeq);
f = audioinfo(fNameIn);
originalBitrate = f.BitsPerSample*f.SampleRate*f.NumChannels;
compression = originalBitrate/mean(bitrate); % = originalSize/compressedSize

%% Display results
originalSize = f.TotalSamples*f.NumChannels*f.BitsPerSample;
disp(['Coding time is ', num2str(t1)]);
disp(['Decoding time is ', num2str(t2)]);
disp(['Uncompressed Audio: ' num2str(originalSize),' bits']);
disp(['Compressed Struct: ' num2str(compressedSize),' bits']);
disp(['Compression Ratio: ', num2str(compressedSize/originalSize*100),' % (x ', num2str(compression), ')']);
disp(['Channel 1 SNR: ', num2str(SNR(1)), ' dB']);
disp(['Channel 2 SNR: ', num2str(SNR(2)), ' dB']);
%%
save('AACSeq3.mat');
end


function [bitrate,compressedSize] = calcBitrate(AACSeq)
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
compressedSize = sum(BitPerFrame);
%bitrate = bits/sec = samples/sec * frames/sample * bits/frame
bitrate = 48000*BitPerFrame/1024;

end