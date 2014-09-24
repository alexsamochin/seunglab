function [voxel_error, n_splits, n_mergers, splits, mergers, n_true_comp] = MetricsAllMatches(true_comp, est_comp, verbose, varargin)
% [voxel_error, splits, mergers] = MetricsAllMatches(true_comp, est_comp, verbose)
%
% MetricsAllMatches - Finds the errors of the estimated components
% (est_comp) from the true labels (true_comp).  Reports all the overlapping
% components in est_comp of each true component.
%
%
% Returns:
%   voxel_error - Divided by the number of labeled voxels in true_comp, 
%       best is 0.0
%   n_splits - Number of splits
%   n_mergers - Number of mergers
%   splits - If more than one est_comp overlaps with a true_comp, then
%       this is a split.  Cell array {n_splits}{2}  For each split,
%       the {n}{1} has the ture_comp number, and {n}{2} the estimated
%       comp numbers of those matching comps in est_comp.
%   mergers - If more than one true_comp overlaps with an est_comp,
%       this is a merger.  Cell array {n_splits}{2}, where {n}{1} contains
%       the true comps that were merged and {n}{2} contains the estimated 
%       comp that merged tham.
%   n_true_comp - Number of components in true_comp that meet the size
%       threshold.
%
%
%  JFM   6/28/2006
%  Rev:  7/28/2008 JFM  Add the varargin from the current version, fix voxel_error calc
%  Rev:  7/28/2008

%disp('!! Warning:  This version (9/25/2007) calculates voxel_error, not voxel_score !!');
if ~exist('verbose','var')
    verbose = 0;
end


if(nargin<4)
	% Delete components smaller than size_thresh
	size_thresh = 100;
	
	% Components with less overlap are not counted as split/merged.
	split_thresh = 100;
	merger_thresh = 100;
else
	size_thresh = varargin{1};
	split_thresh = varargin{2};
	merger_thresh = varargin{3};
end


% Delete components smaller than size_thresh
if(size_thresh>0)
	true_comp = DeleteSmallComponents(double(true_comp), size_thresh);
	est_comp = DeleteSmallComponents(double(est_comp), size_thresh);
end


% Calculate the overlaps
%   overlap - Number of voxels common to the pair of components.
%       Index into comp1 is in the rows, comp2 is the columns.
%   overlap_per1,2 - Full matricies of the overlap in the components.
%       Same as overlap except normalized by the size of the component
%       in comp1 or comp2.
[overlap,size1,size2,corrcoeff,overlap_per1,overlap_per2,label1,label2] = ...
    CompareComponentsSort(true_comp,est_comp);


total_volume = numel(true_comp);
total_labeled_volume = length(find(true_comp));
n_true_comp = length(unique(true_comp)) - 1;
temp_overlap_per1 = overlap_per1;
voxel_error = 0;
splits = {};
mergers = {};
n_splits = 0;
n_mergers = 0;

% For every true object i (row in overlap), report how well it was classified 
for i = 1:length(size1) % Number of true_comp
    [per, ind] = max(temp_overlap_per1(i,:));
    if(per > 0) 
        % ---- Voxel error ----
        % Add the number of voxels missed in the overlap between true (i)
        % and best match (ind)
        extra_vox = nnz( (true_comp == 0) & (est_comp == label2(ind)) );
        voxel_error_contrib = extra_vox + (size1(i) - overlap(i,ind));
        voxel_error = voxel_error + voxel_error_contrib;
        
        if(verbose)
            fprintf('True_comp %4d  (%6d voxels):  Match: %6d overlap %7d ( %.4f), extra %7d ', ...
                label1(i), size1(i), label2(ind), overlap(i,ind), ...
                per, size2(ind) - overlap(i,ind));
            fprintf('   contrib %7.4f,  v_s %7.4f\n', ...
                voxel_error_contrib/total_labeled_volume, ...
                voxel_error/total_labeled_volume );
                
        end

        % ---- Splits -----
        % List all the other components in est_comp that overlap
        overlap_list = find(temp_overlap_per1(i,:) ~= 0);                
        %overlap_list = find(overlap_per1(i,:) ~= 0); % Looks like some bugs with this one                
        
        for j = length(overlap_list):-1:2
            if verbose
                fprintf('    (Split) est_comp %6d:  overlap %6d ( %.4f)', ...
                    label2(overlap_list(j)), overlap(i,overlap_list(j)), ...
                    overlap_per2(i,overlap_list(j)) );
            end
            if overlap(i,overlap_list(j)) < split_thresh
                overlap_list(j) = [];
                if verbose
                    fprintf(' Too small, not counted\n');
                end
            elseif verbose                
                fprintf('\n');
            end
        end
                    
        
        % If more than one est_comp overlaps with this true_comp,
        % then record this as a split true component.
        % !! We might be missing some because we looked in temp_overlap_per1
        % not the true overlap.
        if(length(overlap_list) > 1)
            splits{end+1} = { label1(i) label2(overlap_list) };
        end
                       
        % Don't choose this object in est_comp again, zero out the column
        temp_overlap_per1(:,ind) = 0;
    else
        voxel_error_contrib = size1(i);
        voxel_error = voxel_error + voxel_error_contrib;
        
        if(verbose)
            fprintf('True_comp %4d  (%6d voxels):  No match, ', ...
                label1(i), size1(i) );
            fprintf('   contrib %7.4f,  v_s %7.4f\n', ...
                voxel_error_contrib/total_labeled_volume, ...
                voxel_error/total_labeled_volume );
        end
        
    end
end

n_splits = size(splits,2);

% ------ Mergers --------
% Find mergers: true comps which are joined together by an est_comp.
% This search does not contribute to the voxel_error values.
temp2_overlap_per1 = overlap_per1;
for i = 1:length(size2) % Number of est_comp
    % List all the other components in est_comp that overlap
    overlap_list = find(temp2_overlap_per1(:,i) ~= 0);                
    
    if(length(overlap_list) > 1)
         
        if(verbose)
          %  fprintf('Est_comp %4d (%6d voxels) merges:\n', label2(i), size2(i))
        end
         
        for j = length(overlap_list):-1:1
            if verbose
             %   fprintf('    (Merge) true_comp %4d (%6d voxels):   overlap %d ', label1(overlap_list(j)), size1(overlap_list(j)), overlap(overlap_list(j),i) );
            end
            if overlap(overlap_list(j),i) < merger_thresh
                overlap_list(j) = [];
                if verbose
               %     fprintf('Too small, not counted\n');
                end
            elseif verbose
             %   fprintf('\n');
            end
                 
        end
         
        if length(overlap_list) > 1
            % Add to merger list
            mergers{end+1} = { label1(overlap_list)  label2(i) };
            
            % Add to merger count
            n_mergers = n_mergers + length(overlap_list) - 1;
        end

        if ~isempty(overlap_list)
            % Remove from consideration for future mergers
            temp2_overlap_per1(overlap_list,:) = 0;
        end
    end
end

% Penalize objects in est_comp that weren't the best match to anything in true_comp
% !! Not subtracting this anymore, as it double penalizes missing
% parts, and also makes results lower if not all components in the
% volume are labeled in the true set.
%extra_object_volume = 0;
% for i = 1:length(size2)
%     if(nnz(temp_overlap_per1(:,i)) > 0)
%         % This object was not chosen as a best match
%         if(verbose)
%             fprintf('Est_comp %4d not chosen (volume %6d)\n', ...
%                 label2(i), size2(i) );
%         end
%         %!!
%     %    extra_object_volume = extra_object_volume + size2(i);
%     end
% end

% if verbose
%     fprintf('\nRaw voxel error: %d / %d = %.4f \n', voxel_error, total_volume, ...
%         voxel_error / total_volume);
%     fprintf('Extra object volume: %d\n', extra_object_volume);
% end
% 
% voxel_error = voxel_error - extra_object_volume;

if verbose
    fprintf('Voxel error: %d / %d (labeled vol) = %.4f \n', voxel_error, ...
        total_labeled_volume, ...
        voxel_error / total_labeled_volume);
    fprintf('Number of splits = %d / %d = %f \n', n_splits, n_true_comp, n_splits / n_true_comp );
    fprintf('Number of mergers = %d / %d = %f \n', n_mergers, n_true_comp, n_mergers / n_true_comp );

end

voxel_error = voxel_error / total_labeled_volume;
