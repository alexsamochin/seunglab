function [blocks_received] = connectedComponentsParallel(h5inputfile, h5inputpath, h5outputfile, h5outputpath, bb, blksz, nhood, threshold, verbose, desired_head, prestitch_directory)
% Finds connected components according to the connectivity structure G
% Usage:
% components = connectedComponentsParallel(G,nhood)
nObj=0;

[head, open_labs]=assign_role(desired_head);

if(labindex==head)

	% head lab	
	if ~exist('nhood') || isempty(nhood),
		nhood = mknhood(6);
	end	

	log_message([], 'head node ');
	log_message([], num2str(blksz));

	
	begin_coords=bb(:,1);
	end_coords=bb(:,2);

	log_message([], num2str(begin_coords'));
	log_message([], num2str(end_coords'));
	
	%sz=end_coords-begin_coords+1;
	
	cmpMax = 0;
	blocks_sent=0;
	blocks_received=0;



	%% connect components of the blocks
	for iblk = begin_coords(1):blksz(1):end_coords(1),
		for jblk = begin_coords(2):blksz(2):end_coords(2),
			for kblk = begin_coords(3):blksz(3):end_coords(3),

%				log_message([], num2str(blocks_sent));
				
				% prepare info for worker node
				block_pack.output_start_coords=[iblk jblk kblk];
				block_pack.output_end_coords=[min(end_coords(1),iblk+blksz(1)-1) min(end_coords(2),jblk+blksz(2)-1) min(end_coords(3),kblk+blksz(3)-1)];					
				block_pack.begin_coords=[block_pack.output_start_coords 1]
				block_pack.end_coords=[block_pack.output_end_coords bb(end,2)]
				block_pack.nhood=nhood;
				block_pack.threshold=threshold;
				block_pack.h5inputfile=h5inputfile;
				block_pack.h5inputpath=h5inputpath;
				block_pack.prestitch_directory=prestitch_directory;
				block_pack.block_num=blocks_sent+1;
				
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
	blocks_received=0;
	
	while(keep_going)
	
		% receive new sample to process
		[sample_pack, source, tag]=labReceive;
		
		if(tag==1)
		
			% retrieve block and process it
			g=get_hdf5_file(sample_pack.h5inputfile, sample_pack.h5inputpath, sample_pack.begin_coords, sample_pack.end_coords);
			g=g>sample_pack.threshold;			
					
			if(ndims(g)~=4)
			log_message([], [num2str(labindex),' b ', num2str(sample_pack.begin_coords)]);
			log_message([], [num2str(labindex),' e ', num2str(sample_pack.end_coords)]);
			log_message([], [num2str(labindex), ' size: ', num2str(size(g))]);
			end
			try
			[cmpblk,nObj] = connectedComponentsBlocks(g, sample_pack.nhood, false);
			catch
			log_message([], [num2str(labindex),' b ', num2str(sample_pack.begin_coords)]);
			log_message([], [num2str(labindex),' e ', num2str(sample_pack.end_coords)]);
			log_message([], [num2str(labindex), ' size: ', num2str(size(g))]);
			end
%			log_message([], 'slave processed package');
			
			% we're outputting this block to a file
			output_start_coords=sample_pack.output_start_coords;
			output_end_coords=sample_pack.output_end_coords;
			block_num=sample_pack.block_num;
			save([sample_pack.prestitch_directory, num2str(block_num)], 'cmpblk', 'output_start_coords', 'output_end_coords','block_num','nObj'); 
			
			% tell head node we're done
			sample_output.block_num=block_num;				
			sample_output.nObj=nObj;
			labSend(sample_output, head, 1);
			
		elseif(tag==666)
			keep_going=false;
		end
	end
end


function [] = wait_and_process()
	% wait for a finished sample
	[sample_output, source, tag]=labReceive;

	% write it out once received
	open_labs=[open_labs source];
	blocks_received=blocks_received+1;
end

end
