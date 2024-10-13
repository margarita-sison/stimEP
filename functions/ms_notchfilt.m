function x_notchfilt = ms_notchfilt(x, fs, fo, q);

bw = (fo/(fs/2))/q;
[b,a] = iircomb(fs/fo,bw,'notch'); % Note type flag 'notch'
x_notchfilt = filtfilt(b, a, x);
end
