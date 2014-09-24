function [evecs,evals] = NCutEig(W,k)
% Compute the K normalized cut eigenvectors

n = size(W,1);
D = sparse(1:n,1:n,sum(W));

opts.issym = true;
[evecs,evals] = eigs(D-W,D,k+1,'sa',opts);
evecs = evecs(:,2:end);
evals = diag(evals); evals = evals(2:end);
