function [peaks, pk_locs, pk_widths, pk_proms, min_prom] = ms_findpeaks(segment)

[~, ~, ~, pk_proms] = findpeaks(segment);
max_prom = (max(pk_proms));

threshold = input('Enter threshold as decimal: ');
min_prom = threshold*max_prom;
findpeaks(segment,'MinPeakProminence',min_prom)

user_ans = input('Adjust threshold? Y/N: ',"s");

while user_ans == "Y"
    threshold = input('Enter threshold as decimal: ');
    min_prom = threshold*max_prom;
    findpeaks(segment,'MinPeakProminence',min_prom) 

    user_ans = input('Adjust threshold? Y/N: ',"s");
end

[peaks, pk_locs, pk_widths, pk_proms] = findpeaks(segment,'MinPeakProminence',min_prom);
