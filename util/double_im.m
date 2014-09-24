function doubled=double_im(im)
doubled=zeros(size(im)*2,'single');

for y=1:2
	for x=1:2
		for z=1:2	
			doubled(y:2:end,x:2:end,z:2:end)=im;
		end
	end
end

		