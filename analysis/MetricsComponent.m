function [voxel_score, voxel_score2] = MetricsComponent(true_comp, est_comp, verbose)
% [voxel_score, voxel_score2] = MetricsComponent(true_comp, est_comp, verbose)
%
% MetricsComponent - Finds the errors of the estimated components
% (est_comp) from the true labels (true_comp)
%
% Returns:
%   voxel_score -
%   voxel_score2 - Divided by the number of labeled voxels in true_comp, so
%       max = 1.0
%
%  JFM   2/16/2006
%  Rev:  4/26/2006

if(~exist('verbose'))
    verbose = 0;
end

% Calculate the overlaps
[overlap,size1,size2,corrcoeff,overlap_per1,overlap_per2,label1,label2] = ...
    CompareComponentsSort(true_comp,est_comp);


total_volume = prod(size(true_comp));
total_labeled_volume = length(find(true_comp));
temp_overlap_per1 = overlap_per1;
voxel_score = 0;

% For every true object i (row in overlap), report how well it was classified 
for i = 1:length(size1)
    [per, ind] = max(temp_overlap_per1(i,:));
    if(per > 0) 
        if(verbose)
            fprintf('Object %4d:  Best match: %4d, overlap %f, volume %6d, extra voxels %6d\n', ...
                label1(i), label2(ind), per, size1(i), size2(ind) - overlap(i,ind));
        end

        % Add the number of voxels correctly labeled by object ind,
        % subtract the number of extra voxels in ind that weren't in true obj i
        voxel_score = voxel_score + overlap(i,ind) - (size2(ind) - overlap(i,ind)); 

        % Don't choose this object in est_comp again, zero out the column
        temp_overlap_per1(:,ind) = 0;
    else
        if(verbose)
            fprintf('Object %4d:  No match\n', label1(i));
        end
    end
end

% Penalize objects in est_comp that didn't match anything in true_comp
extra_object_volume = 0;
for i = 1:length(size2)
    if(nnz(temp_overlap_per1(:,i)) > 0)
        % This object was not chosen
        if(verbose)
            fprintf('Not choosen:  Object %4d, volume %6d\n', ...
                label2(i), size2(i) );
        end
        extra_object_volume = extra_object_volume + size2(i);
    end
end

if verbose
    fprintf('\nRaw voxel score: %d / %d = %.4f \n', voxel_score, total_volume, ...
        voxel_score / total_volume);
    fprintf('Extra object volume: %d\n', extra_object_volume);
end

voxel_score = voxel_score - extra_object_volume;

if verbose
    fprintf('Voxel score: %d / %d = %.4f \n', voxel_score, total_volume, ...
        voxel_score / total_volume);
end

voxel_score2 = voxel_score / total_labeled_volume;
if verbose
    fprintf('Voxel score2: %d / %d (labeled voxels) = %.4f \n', voxel_score, ...
        total_labeled_volume, voxel_score2);
end

    
voxel_score = voxel_score / total_volume;
