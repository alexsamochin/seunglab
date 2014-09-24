function [h5outputfile]=find_lasagna(h5inputfile, h5inputpath, h5outputfile, h5outputpath, blksz, chunk_size, bb, total_thresh)

% open input file
[ndims, input_size, max_size]=get_hdf5_size(h5inputfile, h5inputpath);
input_dataID=H5F.open(h5inputfile,'H5F_ACC_RDWR','H5P_DEFAULT');
input_datasetID=H5D.open(input_dataID, h5inputpath);	
input_dataspaceID=H5D.get_space(input_datasetID);

% create output file
%create_hdf5_file(h5outputfile, h5outputpath, input_size, chunk_size, chunk_size, 'float');
output_dataID=H5F.open(h5outputfile,'H5F_ACC_RDWR','H5P_DEFAULT');
output_datasetID=H5D.open(output_dataID, h5outputpath);	
output_dataspaceID=H5D.get_space(output_datasetID);


shift_size=[25 25];

if(isempty(bb))
	begin_coords=[1 1 1];
	end_coords=input_size;
else
	begin_coords=bb(:,1);
	end_coords=bb(:,2);
end
colormap gray;

for kblk = begin_coords(3):1:end_coords(3)
	% get three slice window 
	if(kblk==1)
		im_t=get_hdf5(input_datasetID, input_dataspaceID, [1 1 kblk], [input_size(1) input_size(2) kblk+1]);
		im(:,:,1)=im_t(:,:,2);
		im(:,:,2)=im_t(:,:,1);
		im(:,:,3)=im_t(:,:,2);
	elseif(kblk==input_size(3))
		im_t=get_hdf5(input_datasetID, input_dataspaceID, [1 1 kblk-1], [input_size(1) input_size(2) kblk]);
		im(:,:,1)=im_t(:,:,1);
		im(:,:,2)=im_t(:,:,2);
		im(:,:,3)=im_t(:,:,1);
	else
		im=get_hdf5(input_datasetID, input_dataspaceID, [1 1 kblk-1], [input_size(1) input_size(2) kblk+1]);
	end
	
	lasagna=zeros(size(im(:,:,1)),'single');
	stdblock=zeros(size(im(:,:,1)),'single');
	normblock=zeros(size(im(:,:,1)),'single');

	for iblk = begin_coords(1):shift_size(1):end_coords(1)
		for jblk = begin_coords(2):shift_size(2):end_coords(2)
		
			block_begin_coords=[iblk jblk 1];
			block_end_coords=[min(end_coords(1),iblk+blksz(1)-1) min(end_coords(2),jblk+blksz(2)-1) 3];					

			eval_block=im(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), block_begin_coords(3):block_end_coords(3));
			c1=1-corr2(eval_block(:,:,1),eval_block(:,:,2));
			c2=1-corr2(eval_block(:,:,2),eval_block(:,:,3));

	
			lasagna(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))=...
				lasagna(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))+min(c1,c2);			
			stdblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))=...
				stdblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))+std2(eval_block(:,:,2));			
			normblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))=...
				normblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))+1;			
		end
	end
	
	normblock(find(normblock==0))=1;
	lasagna=lasagna./normblock;
	stdblock=stdblock./normblock;
	combined=(lasagna.*(stdblock>0.04))>total_thresh;
	
	if(nnz(combined)>0)
	
		% get rid of small false positive: lateral inhibition
		combined=medfilt2(combined, [40 40]);
		
		if(nnz(combined)>0)
			% restore boundaries to true positives
			combined=imdilate(combined,strel('square',35));
			combined=imdilate(combined,strel('square',35));

			combined_new=zeros(size(combined),'single');
			
			for iblk = begin_coords(1):50:end_coords(1)
				for jblk = begin_coords(2):25:end_coords(2)
					block_begin_coords=[iblk jblk];
					block_end_coords=[min(end_coords(1),iblk+150-1) min(end_coords(2),jblk+150-1)];					
	
					las_block=combined(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2));
					[yidxs, xidxs]=ind2sub(size(las_block), find(las_block>0));
					las_block(min(yidxs):max(yidxs),min(xidxs):max(xidxs))=1;
					combined_new(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))=...
						combined_new(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2))+las_block;
				end
			end
			combined=min(1,combined_new);
		end
	end
	
	subplot(1,2,1)
	imagesc(im(:,:,2));
	subplot(1,2,2);
	imagesc(combined); 
	drawnow;
	
	%[yidxs, xidxs]=ind2sub(size(combined), find(combined>0));
	%new_im=im(:,:,2);	
	%new_im(min(yidxs):max(yidxs),min(xidxs):max(xidxs))=replace_value;
	
	write_hdf5(output_datasetID, output_dataspaceID, [1 1 kblk], [input_size(1) input_size(2) kblk], single(combined));

	fprintf(1, '.');

end

fprintf(1, '\n');



