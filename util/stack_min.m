function [all_min]=stack_min(stack)
all_min=Inf;
for i=1:size(stack,3)
	min_slice=min(min(stack(:,:,i)));
	if(min_slice<all_min)
		all_min=min_slice;
	end
end