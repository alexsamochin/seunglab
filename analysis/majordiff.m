function [diff_return]=majordiff(begin_coords, end_coords, total_blocksize, replace_blocksize, blksz, varargin)
% diffs along last dimension: voxel score, splits, mergers, count

nargin

if(nargin>5)

	labels=varargin{1};
	output=varargin{2};
	label_mask=varargin{3};
	
else

	labindex
	j=getCurrentJob;
	jobdata=get(j,'JobData')
	%labels=[]; output=[]; label_mask=[];
	labels=jobdata.labels;
	output=jobdata.output;
	label_mask=jobdata.label_mask;
end

begin_coords
end_coords
total_blocksize
replace_blocksize
blksz

output=output.*(label_mask>0);
labels=labels.*(label_mask>0);

nhood=mknhood(6);

diffs=zeros([size(output(:,:,:,1)) 4],'single');

hlf_total=floor(total_blocksize/2);
hlf_replace=floor(replace_blocksize/2);

kblk=begin_coords(3);
	for iblk = begin_coords(1)+hlf_total(1):blksz(1):end_coords(1)-hlf_total(1),
		for jblk = begin_coords(2)+hlf_total(2):blksz(2):end_coords(2)-hlf_total(2),

			total_begin_coords=[iblk-hlf_total(1) jblk-hlf_total(2) kblk-hlf_total(3)];
			total_end_coords=[iblk+hlf_total(1) jblk+hlf_total(2) kblk+hlf_total(3)];				

			replace_begin_coords=[iblk-hlf_replace(1) jblk-hlf_replace(2) kblk-hlf_replace(3)];
			replace_end_coords=[iblk+hlf_replace(1) jblk+hlf_replace(2) kblk+hlf_replace(3)];

			% check if this replace-region falls inside the label mask
			mask_block=label_mask(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), :);
			
			% check if this region has any true components inside it
			label_totalblock=labels(total_begin_coords(1):total_end_coords(1), total_begin_coords(2):total_end_coords(2), total_begin_coords(3):total_end_coords(3), :);
			
			if(nnz(mask_block)>0 && nnz(label_totalblock)>0)
			
				% create true component structure
				label_compblock=connectedComponents(label_totalblock,nhood);
				
				% replace connectivity from network output and re-generate component structure
				output_replaceblock=output(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), :);
				%output_replaceblock=output_replaceblock.*(mask_block>0);
				replaced_totalblock=label_totalblock;
				replaced_totalblock(hlf_total(1)+1-hlf_replace(1):hlf_total(1)+1+hlf_replace(1),hlf_total(2)+1-hlf_replace(2):hlf_total(2)+1+hlf_replace(2),hlf_total(3)+1-hlf_replace(3):hlf_total(3)+1+hlf_replace(3),:)=output_replaceblock;
				replaced_compblock=connectedComponents(replaced_totalblock,nhood);			
				
				%try
					[voxel_score, n_splits, n_mergers, splits, mergers]	= MetricsAllMatches(label_compblock, replaced_compblock, false);
				%catch
				%	total_begin_coords
				%	total_end_coords
				%	BrowseComponents('cci',label_compblock,replaced_compblock,sum(label_totalblock,4));
				%end
					
				diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),1)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 1)+voxel_score;
				diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),2)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 2)+n_splits;
				diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),3)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 3)+n_mergers;
				diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),4)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 4)+1;

			end
			
		end
	end
	[iblk, jblk, kblk]

diff_return.diffs=diffs(begin_coords(1):end_coords(1), begin_coords(2):end_coords(2), kblk-hlf_replace(3):kblk+hlf_replace(3),:);
diff_return.begin_coords=[begin_coords(1) begin_coords(2) kblk-hlf_replace(3)];
diff_return.end_coords=[end_coords(1) end_coords(2) kblk+hlf_replace(3)];
