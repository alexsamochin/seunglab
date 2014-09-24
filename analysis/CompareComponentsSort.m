function [overlap,size1,size2,corrcoeff,overlap_per1,overlap_per2,lab1,lab2]=CompareComponentsSort(comp1,comp2)
% [overlap,size1,size2,corrcoeff,overlap_per1,overlap_per2,lab1,lab2]
%    = CompareComponentsSort(comp1,comp2)
%
% Inputs: 
%   comp1 and comp2: components like those produced by bwlabeln
%   '0' represents background
%   1,2,3,4,... are labels of components
%   it's not assumed that the labels are consecutive
%
% Returns: 
%   overlap - Number of voxels common to the pair of components.
%       Index into comp1 is in the rows, comp2 is the columns.
%   overlap_per1,2 - Full matricies of the overlap in the components.
%       Same as overlap except normalized by the size of the component
%       in comp1 or comp2.
%   size1, size2 - number of voxels in each component
%   corrcoeff - normalized so that the maximum value is one
%   lab1, lab2 - Labels of components after sorting
%
%  Orig:  seung/comparecomponents.m 
%  Rev:  7/5/2006 JFM

[mat1,lab1] = comp2mat(comp1);
[mat2,lab2] = comp2mat(comp2);

% Sort the components into decending size
[mat1, size1, lab1] = SortComponents(mat1,lab1);
[mat2, size2, lab2] = SortComponents(mat2,lab2);

overlap=mat1'*mat2;
corrcoeff=overlap./sqrt(size1'*size2);

% Normalize by the number of pixels in each object in size1
% Still not the same as the % of A in 1 (see notes 2/7/2006)
% !! Errors in this
for i=1:length(size1)
    overlap_per1(i,:) = overlap(i,:)/size1(i);
end

for i=1:length(size2)
    overlap_per2(:,i) = overlap(:,i)/size2(i);
end

% Convert to full matrices for easier viewing
overlap = full(overlap);
overlap_per1 = full(overlap_per1);
overlap_per2 = full(overlap_per2);

%keyboard;
