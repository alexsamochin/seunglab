function [merger_diffs, split_diffs]=find_merger_and_split_regions(labels, output, label_mask, begin_coords, end_coords, merger_thresh, split_thresh, max_workers)


% find regions in network output that are causing mergers/leaks
display('finding regions in network output that are causing mergers/leaks');
total_blocksize=[11 11 11];
replace_blocksize=[5 5 5];
blksz=[1 1 1];
[merger_diffs, errmsgs, msgs]=find_majordiff_par_leaks(labels, output>merger_thresh, label_mask, begin_coords, end_coords, total_blocksize, replace_blocksize, blksz, max_workers);

save /tmp/find_merger_and_split_regions_work

% fix merger/leak regions in network output
display('fixing network output to eliminate mergers/leaks');
merger_regions=merger_diffs(:,:,:,3)>0;
merger_regions=repmat(merger_regions, [1 1 1 size(labels,4)]);
fixed_output=output;
fixed_output(find(merger_regions>0))=labels(find(merger_regions>0));


% find objects that have splits from fixed network output
display('computing components from true labels and fixed network output');
fixed_output_masked=fixed_output.*(label_mask>0);
true_comp=connectedComponents(labels(begin_coords(1):end_coords(1), begin_coords(2):end_coords(2), begin_coords(3):end_coords(3), :), mknhood(6));
est_comp=connectedComponents(fixed_output_masked(begin_coords(1):end_coords(1), begin_coords(2):end_coords(2), begin_coords(3):end_coords(3), :)>split_thresh, mknhood(6));
display('finding split objects in fixed network output');
[voxel_score, n_splits, n_mergers, splits, mergers] = MetricsAllMatches(true_comp, est_comp, false, 0, 50, 0);

save /tmp/find_merger_and_split_regions_work

% find regions in network output that are causing splits
display('finding regions in network output that are causing splits');
split_objs=create_split_mask(true_comp, splits);
split_mask=zeros(size(label_mask));
split_mask(begin_coords(1):end_coords(1), begin_coords(2):end_coords(2), begin_coords(3):end_coords(3), :)=repmat(split_objs, [1 1 1 size(label_mask,4)]);
split_mask=split_mask>0;
total_blocksize=[9 9 9];
replace_blocksize=[5 5 5];
[split_diffs, errmsgs, msgs]=find_majordiff_par_leaks(labels, fixed_output>split_thresh, split_mask, begin_coords, end_coords, total_blocksize, replace_blocksize, blksz, max_workers);

save /tmp/find_merger_and_split_regions_work