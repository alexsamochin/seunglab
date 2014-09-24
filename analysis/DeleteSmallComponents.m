function [comp,sizes_out,list_out] = DeleteSmallComponents(comp,vol_thresh,verbose);
% [comp,sizes_out,list_out] = DeleteSmallComponents(comp,vol_thresh,verbose);
%
%  vol_thresh - Delete any component smaller than vol_thresh
%
% Returns:
%   comp - Large components (same size as comp)
%   sizes_out - List of sizes of the components (sorted)
%   list_out - Component numbers
%
% JFM   4/10/2006
% Rev:  8/8/2006

if ~exist('verbose','var')
    verbose = 0;
end

%%%
list = unique(comp);
num = length(list);

sizes = hist(single(comp(:)),single(list));

% Sort the list in descending order of size
[size, ind] = sort(sizes, 'descend');  
list = list(ind);


%%%

num_comp = 0;

for i = 1:length(list)
        
    if(size(i) < vol_thresh)
        % Delete this component
        ind = find(comp == list(i));
        comp(ind) = 0;
        if verbose
            fprintf('Size of %d = %d - Deleted\n', i, size(i));
        end
    else
        num_comp = num_comp + 1;
        sizes_out(num_comp) = size(i);
        list_out(num_comp) = list(i);
        
        if verbose
            fprintf('Size of %d = %d\n', i, size(i));
        end
    end
   
end

% Sort the list
%[sizes_out,ind] = sort(sizes_out,'descend');
%list_out = list_out(ind);

if verbose
    fprintf('Number of components %d (original %d)\n', num_comp, length(list));
end

