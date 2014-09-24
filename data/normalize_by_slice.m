function im_norm=normalize_by_slice(im)

im_norm=zeros(size(im),'single');

means=[];
for z=1:size(im,3)
	cur_slice=im(:,:,z);
	cur_mean=mean(double(cur_slice(:)));
	means=[means cur_mean];
end

total_mean=mean(means(:))


size(im,3)

for z=1:size(im,3)
	z
	cur_slice=im(:,:,z);
	cur_mean=means(z);
	new_slice=cur_slice+(total_mean-cur_mean);
	mean(new_slice(:))
	im_norm(:,:,z)=single(new_slice);
end
