% Rand error function with N^2 normalization
% input: segA and segB are 2D vectors with labels.
% It assumes segmentation labels start at 1
function re = n2RandError( segA, segB )

segA = double(segA);
segB = double(segB);
n = prod(size(segA));

n_labels_A = max(segA(:));
n_labels_B = max(segB(:));

% compute overlap matrix
p_ij = sparse(segA(:),segB(:),1/n,n_labels_A,n_labels_B);

% a_i
a_i = sum(p_ij,1);

% b_j
b_j = sum(p_ij,2);

% Rand error with N^2 normalization
re = sum(a_i .* a_i) + sum(b_j .* b_j) - 2 * sum( sum( p_ij .^2 ) );
re = full(re);