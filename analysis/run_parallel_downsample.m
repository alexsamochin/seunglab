
%h5inputfile='/local_data/viren/mpi/e592/tile9/h5/processed/pretracing_cropped_e29_1_962_seg929292.h5'
%h5inputpath='/main';
%h5outputfile='/local_data/viren/mpi/e592/tile9/h5/processed/other/selected_1_962_seg939393_255.h5'
%h5outputpath='/main';

%max_workers=8;

sched=findResource('scheduler','configuration','jobmanager','Name','winfried_local');
set(sched,'Configuration','jobmanager');

pjob=createParallelJob(sched);
set(pjob, 'FileDependencies',{'/home/viren/random_code/util/','/home/viren/common/EM/analysis','/home/viren/common/EM/nn/hdf5','/home/viren/common/EM/parallel/assign_role.m'});

train=createTask(pjob, @DownsampleComponentsParallel, 1, {h5inputfile, h5inputpath, h5outputfile, h5outputpath, [1 1 1], [1452 1254 962], 'winfried', 2} );

%set(pjob, 'MaximumNumberOfWorkers', max_workers);
set(train,'CaptureCommandWindowOutput',true);

display(['downsample distributed hdf5 processing. no further console messages.']);

submit(pjob);
waitForState(pjob);
results=getAllOutputArguments(pjob);
errmsgs=get(train,{'ErrorMessage'});
msgs=get(train,{'CommandWindowOutput'});
destroy(pjob);

