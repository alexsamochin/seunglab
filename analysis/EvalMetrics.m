function [score, n_mergers, n_splits] = EvalMetrics(metric_fun, xrange, yrange, zrange, comp_human, varargin)
% [score, n_mergers, n_splits] = EvalMetrics(metric_fun, xrange, yrange, zrange, comp_human, varargin)
%
%
% JFM   8/7/2006
% Rev:  4/12/2006

% Components smaller than thresh are not examined
vol_thresh = 10;


% Get the right range to evaluate the metric over
comp_test = comp_human(yrange, xrange, zrange);
comp_test = DeleteSmallComponents(comp_test, vol_thresh);


n_comp = nargin-5;

score = zeros(1, n_comp);
n_mergers = zeros(1, n_comp);
n_splits = zeros(1, n_comp);


% Evaluate the metric for all the test components
for i = 1:n_comp
    comp = varargin{i};
    est_comp = comp(yrange, xrange, zrange);

    % Remove the smallest components
    est_comp = DeleteSmallComponents(est_comp, vol_thresh);
    
    % Run the metric
    [voxel_score2, n_sp, n_me] = metric_fun(comp_test, est_comp);
    
    score(i) = voxel_score2;
    n_splits(i) = n_sp;
    n_mergers(i) = n_me;
    
end