function [A,l]=normcol(A)
% NORMCOL - normalizes the columns of a matrix A
% Inputs:	A - matrix (M x N)
% Outputs:	A - matrix whose columns have been normalized to 1
% 		l - original column norms
% function [A,l]=normcol(A)

% *** UNCLASSIFIED ***
% $Id: normcol.m,v 1.5 2002/08/05 17:43:55 gronosky Exp $

[m,n]=size(A);
l=zeros(1,n);
for i=1:n,
  l(i)=norm(A(:,i));
end

L=l(ones(m,1),:);
A=A./L;
