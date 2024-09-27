function eps_detrended = ms_detrend(eps2detrend)

eps_detrended = zeros(size(eps2detrend,1), size(eps2detrend,2)); % empty container for detrended EPs

for e = 1:size(eps2detrend,1)
    ep2detrend = eps2detrend(e);
    ep_detrended = detrend(ep2detrend);
    eps_detrended(e,:) = ep_detrended;
end
end