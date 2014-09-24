function [flipped]=flipud_all(mtx)

for i=1:size(mtx,3)
	flipped(:,:,i)=flipud(mtx(:,:,i));
end
