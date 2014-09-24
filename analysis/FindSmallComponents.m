function [small_components, big_components] = FindSmallComponents(comp,vol_thresh,verbose);

list = unique(comp);
num = length(list);

sizes = hist(single(comp(:)),single(list));

% Sort the list in descending order of size
[sorted_size, ind] = sort(sizes, 'ascend');  
list = list(ind);

i=0;
while(sorted_size(i+1)<=vol_thresh)
	i=i+1;
end

if(i>0)
	small_components=list(1:i-1);
	big_components=list(i:end);
else
	small_components=[];
	big_components=list;
end
