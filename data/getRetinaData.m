function [imAll,labelsAll] = getRetinaData(patchSz,nTimes)

% load data and labels
%load ~viren/datasets/e324/mb_label.mat im components
addpath /local_data/jfmurray/project/vision/sem/matlab/
%load /local_data/jfmurray/project/semdata/viren/e324/aw_label2x_mergerfix.mat im components mask
%load aw_label2x_mergerfix.mat im components mask
load retina_yx_simple im components
%im=permute(im,[2 1 3]); components=permute(components,[2 1 3 4]); mask=permute(mask,[2 1 3]);
labelsAll = single(mkConnLabelIntra(components)); labelsAll = labelsAll(:,:,:,1:13);
