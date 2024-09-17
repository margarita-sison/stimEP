function [start_idx, end_idx, segment] = ms_trimsignal(signal2trim)

fig = figure;
fig.WindowState = 'maximized';

plot(signal2trim)
[x, y] = ginput(2);

start_idx = x(1);
end_idx = x(2);
segment = signal2trim(start_idx:end_idx);
plot(segment)
end