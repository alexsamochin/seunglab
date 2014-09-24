for direction=1:3
	dsizes=sizes(:,direction);
	[dsort_size{direction}, dsort_idx{direction}]=sort(dsizes,'descend');
end
