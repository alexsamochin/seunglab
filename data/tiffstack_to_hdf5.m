% ie tiffstack_to_hdf5(dir('.'), 'data.h5' etc)
function [stack]=tiffstack_to_hdf5(files, h5outputfile, h5outputpath, blksz)

slices=0;
img_size=[];

for i=1:length(files)
	if(~files(i).isdir)
		slices=slices+1;
		if(isempty(img_size))
			img=imread(files(i).name);
			img_size=[size(img)]	
		end
	end
end

create_hdf5_file(h5outputfile, h5outputpath, [img_size slices], blksz, blksz, 'float');
output_dataID=H5F.open(h5outputfile,'H5F_ACC_RDWR','H5P_DEFAULT');
output_datasetID=H5D.open(output_dataID, h5outputpath);	
output_dataspaceID=H5D.get_space(output_datasetID);


slice=0;
length(files)

for i=1:length(files)
	if(~files(i).isdir)
		slice=slice+1;
		
		img=single(imread(files(i).name));
		img=img/255;
		
		write_hdf5(output_datasetID, output_dataspaceID, [1 1 slice], [size(img) slice], img);					

		fprintf(1, '.');

	end
end

H5D.close(output_datasetID);
H5F.close(output_dataID);

fprintf(1, '\n');
