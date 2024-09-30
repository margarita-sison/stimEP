function chanLocs_overview = ms_chanLocs_overview(ep_dir, ms_struct)

load(ep_dir)
ephys_num = str2double(ms_struct.ephys(6:end));

chanLocs_overview = {"channelLocsSimpleBipolar"; "channelLocsSimpleMonopolar"; "channelLocsBipolar"; "channelLocsMonopolar"; "channelLocs"; "channelLocsSimple"}; 

for l = 1:length(chanLocs_overview)
    chanLocs_field = chanLocs_overview{l};
    chanLocs = getfield(EP(ephys_num), chanLocs_field);
    chanLocs_overview(l,2) = {length(chanLocs)};
    chanLocs_overview(l,3:length(chanLocs)+2) = chanLocs;
end
end