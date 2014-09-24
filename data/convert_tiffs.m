% ie [img]=convert_tiff_stack_tracing(dir('.'))
function [stack]=convert_tiffs(files, filter)

stack=[];
slice=0;
length(files)

for i=1:length(files)
	if(~files(i).isdir)
		slice=slice+1;
		img=imread(files(i).name);
		
		if(~isempty(filter))
			img=downsample_im(img, filter);
		end
		
				
		if(slice==1)
			stack=zeros([size(img,1),size(img,2),length(files),size(img,3)],'single');
			size(img)
			size(stack)
		end
		
		slice
		
		stack(:,:,slice,:)=single(img);
	end
end

stack=stack(:,:,1:slice,:);