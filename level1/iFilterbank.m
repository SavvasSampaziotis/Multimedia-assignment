function frameT = iFilterbank(frameF, frameType, winType)

if strcmp(frameType, 'OLS')
    
    N = 2048;
    if (strcmp(winType, 'SIN')) % SINE WINDOW
        [W_LEFT, W_RIGHT] = SineWindow(N);
    else % KBD WINDOW
        [W_LEFT, W_RIGHT] = KBDWindow(N, 6);
    end
    W = [W_LEFT, W_RIGHT];
    
    y = imdct4(frameF);
    frameT(:,1) = W'.*y(:,1);
    frameT(:,2) = W' .*y(:,2);
    
    
elseif strcmp(frameType, 'ESH')
    % WARNING. frameF has size 128x16 (both
    % channels have been concacated)
    
    N = 256;
    if (strcmp(winType, 'SIN')) % SINE WINDOW
        [W_LEFT, W_RIGHT] = SineWindow(N);
    else % KBD WINDOW
        [W_LEFT, W_RIGHT] = KBDWindow(N, 4);
    end
    W = [W_LEFT, W_RIGHT];
    
    frameT_TEMP = imdct4(frameF);
    frameT(:,:,1) = frameT_TEMP(:,1:8); % Channel Left
    frameT(:,:,2) = frameT_TEMP(:,9:16);% Channel Right
    
    for channel=1:2
        for i=1:8
            frameT(:,i,channel) = W'.*frameT(:,i,channel); 
        end
    end
    
elseif strcmp(frameType, 'LSS')
    
    if (strcmp(winType, 'SIN')) % SINE WINDOW
        [W_LEFT, ~] = SineWindow(2048);
        [~, W_RIGHT] = SineWindow(256);
    else % KBD WINDOW
        [W_LEFT, ~] = KBDWindow(2048,6);
        [~, W_RIGHT] = KBDWindow(256,4);
    end
    
    y = imdct4(frameF);
    W = [W_LEFT, ones(1,448),W_RIGHT, zeros(1,448)];
    frameT(:,1) = W'.*y(:,1);
    frameT(:,2) = W'.*y(:,2);
    
    
elseif strcmp(frameType, 'LPS')
    
    if (strcmp(winType, 'SIN')) % SINE WINDOW
        [W_LEFT, ~] = SineWindow(256);
        [~, W_RIGHT] = SineWindow(2048);
    else % KBD WINDOW
        [W_LEFT, ~] = KBDWindow(256,4);
        [~, W_RIGHT] = KBDWindow(2048,6);
    end
    
    y = imdct4(frameF);
    W = [zeros(1,448), W_LEFT, ones(1,448), W_RIGHT];
    frameT(:,1) = W'.*y(:,1);
    frameT(:,2) = W'.*y(:,2);
    
end



end
