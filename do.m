clear; clc;

%fName = 'alex_jones_modernstudio';
fName =  'LicorDeCalandraca';
fNameIn = ['songs\',fName,'.wav'];
fNameOut = ['exports\',fName,'_SAVVAS_1.wav'];
%
snr = demoAAC2(fNameIn, fNameOut);

snr
% 
% [AACSeq] = AACoder2();
% x = iAACoder2(AACSeq, fNameOut);
% 
% 
% load('level3.mat')
% plot(x-y)
%  AACSeq1 = AACoder1();
% load('AACSeq.mat');
% i = 134;


%[Fout,TNS] = TNS(frameF, 'OLS');
% Fout = iTNS(Fout, 'OLS', TNS);


%
% iTNS test
%
% frameF = AACSeq(i).chl.frameF;
% frameType = AACSeq(i).frameType;
% if strcmp(frameType, 'ESH') continue; end
% 
% TNScoefs = TNSDequantizer(AACSeq(i).chl.TNScoefs);
% if ~isstable(1,[1;-TNScoefs ])
%     disp(['[TNS] Filter UNSTABLE ', frameType]);
%     
%     H = tf(1, [1;-TNScoefs]', 0.01)
%     %      [~,P,~,~]= zpkdata(H)
%     %Hitns = tf(1,[1;a_]);
% end
% frameFout = filter(1,[1; - TNScoefs ], frameF);
% 
% frameFORIGINAL = AACSeq1(i).chl.frameF;

%Let'w try the reverse filtering...


% clf;
% hold on;
% subplot(1,2,1); plot(frameF, 'r'); plot(1./Sw, 'g')
% subplot(1,2,2); plot(frameFw);
% hold off;
% %snr = demoAAC1([fNameIn, '.wav'], ['exports\', fNameOut, '.wav'])

