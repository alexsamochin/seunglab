function [stack]=CropStack(files, min_y, max_y, min_x, max_x, min_slice, max_slice)
y_size=max_y-min_y+1;
x_size=max_x-min_x+1;
z_size=max_slice-min_slice+1;

stack=zeros([y_size, x_size, z_size], 'uint8');

for slice=min_slice:max_slice
	slice
	img=imread(files(slice).name);
	%size(img)
	stack(:,:,slice-min_slice+1)=uint8(img(min_y:max_y,min_x:max_x));
end