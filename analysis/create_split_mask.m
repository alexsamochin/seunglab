function [split_mask]=create_split_mask(comp, split_list)

split_mask=zeros(size(comp), 'single');

for i=1:length(split_list)
	select_comp=comp==split_list{i}{1};
	split_mask(find(select_comp>0))=1;
end

