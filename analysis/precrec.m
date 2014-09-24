function [prec, rec] = precrec(t, y)
%
% precrec - generate a precision-recall curve
%
%    [prec,rec] = precrec(T,Y) gives the true-positive rate (TP) and false positive
%    rate (FP), where Y is a column vector giving the score assigned to each
%    pattern and T indicates the true class (a value above zero represents
%    the positive class and anything else represents the negative class).  To
%    plot the ROC curve,
%
%       PLOT(FP,TP);
%       XLABEL('FALSE POSITIVE RATE');
%       YLABEL('TRUE POSITIVE RATE');
%       TITLE('RECEIVER OPERATING CHARACTERISTIC (ROC)');

% process targets

t = t(:) > 0;
y = y(:);

% sort by classifier output

[Y,idx] = sort(-y);
t       = t(idx);

% compute true positive and false positive rates

rec = cumsum(t)/sum(t);
prec = cumsum(t)./[1:length(t)]';

% add trivial end-points

rec = [0 ; rec ; 1];
prec = [1 ; prec ; 0];

% bye bye...

