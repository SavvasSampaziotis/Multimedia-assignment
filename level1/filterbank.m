function frameF = filterbank(frameT, frameType, winType)
%FILTERBANK
% This function implements the windowing function and the mdct calculation.
% frameT = signal with 1 channel per column

if strcmp(frameType, 'OLS')
    N = 2048;
    if (strcmp(winType, 'SIN')) % SINE WINDOW
        [W_LEFT, W_RIGHT] = SineWindow(N);
    else % KBD WINDOW
        [W_LEFT, W_RIGHT] = KBDWindow(N,6);
    end
    W = [W_LEFT, W_RIGHT];
    
    x(:,1) = W'.*frameT(:,1);
    x(:,2) = W'.*frameT(:,2);
    frameF = mdct4(x);
    
elseif strcmp(frameType, 'ESH')
    
    N = 256;
    if (strcmp(winType, 'SIN')) % SINE WINDOW
       [W_LEFT, W_RIGHT] = SineWindow(N);
    else % KBD WINDOW
         [W_LEFT, W_RIGHT] = KBDWindow(N,4);
    end
    W = [W_LEFT, W_RIGHT];
    
    n = 1:256;
    frameF = zeros(128,8,2);
    k=1;
    for i=448:128:1344
        x(:,1) = W'.*frameT(i+n,1);
        x(:,2) = W'.*frameT(i+n,2);
        frameF(:,k,:) = mdct4(x);
        k = k + 1;
    end
    
elseif strcmp(frameType, 'LSS')
    
    if (strcmp(winType, 'SIN')) % SINE WINDOW
        [W_LEFT, ~] = SineWindow(2048);
        [~, W_RIGHT] = SineWindow(256);
    else% KBD WINDOW
        [W_LEFT, ~] = KBDWindow(2048,6);
        [~, W_RIGHT] = KBDWindow(256,4);
    end
    
    W = [W_LEFT, ones(1,448), W_RIGHT, zeros(1,448)];
    x(:,1) = W'.*frameT(:,1);
    x(:,2) = W'.*frameT(:,2);
    frameF = mdct4(x);
    
elseif strcmp(frameType, 'LPS')
    
    if (strcmp(winType, 'SIN')) % SINE WINDOW
        [W_LEFT, ~] = SineWindow(256);
        [~, W_RIGHT] = SineWindow(2048);
    else% KBD WINDOW
       [W_LEFT, ~] = KBDWindow(256,4);
        [~, W_RIGHT] = KBDWindow(2048,6);
    end
    
    W = [zeros(1,448), W_LEFT, ones(1,448), W_RIGHT];
    x(:,1) = W'.*frameT(:,1);
    x(:,2) = W'.*frameT(:,2);
    frameF = mdct4(x);
    
end


end


