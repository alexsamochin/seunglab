function [comp_out] = SelectComponents(comp_in, list)
% SelectComponents - Creates a stack with only those objects in
%   the list.  Object numbering is preserved.
%
%   comp_in  - Dense component image 
%   list - List of objects to include in new stack.
%
% Returns:
%   comp_out - Stack (dense) containing selected objects (from list)
%
%  JFM   2/26/2006
%  Rev:  4/9/2006

comp_out = zeros(size(comp_in),'single');
idx = ismember(comp_in,list); comp_out(idx) = comp_in(idx);
%% OR
% cmp_out = cmp_in .* idx;
