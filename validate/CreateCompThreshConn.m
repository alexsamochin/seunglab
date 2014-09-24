function CreateCompThreshConn(conn, im, thresholds, comp_thresh_filename)
% function CreateCompThreshConn(conn, im, thresholds, comp_thresh_filename)
%
%   Create file for use as input to Validate.m from a 3-connectivity
%   output.   Creates components at various thresholds.
%
%   conn    - 3-connectivity output from networks
%   im      - Image of the same volume as conn
%   thresholds - List of thresholds to use (no decimal points, integers)
%       Not needed if included in comp_filename
%   comp_thresh_filename - Output filename with the components (compXX,etc.)
%
% Returns:
%   [saves] comp_thresh_filename
%
% JFM   9/12/2006
% Rev:  9/26/2006

% Delete any components smaller than min_size
min_size = 11;

% condition the image
mn = min(im(:));
if mn<0, im = im-mn; end
mx = max(im(:));
if mx>1, im = im/mx; end
im = single(im);

save(comp_thresh_filename,'thresholds');
save(comp_thresh_filename,'im','-APPEND');
clear('im')

for th = thresholds
    fprintf('Threshold %d\n', th);
 
    th2 = eval(sprintf('.%d', th));
    out = conn > th2;

    % Create the components at this threshold
    tic; 
    cur_comp = single(connectedComponents(out,mknhood(6))); 
    toc;

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
    
    comp_out = uint16(SelectComponentsReorder(cur_comp, list));
        
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

	thstr = num2str(th);
	save(comp_thresh_filename,['comp' thstr],['sizes' thstr],['mins' thstr],['maxs' thstr],'-APPEND');
	clear(['comp' thstr],['sizes' thstr],['mins' thstr],['maxs' thstr]);
end
