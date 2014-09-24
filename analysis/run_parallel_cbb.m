
%h5file='/local_data/viren/mpi/e592/tile9/h5/processed/pretracing_cropped_e29_1_962_seg929292.h5'
h5file='/home/viren/process_networks/e1088_638_graph/c85_450_1500.h5'
h5path='/main';

%max_workers=8;

sched=findResource('scheduler','type','jobmanager','Name','general');
%set(sched,'Configuration','jobmanager');

pjob=createParallelJob(sched);
set(pjob, 'FileDependencies',{'/home/viren/EM/util/','/home/viren/EM/analysis','/home/viren/EM/nn/hdf5','/home/viren/EM/parallel/assign_role.m'});

tic
train=createTask(pjob, @ComponentBoundingBoxParallel, 3, {h5file, h5path, [1 1 450], [1768 1001 1500], ''} );
total_time=toc;

%set(pjob, 'MaximumNumberOfWorkers', max_workers);
set(train,'CaptureCommandWindowOutput',true);

display(['component bounding box hdf5 processing. no further console messages.']);

submit(pjob);
waitForState(pjob);
results=getAllOutputArguments(pjob);
errmsgs=get(train,{'ErrorMessage'});
msgs=get(train,{'CommandWindowOutput'});
destroy(pjob);

