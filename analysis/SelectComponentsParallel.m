function [h5outputfile] = ComponentBoundingBoxParallel(h5inputfile, h5inputpath, h5outputfile, h5outputpath, begin_coords, end_coords, desired_head, comp_list, reorder)

[head, open_labs]=assign_role(desired_head);

if(labindex==head)

	% head lab	
	blksz = [300 300 300];
			
	% open input file
	[ndims, input_size, max_size]=get_hdf5_size(h5inputfile, h5inputpath);
	input_dataID=H5F.open(h5inputfile,'H5F_ACC_RDONLY','H5P_DEFAULT');
	input_datasetID=H5D.open(input_dataID, h5inputpath);
	input_dataspaceID=H5D.get_space(input_datasetID);

	% create and then open output file
	create_hdf5_file(h5outputfile, h5outputpath, input_size(1:3), blksz, blksz, 'int');
	output_dataID=H5F.open(h5outputfile,'H5F_ACC_RDWR','H5P_DEFAULT');
	output_datasetID=H5D.open(output_dataID, h5outputpath);	
	output_dataspaceID=H5D.get_space(output_datasetID);

	if(isempty(begin_coords))
		begin_coords=[];
	end
	
	if(isempty(end_coords))
		end_coords=input_size;
	end

	sz=end_coords-begin_coords+1;

	blocks_sent=0;
	blocks_received=0;
	last_flush=clock;
	
	%% connect components of the blocks
	for iblk = begin_coords(1):blksz(1):end_coords(1),
		for jblk = begin_coords(2):blksz(2):end_coords(2),
			for kblk = begin_coords(3):blksz(3):end_coords(3),
				
				% get this block of the component file
				block_pack.begin_coords=[iblk jblk kblk];
				block_pack.end_coords=[min(end_coords(1),iblk+blksz(1)-1) min(end_coords(2),jblk+blksz(2)-1) min(end_coords(3),kblk+blksz(3)-1)];				
				block_pack.comp_block=get_hdf5(input_datasetID, input_dataspaceID, block_pack.begin_coords, block_pack.end_coords);
				block_pack.comp_list=comp_list;
				
				% wait for a processed sample if no open labs
				while(isempty(open_labs))	
					wait_and_process
				end
		
				% send out new block
				target=open_labs(1);		
				labSend(block_pack, target, 1);
				if(length(open_labs)>1), open_labs=open_labs(2:end); 
				else, open_labs=[]; end
				blocks_sent=blocks_sent+1;	
								
			end
		end
	end
	while(blocks_received<blocks_sent)
		wait_and_process
	end
		
		
	% kill slave nodes
	for lab=1:length(open_labs)
		labSend([], open_labs(lab), 666);
	end	
	
else
	% slave lab
	keep_going=true;
	worker=getCurrentWorker;
	hostname=get(worker, 'HostName');
	
	while(keep_going)
	
		% receive new sample to process
		[sample_pack, source, tag]=labReceive;
		
		if(tag==1)
			
			if(~reorder)
				sample_output.new_comp_block = int32(SelectComponents(sample_pack.comp_block, sample_pack.comp_list ));
				%comp_block = int32(SelectComponents(comp_block, comp_list ));
			else
				sample_output.new_comp_block = int32(SelectComponentsReorder(sample_pack.comp_block, sample_pack.comp_list ));
				%comp_block = int32(SelectComponentsReorder(comp_block, comp_list ));
			end
			

			
			%sample_output.new_comp_block = int32(SelectComponents(sample_pack.comp_block, sample_pack.comp_list ));
			sample_output.begin_coords=sample_pack.begin_coords;
			sample_output.end_coords=sample_pack.end_coords;
	
			labSend(sample_output, head, 1);
			
		elseif(tag==666)
			keep_going=false;
		end
	end
end


function [] = wait_and_process()
	% wait for a finished sample
	[sample_output, source, tag]=labReceive;

	open_labs=[open_labs source];
	blocks_received=blocks_received+1;
	
	write_hdf5(output_datasetID, output_dataspaceID, sample_output.begin_coords, sample_output.end_coords, sample_output.new_comp_block);					
		
end

end
