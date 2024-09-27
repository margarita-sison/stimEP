function averaged_EPs = ms_averageEPs(ep_dir, ms_struct)
%% Extract channel labels (annotations) from 'EP' struct
load(ep_dir) % where we get the channel labels (annotations)

ephys_num = str2double(ms_struct.ephys(6:end));

if montage == "monopolar"
    chan_annots = EP(ephys_num).channelLocsSimpleMonopolar; 
elseif montage == "bipolar"
    chan_annots = EP(ephys_num).channelLocsSimpleBipolar;
end

%% 
rois = unique(chan_annots);
eps_poststim = ms_struct.eps_poststim;
averaged_EPs = zeros(length(rois),size(eps_poststim,2));

for r = 1:length(rois)
    averaged_EP = mean(eps_poststim(strcmp(chan_annots,rois{r}),:),1);
    averaged_EPs(r,:) = averaged_EP;
end