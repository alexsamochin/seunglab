function [ws dend] = ws_mex(conn,nh,thresh)
%% Watershed transform (non-marker based)
%% [W D] = markerWatershed (conn,nh,thresh) computes the component labelings of
%% each node under the watershed algorithm. 
%% If a node is label 0, then it has not been assigned a watershed component, most likely because the edges adjacent to the node are below the threshold.
%
%% If a node's label is a positive integer N, then it is in the same watershed component as other nodes with label N.
%% The connectivity matrix (conn) can have any dimensions D, and the neighborhood matrix that specifies adjacent nodes
%% can have any number of rows given that the number of columns is D-1.
%
%% A lower threshold can be set (thresh) so that the watershed algorithm stops once the threshold has been reached.
%%
%% The output matrix W contains the watershed labelings, and will have the same dimensions as first D-1 dimensions of the conn matrix.
%% The output D is the dendrogram specifying at which value or height each labeled watershed component first meets with another labeled component.




conn=single(conn);
nh=double(nh);
% label=double(label);
thresh=double(thresh(:));

[ws dend]=markerWatershedmex(conn,nh,thresh);
