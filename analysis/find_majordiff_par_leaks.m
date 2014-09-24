function [diffs, errmsgs, msgs]=find_majordiff_par_leaks(labels, output, label_mask, begin_coords, end_coords, total_blocksize, replace_blocksize, blksz, max_workers)

hlf_total=floor(total_blocksize/2);
hlf_replace=floor(replace_blocksize/2);

% save out information for this job so workers can load 
save_directory='/home/viren/process_networks/merger_find/';
mkdir(save_directory);
label_send=[save_directory 'label_send'];
mask_send=[save_directory 'mask_send'];
output_send=[save_directory 'output_send'];
save(label_send,'labels');
save(mask_send,'label_mask');
save(output_send, 'output');


% prepare data by distributing arguments along z-axis
i=1;
for kblk = begin_coords(3)+hlf_total(3):blksz(3):end_coords(3)-hlf_total(3)
	%kblk
	
	distributed_args{i}={[begin_coords(1) begin_coords(2) kblk], [end_coords(1) end_coords(2) kblk], ...,
						  total_blocksize, replace_blocksize, blksz, label_send, output_send, mask_send};
	i=i+1;	
end

% prepare the parallel job
EMroot='/home/viren/EM';
sched=get_sched('general');
j=sched.createJob();
evaldiff=createTask(j, @majordiff_leaks, 1, distributed_args);
set(j, 'MaximumNumberOfWorkers', max_workers);
set(j, 'PathDependencies',{[EMroot '/analysis/'], [EMroot '/util/'], [EMroot '/segmentation/'], [EMroot '/segmentation/inout/adjacency_list/'], [EMroot '/lib/matlab_bgl-3.0-beta/']});
set(evaldiff,'CaptureCommandWindowOutput',true);
jobID=j.ID;
display(['distributed processing on on job ID ', num2str(jobID),'.']);



% run the job
submit(j);
tic
waitForState(j);
toc
errmsgs=get(evaldiff,{'ErrorMessage'});
msgs=get(evaldiff,{'CommandWindowOutput'});

% gather results and combine
results=get(evaldiff,'OutputArguments');
diffs=zeros([size(output(:,:,:,1)) 4],'single');
for i=1:length(results)
	return_diff=results{i};
	if(~isempty(return_diff))
		lab_diff=return_diff{1};
		diffs(lab_diff.begin_coords(1):lab_diff.end_coords(1),lab_diff.begin_coords(2):lab_diff.end_coords(2), lab_diff.begin_coords(3):lab_diff.end_coords(3),:)=diffs(lab_diff.begin_coords(1):lab_diff.end_coords(1),lab_diff.begin_coords(2):lab_diff.end_coords(2), lab_diff.begin_coords(3):lab_diff.end_coords(3),:)+lab_diff.diffs;
	end
end

% crop mergers and split voxels to regions within mask
%diffs(:,:,:,2)=diffs(:,:,:,2).*(sum(label_mask,4)>0);
%diffs(:,:,:,3)=diffs(:,:,:,3).*(sum(label_mask,4)>0);
