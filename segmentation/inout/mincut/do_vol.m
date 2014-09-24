function [seg,perf]=do_vol(vol,comp,theta,J)
% [seg,perf]=do_vol(vol,comp,theta,J)
% do volume vol at with given theta and J, check performance against
% tracing comp
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
% fin, 04-07
% $Id: do_vol.m 119 2007-03-19 17:18:30Z fin $

addpath('../adjacency_list');
addpath('~/svn/EM/segmentation/');


[m,n,l] = size(vol);

% renormalize image to mean 0 and variance 16 (min cut algorithm runs with integers)
im3=vol-mean(vol(:));
im3=16*double(im3/std(im3(:)));

trace=comp>0;

trace=reshape(trace,[m*n*l 1]);


clear comp


% use srini's wheight matrix and threshold it to get adjacency matrix
W=MakeNCutW(im3);
nn=W>0;
[i,j]=find(nn);
lidx=find(i<j);
clear W;
clear nn;

[m,n,l] = size(im3);
I=reshape(im3,[m*n*l 1]);


nedges=size(lidx,1);


[perf,cut]=do_cut_compare(I,trace,theta,J,i(lidx),j(lidx));
%
%
%ssm=1*[I-theta theta-I];
%
%
%Jm=J*ones(nedges,1);
%
%adm=[i(lidx) j(lidx) Jm Jm];
%
%cut=cut_graph_al(ssm,adm);
%
cc=reshape(cut,[m n l]);

%diff=cc-trace;
%perf=sum(abs(diff(:)));

seg=cc;
