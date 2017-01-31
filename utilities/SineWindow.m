
function [W_SIN_LEFT, W_SIN_RIGHT] = SineWindow(N)
n = 0:(N/2-1);
W_SIN_LEFT = sin(pi*(n + (1/2))/N);
n = (N/2):(N-1);
W_SIN_RIGHT = sin(pi*(n + (1/2))/N);
end