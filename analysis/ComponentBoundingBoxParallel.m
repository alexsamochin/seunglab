function [total_mins, total_maxs, total_labels] = ComponentBoundingBoxParallel(h5inputfile, h5inputpath, begin_coords, end_coords, desired_head)

[head, open_labs]=assign_role(desired_head);
sizes={};
total_mins=[];
total_maxs=[];
total_labels=[];

if(labindex==head)

	% head lab	
	blksz = [300 300 300];
			
	% open input file
	[ndims, input_size, max_size]=get_hdf5_size(h5inputfile, h5inputpath);
	input_dataID=H5F.open(h5inputfile,'H5F_ACC_RDONLY','H5P_DEFAULT');
	input_datasetID=H5D.open(input_dataID, h5inputpath);
	input_dataspaceID=H5D.get_space(input_datasetID);

	if(isempty(begin_coords))
		begin_coords=[1 1 1];
	end
	
	if(isempty(end_coords))
		end_coords=input_size';
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
				block_pack.comp=get_hdf5(input_datasetID, input_dataspaceID, block_pack.begin_coords, block_pack.end_coords);
				
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
	
	num_nonempty=0;
	for i=1:length(sizes)
		if(~isempty(sizes{i}))
			num_nonempty=num_nonempty+1;
		end
	end
	
	total_labels=zeros([num_nonempty 1], 'uint32');
	total_mins=zeros([num_nonempty 3], 'uint32');
	total_maxs=zeros([num_nonempty 3], 'uint32');
	
	
	% compile results
	store_count=0;
	for i=1:length(sizes)
		if(~isempty(sizes{i}))
			store_count=store_count+1;
			total_labels(store_count)=i;
			total_mins(store_count,:)=sizes{i}.mins;
			total_maxs(store_count,:)=sizes{i}.maxs;
		end
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
			
			[mins, maxs, labels] = ComponentBoundingBox(sample_pack.comp);
			sample_output.mins=uint32(mins);
			sample_output.maxs=uint32(maxs);
			sample_output.labels=uint32(labels);
			sample_output.begin_coords=uint32(sample_pack.begin_coords);
			sample_output.end_coords=uint32(sample_pack.end_coords);
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

	% update global size stats
	for c=1:length(sample_output.labels)
		
		if(sample_output.labels(c)>0)
	
			adjusted_mins=(sample_output.begin_coords+sample_output.mins(c,:))-1;
			adjusted_maxs=(sample_output.begin_coords+sample_output.maxs(c,:))-1;
			
			if(~isempty(sizes) && sample_output.labels(c) <= length(sizes) && ~isempty(sizes{sample_output.labels(c)}))
				sizes{sample_output.labels(c)}.mins=min(adjusted_mins, sizes{sample_output.labels(c)}.mins);
				sizes{sample_output.labels(c)}.maxs=max(adjusted_maxs, sizes{sample_output.labels(c)}.maxs);
			else
				sizes{sample_output.labels(c)}.mins=adjusted_mins;
				sizes{sample_output.labels(c)}.maxs=adjusted_maxs;			
			end
			
		end			
	end
	
	
end

end
