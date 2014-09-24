function [comp_out, sizes, labels_out] = SortComponents(comp_in, labels)
% SortComponents(comp_in) - Sort the components in order of decreasing
% size.
%
%   comp_in - Sparse components (from comp2mat)
%
%
%  JFM   2/15/2006
%  Rev:  2/26/2006

%comp_in
%labels

	% sum(A) treats the columns of A as vectors, returning a row vector of the
	% sums of each column. 
	size1 = full(sum(comp_in)); 
	
	[sizes, ind] = sort(size1);
	sizes = fliplr(sizes);
	ind = fliplr(ind);
	
	for i = 1:length(ind)
		comp_out(:,i) = comp_in(:,ind(i));
	end
	
	if(exist('labels'))
		labels_out = labels(ind);
	end
	
	%if(~exist('comp_out'))
	%	comp_out=comp_in;
	%	labels_out=labels;
	%	sizes=[];
	%end
	
	% Didn't work    
	%comp_out(:,ind) = comp_in(:,:);
