function [] = tif2hdf5_omni(hdf5File,inputFileList)

chunk_size = [50 50 1];

%% figure out input dimensions
nImages=length(inputFileList);

im = uint8(imread(fnames(1).name));
imSz = size(im); imSz = imSz(1:2);	% assume (require) grayscale!


%% initialize output hdf5 file
%% write single precision
hdf5_type='H5T_NATIVE_INT';

total_size=flipdims(total_size);
chunk_size=flipdims(chunk_size);
init_size=flipdims(init_size);


fileID=H5F.create(hdf5File, 'H5F_ACC_EXCL', 'H5P_DEFAULT', 'H5P_DEFAULT');
cparms=H5P.create('H5P_DATASET_CREATE');
H5P.set_chunk(cparms, chunk_size);
%H5P.set_deflate(cparms, 1);
dataspace=H5S.create_simple(length(total_size), init_size, -1*ones([length(total_size)',1]));
datasetID=H5D.create(fileID, path, hdf5_type, dataspace, cparms);
memspace=H5D.get_space(datasetID);
H5D.write(datasetID, hdf5_type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', init_zeros); 
H5D.extend(datasetID, total_size);

% if file exists, check to see if the parameters match
if exist(file,'file'),
	h5info = hdf5info(file);
	current_total_size = h5info.GroupHierarchy.Datasets.Dims;
	current_data_type = h5info.GroupHierarchy.Datasets.Datatype.Class;
	if isequal(current_total_size,total_size) && ...
		(isequal(current_data_type,'H5T_IEEE_F32LE') && isequal(type,'float')),
		% parameters match!
		return;
	end
else,
	delete(file)
	create_hdf5_file(file, path, total_size, chunk_size, chunk_size, varargin{:});
	points = mk_split_points(init_size,chunk_size);
	for k = 1:size(points,3),
		block = zeros([points(:,2,k)-points(:,1,k)+1]',matlab_type);
		write_hdf5_file(file, path, points(:,1,k), points(:,2,k), block)
	end
end

%% read and write
for i=2:nimages
  im = imread(fnames(i).name);
end

%% close hdf5 file
H5P.close(cparms);
H5D.close(datasetID);
H5F.close(fileID);
