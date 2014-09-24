function CreateCompThresh(comp_filename, comp_thresh_filename, thresholds)
% function CreateCompThresh(comp_filename, comp_thresh_filename, thresholds)
%
%   Create file for use as input to Validate.m.  Assumes the components
%   have already been generated at various thresholds
%
%   comp_filename - Name of file with the components (compXX,etc.)
%   [thresholds] - List of thresholds to use (no decimal points, integers)
%       Not needed if included in comp_filename
%
% Returns:
%   [saves] comp_thresh_filename
%
% JFM   8/16/2006
% Rev:  9/5/2006

% Delete any components smaller than min_size
min_size = 11;

% !! Assume the comp_thresh_filename is already created with the right
% components
load(comp_filename);

if ~exist('thresholds','var')
    fprintf('Error: thresholds vector not found in input\n');
    return;
end

%comp_thresh_filename = 'test.mat';

eval(sprintf('save %s thresholds', comp_thresh_filename));

% !! Image file also assumed to be here (im)
eval(sprintf('save %s im -APPEND', comp_thresh_filename));

for th = thresholds
    fprintf('Threshold %d\n', th);
    cur_comp = eval(sprintf('comp%d',th));
    
    if isempty(cur_comp)
        fprintf('CreateCompThresh:  Warning comp%d not found\n', th);
        continue
    end
    
    % Sort components by size (sorted in descending order by size)
    [sizes, list] = ComponentSizes(cur_comp);
    
    ind = find(list==0); % Delete the 0 component
    list(ind) = [];
    %sizes_out = sizes(list);
    sizes(ind) = [];
    
    % Delete the small components
    ind = find(sizes >= min_size);
    sizes_out = sizes(ind);
    list = list(ind);
    
    comp_out = SelectComponentsReorder(cur_comp, list);
        
    % Find the bounding box of all the components
    [mins, maxs, labels] = ComponentBoundingBox(comp_out);
    [sl, ind] = sort(labels);
    % Remove the 0 component
    if sl(1) == 0
        sl(1) = [];
        ind(1) = [];
    end
    clear mins_out maxs_out
    mins_out(:,1:3) = mins(ind,:);
    maxs_out(:,1:3) = maxs(ind,:);
    
    eval(sprintf('comp%d = comp_out;',th));
    eval(sprintf('sizes%d = sizes_out;',th));
    eval(sprintf('mins%d = mins_out;',th));
    eval(sprintf('maxs%d = maxs_out;',th));
    eval(sprintf('save %s comp%d sizes%d mins%d maxs%d -APPEND', ... 
        comp_thresh_filename, th, th, th, th));
end

