function [mat,lab]=comp2mat(comp,morph,se)
% constructs sparse matrix, with one column for each component
% comp: components like those produced by bwlabeln
% '0' represents background
% 1,2,3,4,... are labels of components
% it's not assumed that the labels are consecutive
% morph and se are optional arguments, if you want to perform a
% morphological operation on each component
% before sticking it in the matrix
% earlier version worked with indices, and takes 1.5 times as long
lab=nonzeros(unique(comp)); 
mat=sparse([],[],[],length(comp(:)),length(lab),nnz(comp));
if nargin==1
    for j=1:length(lab)
        mat(:,j) = (comp(:)==lab(j));
    end
    return
else
    for j=1:length(lab)
        morphed = morph(comp==lab(j),se);
        mat(:,j) = morphed(:);
    end
    return
end
    

    
