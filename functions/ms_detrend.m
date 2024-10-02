function eps_detrended = ms_detrend(MS_STRUCT, signals2detrend)

eps_detrended = zeros(size(signals2detrend,1), size(signals2detrend,2));
for e = 1:size(signals2detrend,1)
    signal2detrend = signals2detrend(e,:);
    ep_detrended = detrend(signal2detrend);
    eps_detrended(e,:) = ep_detrended;
end

%%
MS_STRUCT.eps_detrended = eps_detrended;
evalin('base',MS_STRUCT)
end