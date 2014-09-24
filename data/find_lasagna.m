function [lasagna, stdblock, combined]=find_lasagna(im, blksz, bb, total_thresh)
shift_size=[25 25];

if(isempty(bb))
	begin_coords=[1 1 1];
	end_coords=size(im);
else
	begin_coords=bb(:,1);
	end_coords=bb(:,2);
end

lasagna=zeros(size(im),'single');
stdblock=zeros(size(im),'single');
normblock=zeros(size(im),'single');

for iblk = begin_coords(1):shift_size(1):end_coords(1),
	for jblk = begin_coords(2):shift_size(2):end_coords(2),
		for kblk = begin_coords(3)+1:1:end_coords(3)-1,	
			block_begin_coords=[iblk jblk kblk-1];
			block_end_coords=[min(end_coords(1),iblk+blksz(1)-1) min(end_coords(2),jblk+blksz(2)-1) kblk+1];					

			eval_block=im(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), block_begin_coords(3):block_end_coords(3));
			c1=1-corr2(eval_block(:,:,1),eval_block(:,:,2));
			c2=1-corr2(eval_block(:,:,2),eval_block(:,:,3));

			
			%lasagna(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)=lasagna(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)+((c1+c2)/2);			
			lasagna(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)=lasagna(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)+min(c1,c2);			
			stdblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)=stdblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)+std2(eval_block(:,:,2));			
			normblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)=normblock(block_begin_coords(1):block_end_coords(1), block_begin_coords(2):block_end_coords(2), kblk)+1;			
		end
	end
end
normblock(find(normblock==0))=1;
lasagna=lasagna./normblock;
stdblock=stdblock./normblock;


combined=(lasagna.*(stdblock>0.04));

for i=1:size(combined,3)
	combined(:,:,i)=medfilt2(combined(:,:,i)>total_thresh, [40 40]);
end



