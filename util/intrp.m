function im = intrp(im,fact)

[x,y,z] = meshgrid(1:1/fact:size(im,2),1:1/fact:size(im,1),1:1/fact:size(im,3));
im = interp3(im,x,y,z);
