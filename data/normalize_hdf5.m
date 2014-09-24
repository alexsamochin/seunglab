% normalize an hdf5 image 
function [h5outputfile] = normalize_hdf5(h5inputfile, h5inputpath, h5outputfile, h5outputpath, stat_begin_coords, stat_end_coords, begin_coords, end_coords)

blksz = [150 150 150];
		
% open input file
[ndims, input_size, max_size]=get_hdf5_size(h5inputfile, h5inputpath);
input_dataID=H5F.open(h5inputfile,'H5F_ACC_RDONLY','H5P_DEFAULT');
input_datasetID=H5D.open(input_dataID, h5inputpath);
input_dataspaceID=H5D.get_space(input_datasetID);

% create and then open output file
create_hdf5_file(h5outputfile, h5outputpath, input_size(1:3), blksz, blksz, 'float');
output_dataID=H5F.open(h5outputfile,'H5F_ACC_RDWR','H5P_DEFAULT');
output_datasetID=H5D.open(output_dataID, h5outputpath);	
output_dataspaceID=H5D.get_space(output_datasetID);

if(isempty(stat_begin_coords))
	stat_begin_coords=[1 1 1];
end

if(isempty(stat_end_coords))
	stat_end_coords=input_size';
end

if(isempty(begin_coords))
	begin_coords=[1 1 1];
end

if(isempty(end_coords))
	end_coords=input_size';
end

sz=end_coords-begin_coords+1;

means=[];
vars=[];

display('calculating global mean and variance');
for iblk = stat_begin_coords(1):blksz(1):stat_end_coords(1),
	for jblk = stat_begin_coords(2):blksz(2):stat_end_coords(2),
		for kblk = stat_begin_coords(3):blksz(3):stat_end_coords(3),
						
			% get this block of the component file
			block_begin_coords=[iblk jblk kblk];
			block_end_coords=[min(stat_end_coords(1),iblk+blksz(1)-1) min(stat_end_coords(2),jblk+blksz(2)-1) min(stat_end_coords(3),kblk+blksz(3)-1)];				
			image_block=double(get_hdf5(input_datasetID, input_dataspaceID, [block_begin_coords], [block_end_coords]));
			
			means=[means mean(image_block(:))];
			vars=[vars var(image_block(:))];
			
			fprintf(1, '.');
		end
	end
end
fprintf(1, '\n');


% cumulative stats
total_mean=mean(means)
total_var=mean(vars)+var(means)
total_std=sqrt(total_var)

display('outputting new image');
for iblk = begin_coords(1):blksz(1):end_coords(1),
	for jblk = begin_coords(2):blksz(2):end_coords(2),
		for kblk = begin_coords(3):blksz(3):end_coords(3),
						
			% get this block of the component file
			block_begin_coords=[iblk jblk kblk];
			block_end_coords=[min(end_coords(1),iblk+blksz(1)-1) min(end_coords(2),jblk+blksz(2)-1) min(end_coords(3),kblk+blksz(3)-1)];				
			image_block=get_hdf5(input_datasetID, input_dataspaceID, [block_begin_coords], [block_end_coords]);
			
			image_block=image_block-single(total_mean);
			image_block=image_block./single(total_std);
			
			% write out new components
			write_hdf5(output_datasetID, output_dataspaceID, block_begin_coords, block_end_coords, image_block);					
			
			fprintf(1, '.');
		end
	end
end

H5D.close(output_datasetID);
H5F.close(output_dataID);

fprintf(1, '\n');

