function d_im=downsample_im(im, downsample_filter)
im=single(im);
d_im=[];
for i=1:size(im,3)
	dim=convn(im(:,:,i,:),downsample_filter,'valid');
    d_im(:,:,i,:)=dim(1:size(downsample_filter,1):end, 1:size(downsample_filter,2):end, 1:size(downsample_filter,3):end);
   d_im(:,:,i,:)=d_im(:,:,i,:)./sum(downsample_filter(:));    
end
