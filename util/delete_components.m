% delete list of components delete_list from a component file comp
% arguments: comp, delete_list
% returns: comp

function [comp]=delete_components(comp, delete_list)

for i=1:length(delete_list)
	delete_list(i)
	ind = find(comp == delete_list(i));
	comp(ind) = 0;
end

