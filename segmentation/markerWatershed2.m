function [ws dend] = markerWatershedmex(conn,nh,label,thresh)
%% Marker-based Watershed transform
%% [W D] = markerWatershed (conn,nh,label,thresh) computes the component labelings of
%% each node under the watershed algorithm, given labeled starting markers whose values are greater than 0.
%% If a node is label 0, then it is not in the watershed component of any of the starting labeled nodes.
%% If a node's label is a positive integer N, then it is in the watershed component of a starting node label with N.
%% The connectivity matrix (conn) can have any dimensions D, and the neighborhood matrix that specifies adjacent nodes
%% can have any number of rows given that the number of columns is D-1.
%% The matrix of initial node labels (label) must have D-1 dimensions which match the first D-1 dimensions of conn.
%% Each element of the label matrix must be a non-negative integer.
%% A lower threshold can be set (thresh) so that thw atershed algorithm stops once the threshold has been reached.
%%
%% The output matrix W is the watershed labelings given the markers, and will have the same dimensions as the marker matrix.
%% The output D is the dendrogram specifying at which value or height each labeled component first meets with another label component.




conn=single(conn);
nh=double(nh);
label=double(label);
thresh=double(thresh(:));

[ws dend]=markerWatershed2mex(conn,nh,label,thresh);
