% Rand error, Turaga error and Variation of information
% with N^2 normalization
% input: segA and segB are label matrices.
% It assumes segmentation labels start at 0 and BackGround=0
% It assumes segA is the groundtruth
function [re, te, vi] = compare_partitions_asymmetric_N2( segA, segB )

segA = double(segA)+1;
segB = double(segB)+1;
n = prod(size(segA));

n_labels_A = max(segA(:));
n_labels_B = max(segB(:));

% compute overlap matrix
p_ij = sparse(segA(:),segB(:),1/n,n_labels_A,n_labels_B);

% a_i
a_i = sum(p_ij(2:end,:), 2);

% b_j
b_j = sum(p_ij(2:end,2:end), 1);

p_i0 = p_ij(2:end,1);	% pixels marked as BG in segB which are not BG in segA
p_ij = p_ij(2:end,2:end);

% Rand error with N^2 normalization
sumA = sum(a_i.*a_i);
sumB = sum(b_j.*b_j) +  sum(p_i0)/n;
sumAB = sum(sum(p_ij.^2)) + sum(p_i0)/n;
re = full(sumA + sumB - 2*sumAB);

% Turaga error
aux = (a_i.*a_i - (sum(p_ij.^2,2)+p_i0/n)) ./ a_i;
sumA = sum(aux(~isnan(aux)));

aux = (b_j.*b_j - sum(p_ij.^2,1)) ./ b_j;
sumB = sum(aux(~isnan(aux)));

te = full(sumA + sumB);

% Variation of information
aux = a_i .* log(a_i);
sumA = sum(aux(~isnan(aux)));

aux = b_j .* log(b_j);
sumB = sum(aux(~isnan(aux))) - sum(p_i0)*log(n);

aux = p_ij .* log(p_ij);
sumAB = sum(aux(~isnan(aux))) - sum(p_i0)*log(n);

vi = full(sumA + sumB - 2*sumAB);

