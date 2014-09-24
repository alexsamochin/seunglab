function [diff_return]=majordiff_leaks(begin_coords, end_coords, total_blocksize, replace_blocksize, blksz, labels, output, label_mask)
% diffs along last dimension: voxel score, splits, mergers, count

hlf_total=floor(total_blocksize/2);
hlf_replace=floor(replace_blocksize/2);

% load in data if we are given strings
if(ischar(labels))
	load(labels);
end
if(ischar(output))
	load(output);
end
if(ischar(label_mask))
	load(label_mask);
end

% crop data to the slice we are working on
kblk=begin_coords(3);
labels=labels(:,:,kblk-hlf_total(3):kblk+hlf_total(3),:);
output=output(:,:,kblk-hlf_total(3):kblk+hlf_total(3),:);
label_mask=label_mask(:,:,kblk-hlf_total(3):kblk+hlf_total(3),:);

%output=output.*(label_mask>0);
labels=labels.*(label_mask>0);

if(size(labels,4)==3)
	nhood=mknhood(6);
else
	nhood=mknhood(26);
end

diffs=zeros([size(output(:,:,:,1)) 4],'single');

kblk=hlf_total(3)+1;
	for iblk = begin_coords(1)+hlf_total(1):blksz(1):end_coords(1)-hlf_total(1),
		for jblk = begin_coords(2)+hlf_total(2):blksz(2):end_coords(2)-hlf_total(2),

			total_begin_coords=[iblk-hlf_total(1) jblk-hlf_total(2) kblk-hlf_total(3)];
			total_end_coords=[iblk+hlf_total(1) jblk+hlf_total(2) kblk+hlf_total(3)];				

			replace_begin_coords=[iblk-hlf_replace(1) jblk-hlf_replace(2) kblk-hlf_replace(3)];
			replace_end_coords=[iblk+hlf_replace(1) jblk+hlf_replace(2) kblk+hlf_replace(3)];

			% check if this replace-region falls inside the label mask
			mask_block=label_mask(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), :);
						
			if(nnz(mask_block)>0)% && nnz(label_totalblock)>0)

				label_totalblock=labels(total_begin_coords(1):total_end_coords(1), total_begin_coords(2):total_end_coords(2), total_begin_coords(3):total_end_coords(3), :);
				mask_totalblock=label_mask(total_begin_coords(1):total_end_coords(1), total_begin_coords(2):total_end_coords(2), total_begin_coords(3):total_end_coords(3), :);

				% create true component structure
				label_compblock=connectedComponents(label_totalblock,nhood);
				% make space outside the mask into a single component in order to find leaks
				label_compblock(find(mask_totalblock(:,:,:,1)==0))=9999;
			
				% replace connectivity from network output and re-generate component structure
				output_replaceblock=output(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), :);
				%output_replaceblock=output_replaceblock.*(mask_block>0);
				replaced_totalblock=label_totalblock;
				replaced_totalblock(hlf_total(1)+1-hlf_replace(1):hlf_total(1)+1+hlf_replace(1),hlf_total(2)+1-hlf_replace(2):hlf_total(2)+1+hlf_replace(2),hlf_total(3)+1-hlf_replace(3):hlf_total(3)+1+hlf_replace(3),:)=output_replaceblock;
				replaced_compblock=connectedComponents(replaced_totalblock,nhood);			
				
				%try
					[voxel_score, n_splits, n_mergers, splits, mergers]	= MetricsAllMatches(label_compblock, replaced_compblock, false, 5, 5, 5);
				%catch
				%	total_begin_coords
				%	total_end_coords
				%	BrowseComponents('cci',label_compblock,replaced_compblock,sum(label_totalblock,4));
				%end
				all_splits_outside_mask=true;
				for sp=1:n_splits
					if(splits{sp}{1}~=9999)
						all_splits_outside_mask=false;
						break;
					end
				end
					
				diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),1)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 1)+voxel_score;
				if(~all_splits_outside_mask)
					diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),2)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 2)+n_splits;
				end
				diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),3)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 3)+n_mergers;
				diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3),4)=diffs(replace_begin_coords(1):replace_end_coords(1), replace_begin_coords(2):replace_end_coords(2), replace_begin_coords(3):replace_end_coords(3), 4)+1;

			end
			
		end
	end
	[iblk, jblk, kblk]

diff_return.diffs=diffs(begin_coords(1):end_coords(1), begin_coords(2):end_coords(2), kblk-hlf_replace(3):kblk+hlf_replace(3),:);
diff_return.begin_coords=[begin_coords(1) begin_coords(2) begin_coords(3)-hlf_replace(3)];
diff_return.end_coords=[end_coords(1) end_coords(2) begin_coords(3)+hlf_replace(3)];
