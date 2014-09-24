function cmp = pruneComponents(cmp,pruneList)
% removes the objects given in pruneList from the segmentation

lut = 1:max(cmp(:));
lut(pruneList) = 0;
cmp = applylutWithZeros(cmp,lut);
