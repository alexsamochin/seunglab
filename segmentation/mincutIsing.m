function inout = mincutIsing(i,j,J_ij,h_i)
% MINCUTISING	computes the MAP of an Ising MRF
%
%	inout = mincutMAP(i,j,J_ij,h)
%
% Computes the MAP of an Ising MRF given by the general graph J
% and field h. This corresponds to finding the global minimum of:
%
%    E = - (\sum_{ij} J_{ij}*s_i*s_j + h_i*s_i)
%
% J_ij *must* be non-negative!

% normalize
mx = max(max(J_ij),max(abs(h_i)));
J_ij = double(J_ij) * 256/mx;
h_i = double(h_i) * 256/mx;

inout = cut_graph_al(max(0,[h_i -h_i]),[i j J_ij J_ij]);
