function [split_weak, split_comp] = SuggestSplits(comp_big, compB)
% [split_weak, split_comp] = SuggestSplits(comp_big, compB)
%
%   comp_big - Component to be split
%   compB - Components at lower threshold
%
% Returns:
%   split_weak - Components of the regions that could join 2 objects in B
%   split_comp - Components at lower threshold
%
% JFM   7/26/2006
% Rev:  7/26/2006

compB = (compB & comp_big) .* compB;
unB = unique(compB);


% Should warn if any of the components left in B extend for larger 
% than comp_big (could happen if segmentations came from different
% networks).

if length(unB) == 0
    fprintf('SuggestSplits:  Error: No matching components in compB\n');
    return
elseif length(unB) == 1
    fprintf('SuggestSplits:  Error: comp_big is not split in compB, try higher threshold\n');
    return
else
    fprintf('SuggestSplits:  comp_big can be split into %d\n', unB(2:end));
end

if unB(1) == 0
    unB = unB(2:end);
end

% Regions in comp_big not in the split components
regC = (comp_big > 0) - (compB > 0);

split_weak = zeros(size(compB),'single');
split_pos = bwlabeln(regC,6);

% comp2mat is too slow.
%[split_weak_mat, lab] = comp2mat(split_weak);

fprintf('ComponentBoundingBox...');
[mins, maxs, labels] = ComponentBoundingBox(split_pos);
fprintf('finished\n');

num_weak_links = 0;
for i = 1:length(labels)
    % Check to see if the component is a possible 'weak link'
    
    try
        regC2 = compB(mins(i,1)-1:maxs(i,1)+1, mins(i,2)-1:maxs(i,2)+1, mins(i,3)-1:maxs(i,3)+1 );
    catch
         % Could exceed the bounding box
         fprintf('Skipping %d, on boundardy\n', i);
         continue;
    end

    unC2 = unique(regC2);
    if length(unC2) == 0
        continue;
    end
    
    if unC2(1) == 0;
        unC2 = unC2(2:end);
    end
    
    if length(unC2) > 1
        % We've found a possible 'weak link'!!
        cD = imdilate(split_pos == labels(i), ones(3,3,3));
        for j = 1:length(unC2)
            if length(   find( cD & ( compB == unC2(j) )  )   ) == 0
                % This object doesn't actually touch!
                unC2(j) = 0;
            end
        end
        
        unC3 = unique(unC2);
        if unC3(1) == 0;
            unC3 = unC3(2:end);
        end
        
        if length(unC3) > 1        
            num_weak_links = num_weak_links + 1;
            split_weak = split_weak + num_weak_links * (split_pos == labels(i));
            fprintf('Weak link %d: \n', num_weak_links);
            fprintf('  %d\n', unC3);
        end
    end
    
end

    
% Dilate the exterior regions
% ones(3,3,3) dilation makes the exterior regions too big. 
%regCd = imdilate(regC, ones(3,3,3));

split_comp = compB;

%keyboard;