% input - images, filename
function []=output_tiff_stack(ims, fname)

for i=1:size(ims,3)
    i
    imwrite(ims(:,:,i),fname,'TIFF','WriteMode','append');%,'Compression','none');
end

