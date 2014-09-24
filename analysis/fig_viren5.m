% fig_viren5.m - Plots metrics results for a network
%
%
% JFM  8/7/2006
% Rev: 8/9/2006

cd /home/jfmurray/project/semdata/retina1

load retina1_viren4
load retina1_comp0707 comp   % tkelling
comp_human = comp;
clear comp;

load retina1_comp0724 comp   % mbangert
comp_human0724 = comp;
clear comp;

% Assumes that we've already generated the components at these
% levels of threshold.
thresh = [ 0.90 0.94 0.95 0.96 0.97 0.98 0.99 0.995 ] ;

% Phillip's test set
xrange = 20:120;
yrange = 71:120;
zrange = 7:94;  % To get only the part the network labeled

% Phillip's train set 20:70,20:120,1,1:100
%xrange = 20:120;
%yrange = 20:70;
%zrange = 1:100;


[score, n_mergers, n_splits] = EvalMetrics(@MetricsAllMatches, xrange, yrange, ...
    zrange, comp_human, comp90, comp94, comp95, comp96, ...
    comp97, comp98, comp99, comp995);

% Compare other human
[score_h, n_mergers_h, n_splits_h] = EvalMetrics(@MetricsAllMatches, xrange, yrange, ...
    zrange, comp_human, comp_human0724);


figure;
subplot(1,2,1);
plot(thresh,score); hold on;
plot([thresh(1) thresh(end)], [score_h score_h], '--'); hold off;
legend('Viren5', 'mbangert 7-24'); legend boxoff;
title('Viren5 vs. tkelling 7-07');
ylabel('Metric');
xlabel('Threshold');
%set(gca,'XTickLabel', thresh);
ax = axis; ax(3) = 0; ax(4) = 1.0; axis(ax);

subplot(1,2,2);
%plot(1:length(thresh), n_mergers, 1:length(thresh), n_splits);
plot(thresh, n_mergers, thresh, n_splits); hold on;
plot([thresh(1) thresh(end)], [n_mergers_h n_mergers_h], 'b--'); 
plot([thresh(1) thresh(end)], [n_splits_h n_splits_h], 'g--'); hold off;
legend('# Mergers', '# Splits', 'human mergers', 'human splits'); legend boxoff;
title(sprintf('%d human-labeled components', length(unique(comp_human))));
xlabel('Threshold');
%set(gca,'XTickLabel', thresh);
ax = axis; ax(3) = 0; axis(ax);