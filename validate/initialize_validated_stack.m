function []=initialize_validated_stack(comp_filename, validated_filename, threshold)

load(validated_filename);
comp_file=load(comp_filename);
comp=eval(sprintf('comp_file.comp%d', threshold));


comp_idxs=nonzeros(unique(comp));
[mins, maxs, labels]=ComponentBoundingBox(comp);
valid_comp=zeros(size(comp),'single');

for k=1:length(comp_idxs)
	k
	valid_info(k).comp_num=k;
	valid_info(k).cell_type='unknown';
	valid_info(k).min_yxz=mins(find(labels==comp_idxs(k)),:);
	valid_info(k).max_yxz=maxs(find(labels==comp_idxs(k)),:);
	valid_info(k).constituent(1).comp_num=k;
	valid_info(k).constituent(1).thresh=threshold;
	valid_info(k).constituent(1).filename=comp_filename;
	
	this_comp=comp==comp_idxs(k);
	valid_comp=valid_comp + single((this_comp*k));		
end

state.n_valid=k;

save(validated_filename,'valid_info','state','valid_comp','problem_area');