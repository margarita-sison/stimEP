# stimEP
%% What you can do with this pipeline:
% 1 - Visually inspect EMG signals before selecting a template EMG signal
% 2 - Trim the template EMG signal before extracting stimulus artifact peaks
% 3 - Extract stimulus artifact peaks from template EMG signal
% 4 - Align stimulus artifact peaks in template EMG signal with ECOG and/or LFP signals
% 5 - Extract epochs from ECOG or LFP signals based on a specified time window around the stimulus artifact peaks
% 6 - Average epochs to generate evoked potentials
% 7 - Apply a baseline correction to the evoked potentials
% 8 - Detrend evoked potentials if necessary
% 9 - Average evoked potentials from the same brain region (e.g, primary motor cortex)
% 10 - Extract post-stimuulus peaks from evoked potentials
% 11 - Plot average evoked potentials by brain region