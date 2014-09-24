% merge list of components merge_list from a component file comp
% arguments: comp, merge_list
% merge_list format: {{1, 2}, {3, 4, 5}} merges 1&2, and 3&4&5
% returns: comp
function [comp]=merge_components(comp, merge_list)

for i=1:length(merge_list)
	list=merge_list{i}
	
	for j=2:length(list)
		ind = find(comp == list{j});
		comp(ind) = list{1};
	end
end

