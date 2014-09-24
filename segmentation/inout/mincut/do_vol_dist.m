% do grid search on parameters of ising-model - distributed
%
% Model: E= - sum_{ij} J_{ij} s_i s_j - sum_i (I_i-theta) s_i
% s_i \in \{-1, 1\}
%
% Minimum can be found efficiently by finding min-cut of graph
% similar to [1], with weights t^alpha_i = +-I_i, and e_{ij}=2*J_{ij}
%
% J_{ij} = J, I_i = \hat{I}_i-theta, \hat{I}=image with mean 0 and
% variance 16
%
% parameters to find are 
%
% [1] Y. Boykov et al., Fast Approcimate Energy Minimaization via Graph
% Cuts, IEEE Trans on Pattern Analysis and Machine Intelligence, 2001(22), 1222
%
% fin, 03-07
% $Id: do_vol_dist.m 241 2007-04-12 15:54:22Z fin $

load ~/retina1/retina1.mat
load ~/retina1/retina1_comp0707.mat

% supersample 


clear conn
clear components

addpath('../adjacency_list');
addpath('~/svn/EM/segmentation/');

tic
im=retina1.im;
clear retina1;

im3=im-mean(im(:));
im3=16*double(im3/std(im3(:)));

im3train=im3(20:70,20:120,10:100);

trace=comp>0;
trace=trace(20:70,20:120,10:100);

clear comp


% supersample image
im3train = supersample(im3train);




% use srini's wheight matrix and threshold it to get adjacency matrix
W=MakeNCutW(im3train);
nn=W>0;
[i,j]=find(nn);
lidx=find(i<j);
clear W;
clear nn;




[m,n,l] = size(im3train);
I=reshape(im3train,[m*n*l 1]);




nedges=size(lidx,1);



threshrange=-15:1:2;
Jrange=0:2:100;

trace=reshape(trace,[m*n*l 1]);

is=i(lidx);
js=j(lidx);

% pack this date into jobData to minimize IO
jobData{1}=I;
jobData{2}=trace;
jobData{3}=is;
jobData{4}=js;

clear Jdist;
clear threshdist;

jm=findResource('scheduler','type','jobmanager','Name','general');


for ti=1:length(threshrange);
  thresh=threshrange(ti);
  for ji=1:length(Jrange)
    J=Jrange(ji);
    thresh
    J

    threshdist{ji}=thresh;
    Jdist{ji}=J;
  end
    

  perf=dfeval(@do_cut_compare_dist,threshdist,Jdist,'JobManager','general','PathDependencies',{'/home/fin/segment/mincut/','/home/fin/segment/adjacency_list'},'JobData',jobData);

  jobs=jm.findJob('State','finished','UserName','fin');
  destroy(jobs);
  clear jobs;
  
   for ji=1:length(Jrange)
     score(ti,ji)=perf{ji};
   end

end
disttime=toc

[ti,ji]=find(score==min(score(:)));

minthresh=threshrange(ti(1));
minJ = Jrange(ji(1));



save result2 score disttime minthresh minJ
