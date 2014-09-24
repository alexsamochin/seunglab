% test_perf - Compares network component labeling to
%   human labeled data
%
% JFM   4/26/2006
% Rev:  4/27/2006

fprintf('Loading...\n');
load ~jfmurray/project/semdata/retina1/retina1_srini5
%load retina1_srini3
load ~jfmurray/project/semdata/retina1/retina1

% Set the range that we're looking at
yrange = 120:200; % Labeled yx range
xrange = 30:70;
zrange = 5:20;
human = 1;

% 20:170,65:115,50:85
%xrange = 65:115;  % Components that should be merged
%yrange = 20:170;
%zrange = 50:85;
%human = 0;

% Full set
%xrange = 1:size(retina1.im,2);
%yrange = 1:size(retina1.im,1);
%zrange = 1:size(retina1.im,3);
%human = 0;

% Find the labeled part
im = retina1.im(yrange,xrange,zrange);

if human
    human_comp_yx = retina1.components_yx(yrange,xrange,zrange);
end

yl = y(yrange,xrange,zrange,:);

fprintf('Labeling components...\n');

% Find the seed components
%seed_comp = connLabelSymmBW(conn);
seed_comp = pottsSeg(yl,0);

fprintf('Running Potts model...\n');
% Enhance the seed
%comp = seed_comp;
comp = pottsSeg(yl,500,seed_comp);  % Seed with the connLabel1Pass output
%comp = pottsSeg(yl,200,seed_comp);  % Seed with the connLabel1Pass output

if human
    fprintf('Running metric...\n');
    [voxel_score, voxel_score2] = MetricsComponent(human_comp_yx, comp, 1);

%    save retina1_srini5_labeled10   im human_comp_yx threshold yl conn seed_comp comp voxel_score voxel_score2
else
%    save retina1_srini5_labeled10  im threshold yl conn seed_comp comp
end
