function [all_max]=stack_max(stack)
all_max=-Inf;
for i=1:size(stack,3)
	max_slice=max(max(stack(:,:,i)));
	if(max_slice>all_max)
		all_max=max_slice;
	end
end