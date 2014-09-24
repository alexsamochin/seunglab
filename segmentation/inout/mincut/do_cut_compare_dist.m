 function perf=do_cut_compare_dist(thresh,J)
% perf=do_cut_compare(I,trace,thresh,J,is,js)    
    
    job=getCurrentJob();
    myData=job.get('JobData');
    I=myData{1};
    trace=myData{2};
    is=myData{3};
    js=myData{4};

    ssm=1*[I-thresh thresh-I];

    nedges=length(is);
    Jm=J*ones(nedges,1);

    adm=[is js Jm Jm];

    cut=cut_graph_al(ssm,adm);

    diff=cut-trace;
    perf=sum(abs(diff(:)));

    
