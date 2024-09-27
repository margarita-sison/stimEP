function eps_demeaned = ms_baselinecorrect(ms_struct, baselineperiod)

evoked_potentials = ms_struct.evoked_potentials; % the EPs to subtract the averaged baseline from
eps_demeaned = zeros(size(evoked_potentials,1), size(evoked_potentials,2)); % baseline-corrected EPs

% Prepare x-axis values in ms
start_time = ms_struct.timewindow(1); % start time in ms
end_time = ms_struct.timewindow(2); % end time in ms

samples_per_ms = ms_struct.fs/1000; % sampling rate in ms

xaxis_ms = start_time:1/samples_per_ms:end_time; % x-axis values in ms

bs_start_idx = find(xaxis_ms == baselineperiod(1));
bs_end_idx = find(xaxis_ms == baselineperiod(2));

for e = 1:size(evoked_potentials,1)
    evoked_potential = evoked_potentials(e,:);

    baseline = evoked_potential(bs_start_idx:bs_end_idx);
    baseline_mean = mean(baseline);

    ep_demeaned = evoked_potential-baseline_mean;
    eps_demeaned(e,:) = ep_demeaned;
end
end