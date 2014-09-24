function [comp_out] = SelectComponentsReorder(comp_in, list)
% [comp_out] = SelectComponentsReorder(comp_in, list)
%
% SelectComponentsReorder - Creates a stack with only those objects in
%   the list.  Object numbering is _not_ preserved (use 
%   SelectComponents if you want that).
%
%   comp_in  - Dense component image 
%   list - List of objects to include in new stack.
%
% Returns:
%   comp_out - Stack (dense) containing selected objects (from list)
%
%  JFM   4/13/2006
%  Rev:  4/13/2006

remap = zeros(1,max(list)); remap(list) = 1:length(list);
comp_out = zeros(size(comp_in),'single');
idx = ismember(comp_in,list); comp_out(idx) = remap(comp_in(idx));
