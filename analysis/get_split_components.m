function [split_cmps] = get_split_components(cmp)

cmps=unique(cmp(:))';

split_cmps=[];

for c=cmps
	if(c>0)
		num_parts=unique(bwlabeln(cmp==c,6));
		if(nnz(num_parts)>1)
			c
			
			% this component has been broken, try a lower threshold
			split_cmps=[split_cmps; c];
		end
	end
end
