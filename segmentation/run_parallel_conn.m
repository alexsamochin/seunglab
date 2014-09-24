function [errmsgs]=run_parallel_conn(h5inputfile, h5inputpath, h5outputfile, h5outputpath, bb, split_size, chunk_size, max_workers, threshold)

	prestitch_directory='/home/viren/process_networks/conntemp/';
	EMroot = get(0,'UserData');
	nhood=mknhood(6);
	errmsgs=[];
	
	% process everything if no bounding box given
	[ndims, input_size, max_size]=get_hdf5_size(h5inputfile, h5inputpath);
	
	input_size
	
	if(isempty(bb))
		display(['warning: no bounding box given, assuming full volume']);
		bb(:,1)=ones(length(input_size));
		bb(:,2)=input_size;
	end
	if(size(bb,1)~=length(input_size));
		display(['number of dimensions in bounding box does not match number of dimensions in h5inputfile!']);
		return;
	end
	if(length(chunk_size)~=length(input_size));
		display(['number of dimensions in chunk_size does not match number of dimensions in h5inputfile!']);
		return;
	end
	if(length(split_size)~=length(input_size));
		display(['number of dimensions in split_size does not match number of dimensions in h5inputfile!']);
		return;
	end

	
	% distributed connected components processing of input hdf5 file
	sched=findResource('scheduler','configuration','jobmanager','Name','general');
	set(sched,'Configuration','jobmanager');	
	pjob=createParallelJob(sched);
	set(pjob, 'PathDependencies',{[EMroot '/nn/emnet_dist_passes/'], [EMroot '/segmentation'], [EMroot '/util/'], [EMroot '/parallel/'], [EMroot '/nn/hdf5/']});
	conncomps=createTask(pjob, @connectedComponentsParallel, 1, {h5inputfile, h5inputpath, h5outputfile, h5outputpath, bb, split_size, nhood, threshold, true, '', prestitch_directory} );
	set(pjob, 'MaximumNumberOfWorkers', max_workers);
	set(conncomps,'CaptureCommandWindowOutput',true);
	display(['connected components distributed hdf5 processing. No further console messages.']);
	submit(pjob);
	waitForState(pjob);
	results=getAllOutputArguments(pjob);
	errmsgs=get(conncomps,{'ErrorMessage'})
	if(~isempty(errmsgs))
		errmsgs{1}
	end
	msgs=get(conncomps,{'CommandWindowOutput'});
	if(~isempty(errmsgs))
		msgs{1}
	end

	destroy(pjob);
	num_points=results{1};
	
	% combine, stitch, and collapse if successful
	if(~isempty(num_points))	
	
		% stitch together total component file
		[ndims, input_size, max_size]=get_hdf5_size(h5inputfile, h5inputpath);
		display(['done processing. now combining together ', num2str(num_points), ' blocks into hdf5 output file.']);
		cmpMax=stitch_hdf5_parallelconn(prestitch_directory, num_points, input_size(1:3), h5outputfile, h5outputpath, chunk_size(1:3))


		% open stitched component output and graph input file
		input_dataID=H5F.open(h5inputfile,'H5F_ACC_RDWR','H5P_DEFAULT');
		input_datasetID=H5D.open(input_dataID, h5inputpath);	
		input_dataspaceID=H5D.get_space(input_datasetID);
		output_dataID=H5F.open(h5outputfile,'H5F_ACC_RDWR','H5P_DEFAULT');
		output_datasetID=H5D.open(output_dataID, h5outputpath);	
		output_dataspaceID=H5D.get_space(output_datasetID);

	
		% fix up the block boundaries
		display(['done combining. now stitching together connected component blocks.']);
		cmpMax=double(cmpMax);
		equiv = sparse(1:cmpMax,1:cmpMax,1,cmpMax,cmpMax,round(1.5*cmpMax));	% 'pre-allocate'
	
		begin_coords=bb(:,1);
		end_coords=bb(:,2);
		
		blksz=split_size;
		
		for iblk = begin_coords(1):blksz(1):end_coords(1),
			for jblk = begin_coords(2):blksz(2):end_coords(2),
				for kblk = begin_coords(3):blksz(3):end_coords(3),	
					
					
					% look at all the "faces" of this block
					% top face
					if(iblk>1)
						% get this block of the graph & component output
						comp_begin_coords=[iblk-1 jblk kblk];
						comp_end_coords=[iblk min(end_coords(2),jblk+blksz(2)-1) min(end_coords(3),kblk+blksz(3)-1)];				
						comp_block=get_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords);
						g_offset = [1 0 0];
						g_block=get_hdf5(input_datasetID, input_dataspaceID, [comp_begin_coords+g_offset 1], [comp_end_coords 3]);
						g_block=g_block>threshold;
	
						i=1;
						for j = 1:size(comp_block,2),
							for k = 1:size(comp_block,3),
								findlinks;
							end
						end
						write_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords, comp_block);					
					end
					
					% front face
					if(jblk>2)
						% get this block of the graph & component output
						comp_begin_coords=[iblk jblk-1 kblk];
						comp_end_coords=[min(end_coords(1), iblk+blksz(1)-1) jblk min(end_coords(3),kblk+blksz(3)-1)];				
						comp_block=get_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords);
						g_offset = [0 1 0];
						g_block=get_hdf5(input_datasetID, input_dataspaceID, [comp_begin_coords+g_offset 1], [comp_end_coords 3]);
						g_block=g_block>threshold;
	
						j=1;
						for i = 1:size(comp_block,1),
							for k = 1:size(comp_block,3)
								findlinks
							end
						end
						write_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords, comp_block);					
					end
					
					
					
					% left face
					if(kblk>1)
						% get this block of the graph & component output
						comp_begin_coords=[iblk jblk kblk-1];
						comp_end_coords=[min(end_coords(1), iblk+blksz(1)-1) min(end_coords(2), jblk+blksz(2)-1) kblk];				
						comp_block=get_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords);
						g_offset = [0 0 0];
						g_block=get_hdf5(input_datasetID, input_dataspaceID, [comp_begin_coords+g_offset 1], [comp_end_coords 3]);
						g_block=g_block>threshold;
	
						%g_block=permute(g_block, [4 3 2 1]);
						
						k=2;
						for i = 1:size(comp_block,1),
							for j = 1:size(comp_block,2),
								findlinks
							end
						end
						write_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords, comp_block);					
					end
					
					fprintf(1, '.');

				end
			end
		end
	
		fprintf(1, '\n');
		display(['now collapsing indexes']);
		
		% collapsing indexes
		% copied from http://web.ccr.jussieu.fr/ccr/Documentation/Calcul/matlab5v11/docs/ftp.mathworks.com/pub/mathworks/toolbox/images/cclabel.m
		[p,p,r,r] = dmperm(equiv);
		sizes = diff(r);				% Sizes of components, in vertices.
		numObjs = length(sizes);		% Number of components.
		% Now compute an array "blocks" that maps vertices of equiv to components;
		% First, it will map vertices of equiv(p,p) to components...
		blocks = zeros(1,cmpMax);
		blocks(r(1:numObjs)) = ones(1,numObjs);
		blocks = cumsum(blocks);
		% Second, permute it so it maps vertices of equiv to components.
		blocks(p) = blocks;
		
		% label the equivalent components
		for iblk = begin_coords(1):blksz(1):end_coords(1),
			for jblk = begin_coords(2):blksz(2):end_coords(2),
				for kblk = begin_coords(3):blksz(3):end_coords(3),	
	
					% get this block of the graph & component output
					comp_begin_coords=[iblk jblk kblk];
					comp_end_coords=[min(end_coords(1),iblk+blksz(1)-1) min(end_coords(2),jblk+blksz(2)-1) min(end_coords(3),kblk+blksz(3)-1)];				
	
					comp_block=get_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords);
	
					comp_block(comp_block>0) = blocks(comp_block(comp_block>0));
					
					write_hdf5(output_datasetID, output_dataspaceID, comp_begin_coords, comp_end_coords, comp_block);					
	
					fprintf(1, '.');

				end
			end
		end
	end

	fprintf(1, '\n');

	% close files
	H5D.close(output_datasetID);
	H5F.close(output_dataID);
	H5D.close(input_datasetID);
	H5F.close(input_dataID);



	%% nested function to link up components
	function [] = findlinks()
		ii = i+g_offset(1); jj = j+g_offset(2); kk = k+g_offset(3);
		mycmp = comp_block(ii,jj,kk);
		for nbor = 1:size(nhood,1),
			if g_block(i,j,k,nbor),
				ii2 = ii+nhood(nbor,1); jj2 = jj+nhood(nbor,2); kk2 = kk+nhood(nbor,3);
				try,%if (ii2>0)&&(jj2>0)&&(kk2>0),
					nncmp = comp_block(ii2,jj2,kk2);
					% check if your neighbor has been set to 0 and "push" a label
					if nncmp == 0,
						comp_block(ii2,jj2,kk2) = mycmp;
					else, % else, add a link
						equiv(mycmp,nncmp) = 1;
						equiv(nncmp,mycmp) = 1;
					end
				end
			end
		end
	end
	
end