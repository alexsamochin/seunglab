% Rand error, Turaga error and Variation of information
% with N^2 normalization
% input: segA and segB are label matrices.
% It assumes segmentation labels start at 1
function [re, te, vi] = compare_partitions_asymmetric_N2( segA, segB )

segA = double(segA);
segB = double(segB);
n = prod(size(segA));

n_labels_A = max(segA(:));
n_labels_B = max(segB(:));

% compute overlap matrix
p_ij = sparse(segA(:),segB(:),1/n,n_labels_A,n_labels_B);

% a_i
a_i = sum(p_ij(2:end,:), 2);

% b_j
b_j = sum(p_ij(2:end,2:end), 1);

p_ij = p_ij(2:end,2:end);

% Rand error with N^2 normalization
re = sum(a_i .* a_i) + sum(b_j .* b_j) - 2 * sum( sum( p_ij .^2 ) );
re = full(re);

% Variation of information
aux = p_ij .* log(p_ij);
aux(isnan(aux))=0;

aux1 = a_i .* log( a_i );
aux1(isnan(aux1))=0;

aux2 = b_j .* log( b_j );
aux2(isnan(aux2))=0;

vi = sum( aux1 ) + sum( aux2  ) - 2 * sum( sum(aux) );
vi = full( vi );

% Turaga error
aux1 = (a_i .* a_i - sum( p_ij .^2, 2 )) ./ a_i;
aux1(isnan(aux1))=0;

aux2 = (b_j .* b_j - sum( p_ij .^2, 1 )) ./ b_j;
aux2(isnan(aux2))=0;

te = sum( aux1 ) + ...
     sum( aux2 );
te = full( te );