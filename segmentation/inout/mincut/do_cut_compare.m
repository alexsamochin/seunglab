 function [perf,cut]=do_cut_compare(I,trace,thresh,J,is,js)
% perf=do_cut_compare(I,trace,thresh,J,is,js)    
    ssm=1*[I-thresh thresh-I];

    nedges=length(is);
    Jm=J*ones(nedges,1);

    adm=[is js Jm Jm];

    cut=cut_graph_al(ssm,adm);

    diff=cut-trace;
    perf=sum(abs(diff(:)));

    
