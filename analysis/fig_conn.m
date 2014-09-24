% fig_conn: plot metric results for a connectivity output
function [scores,  n_mergers, n_splits]=fig_conn(n, bb, input, im_conn, human_conn, human2_conn) 

% generate bounding box based on network valid convolutions
bb_ntwk=bb_to_bb_ntwk(n, input, bb);
bb_img=bb_ntwk_to_bb(n, input, bb_ntwk); % must do this because bb_ntwk might clip at borders

% get aligned labels
label_coords=in2out_coords(n, bb_ntwk(:,1), bb_ntwk(:,2)); 

% crop all labels 
im_conn=im_conn(label_coords{1}, label_coords{2},label_coords{3},:);
human_conn=human_conn(label_coords{1}, label_coords{2},label_coords{3},:);
human2_conn=human2_conn(label_coords{1}, label_coords{2},label_coords{3},:);
size(im_conn)

% generate components at various threshold levels
thresholds = [0.95 0.96];
for thresh=1:length(thresholds)
	thresholds(thresh)
	comp{thresh}=Conn3Label1Pass(im_conn>thresholds(thresh));
end

% segment human data
comp_human=Conn3Label1Pass(human_conn);
comp_human2=Conn3Label1Pass(human2_conn);

% score these segmentations
scores=[]; n_mergers=[]; n_splits=[];
for thresh=1:length(thresholds)
	[score, n_merger, n_split] = EvalMetrics(@MetricsAllMatches, 1:size(im_conn,1), 1:size(im_conn,2), 1:size(im_conn,3), comp_human, comp{thresh});
  	scores=[scores; score];
  	n_mergers=[n_mergers; n_merger];
  	n_splits=[n_splits; n_split];
end

% score other human
[score_h, n_mergers_h, n_splits_h] = EvalMetrics(@MetricsAllMatches, 1:size(im_conn,1), 1:size(im_conn,2), 1:size(im_conn,3), comp_human, comp_human2);


figure;
subplot(1,2,1);
plot(thresholds,scores); hold on;
plot([thresholds(1) thresholds(end)], [score_h score_h], '--'); hold off;
legend('Viren', 'mbangert 7-24'); legend boxoff;
title('Viren vs. tkelling 7-07');
ylabel('Metric');
xlabel('Threshold');
%set(gca,'XTickLabel', thresh);
ax = axis; ax(3) = 0; ax(4) = 1.0; axis(ax);

subplot(1,2,2);
%plot(1:length(thresh), n_mergers, 1:length(thresh), n_splits);
plot(thresholds, n_mergers, thresh, n_splits); hold on;
plot([thresholds(1) thresholds(end)], [n_mergers_h n_mergers_h], 'b--'); 
plot([thresholds(1) thresholds(end)], [n_splits_h n_splits_h], 'g--'); hold off;
legend('# Mergers', '# Splits', 'human mergers', 'human splits'); legend boxoff;
title(sprintf('%d human-labeled components', length(unique(comp_human))));
xlabel('Threshold');
%set(gca,'XTickLabel', thresh);
ax = axis; ax(3) = 0; axis(ax);