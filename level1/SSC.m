function [ frameType ] = SSC( frameT, nextFrameT, prevFrameType )
%% SSC: This functions accepts requires both channels of audio to realise the
% segmentation
% “OLS”: ãéá ONLY_LONG_SEQUENCE
% “LSS”: ãéá LONG_START_SEQUENCE
% “ESH”: ãéá EIGHT_SHORT_SEQUENCE
% “LPS”: ãéá LONG_STOP_SEQUENCE


% Channel 1
s1 = SSCsinglechannel(frameT(:,1), nextFrameT(:,1), prevFrameType);
% Channel 2
s2 = SSCsinglechannel(frameT(:,2), nextFrameT(:,2), prevFrameType);


%% Decide Final Frame Type
% SAVVAS: further method has been tested and works
FinalTypeMap = {
    'OLS','LSS','ESH','LPS';
    'LSS','LSS','ESH','ESH';
    'ESH','ESH','ESH','ESH';
    'LPS','ESH','ESH','LPS';};
frameType = FinalTypeMap(S2index(s1),S2index(s2));
end

%
%
%
%
function [ frameType ] = SSCsinglechannel( frameT, nextFrameT, prevFrameType)
%% SSCSINGLECHANEL
% Final frame is handled:
% First Frame is considered automatically an OLS frame

%%
if strcmp(prevFrameType, 'NONE')
    % SPECIAL CASE: FRAME IS THE FIRST ONE
    % No previous frame in existance... we will determine if the frame is ESH
    % or OLS
    prevFrameType = 'OLS';
    
end

%%

switch S2index(prevFrameType)
    case S2index('OLS')
        % Frame can be only OLS or LSS
        if nextFrameT == 0
            %  SPECIAL CASE: final frame and there is no next frame
            frameType = 'OLS';
        else % Check neXt frame...
            if frameIsESH(nextFrameT)
                frameType = 'LSS';
            else
                frameType = 'OLS';
            end
        end
    case S2index('ESH')
        % Frame can be only ESH or LPS
        if nextFrameT == 0
            % SPECIAL CASE: final frame and there is no next frame
            if frameIsESH(frameT)
                frameType = 'ESH'
            else
                frameType = 'LPS';
            end
        else
            % Check next frame...
            if frameIsESH(nextFrameT)
                frameType = 'ESH';
            else
                frameType = 'LPS';
            end
        end
    case S2index('LSS')
        % Frame can be only ESH
        frameType = 'ESH';
    case S2index('LPS')
        % Frame can be only OLS
        frameType = 'OLS';
end

end

%
%
%
%
function result = frameIsESH(frame)
%% Returns 1 if frame is indeed ESH or 0 if not

% Filter with HPF
y = filter([0.7548, -0.7548], [1, -0.5095], frame);

% Energy of each 128 partition
n = 1:128;
k=1;
s2 = zeros(8,1);
for i=576:128:1472
    s2(k) = sum(y(i+n).^2); % Energy of short segmented signal 
    k = k+1;
end

% Calc attack values
ds = ones(8,1); % ds(1) = 0 and is not really needed...
for l=2:8
    S = mean(s2(1:(l-1)));
    ds(l) = s2(l)/S;
end

% Check if attack values and short sequence energy qualify for ESH
result = 0;
for i=2:8
    if (s2(i) > 10^-3) && (ds(i) > 10)
        %  disp('ESH!!!');
        result = 1;
        % plot(abs(fft(frame))); hold on; plot(abs(fft(y)),'r'); hold off;
        break;
    end
end
end

function i = S2index(sequenceType)
%%
% This function returns
% 1 for 'OLS'
% 2 for 'LSS'
% 3 for 'EHS'
% 4 for 'LPS'
% So that the final Frame Type can be decided via a decision array

if strcmp(sequenceType,'OLS')
    i=1;
elseif strcmp(sequenceType,'LSS')
    i=2;
elseif strcmp(sequenceType,'ESH')
    i=3;
elseif strcmp(sequenceType,'LPS')
    i=4;
end

end
