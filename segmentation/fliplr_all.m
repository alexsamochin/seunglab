function [flipped]=fliplr_all(mtx)

for i=1:size(mtx,3)
	flipped(:,:,i)=fliplr(mtx(:,:,i));
end
