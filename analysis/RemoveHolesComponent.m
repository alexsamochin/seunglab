function comp_out = RemoveHolesComponent(comp)
% function comp = RemoveHolesComponent(comp)
%
%   Uses bwlabeln on the 0 voxels to find and remove holes in the object
%
% comp - Binary image of a single component
%
% JFM   4/20/2006
% Rev:  5/30/2006

bwcomp = bwlabeln(~comp,6);

[sizes, list] = ComponentSizes(bwcomp);

% Assume the biggest two components are the correct object
% and the background, and fill everything else

% (Other choices are to fill only components with a small enough
% volume)

comp_out = comp;

bwcomp(find(bwcomp == list(1))) = 0;
bwcomp(find(bwcomp == list(2))) = 0;

comp_out(find(bwcomp)) = 1;

% Compare comp to comp_out and give a warning/error
% if they are very different.

if norm(comp_out(:) - comp(:),1)/nnz(comp) > .05
    fprintf('RemoveHolesComponent:  Warning:  More than 5 percent different\n');
end
