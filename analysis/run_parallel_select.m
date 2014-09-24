
h5file='/home/viren/process_networks/e1088_638_graph/c85_450_1500.h5'
h5path='/main';
h5outputfile='/home/viren/process_networks/e1088_638_graph/c85_450_1500_selected_reorder_both.h5'
h5outputpath='/main';
reorder=true;

%max_workers=8;

sched=findResource('scheduler','type','jobmanager','Name','general');

pjob=createParallelJob(sched);
set(pjob, 'FileDependencies',{'/home/viren/EM/util/','/home/viren/EM/analysis','/home/viren/EM/nn/hdf5','/home/viren/EM/parallel/assign_role.m'});

train=createTask(pjob, @SelectComponentsParallel, 1, {h5file, h5path, h5outputfile, h5outputpath, [1 1 450], [1768 1001 1500], '', comp_list, reorder} );

set(train,'CaptureCommandWindowOutput',true);

display(['select components distributed hdf5 processing. no further console messages.']);

submit(pjob);
waitForState(pjob);
results=getAllOutputArguments(pjob);
errmsgs=get(train,{'ErrorMessage'});
msgs=get(train,{'CommandWindowOutput'});
destroy(pjob);

