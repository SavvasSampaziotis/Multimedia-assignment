function [W_L, W_R] = SineWindow(N)
% SINEWINDOW This function returns the right and left halves of a Sine
% window of N points.
n = 0:(N/2-1);
W_L = sin(pi*(n + (1/2))/N);
n = (N/2):(N-1);
W_R = sin(pi*(n + (1/2))/N);
end