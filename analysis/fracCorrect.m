function [p,th] = fracCorrect(t, y)
%
% fracCorrect computes the fraction of correct classifications at the optimal threshold
%
%    [p,th] = fracCorrect(T,Y)

% process targets

t = t(:) > 0;
y = y(:);

% sort by classifier output

[Y,idx] = sort(y);
t       = t(idx);

% compute true positive and true negative rates

% p = cumsum(t);
% th = cumsum(~t);

% for k=1:length(t),
% 	err(k) = sum(~t(1:k)) + sum(t(k+1:end));
% end
negerr = cumsum(~t);
poserr = sum(t) - cumsum(t);
err = (negerr+poserr)/length(t);

% add and find the peak
[p,th]=max(err);
th = Y(th);
