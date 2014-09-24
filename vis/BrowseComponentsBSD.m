function browseSeg2d(f1,varargin)

if isempty(f1),
	f1 = figure;
else,
	figure(f1)
	clf(f1)
end

if ~exist('alphaValue','var') || isempty(alphaValue),
	alphaValue = 0.4;
end

set(f1,'KeyPressFcn',@updateFrame);
load component_colormap; color_map(1,:) = 0;
nFrames = length(im);
iFrame = 1;
iSeg = 1;
threshold = 0.5;

if iscellstr(varargin{end}),
	imList = varargin(1:end-1);
	nIm = length(imList);
	legendStr = varargin{end};
else,
	imList = varargin;
	nIm = length(imList);
	for k = 1:nIm,
		legendStr{k} = '';
	end
end
plotFrame;

function updateFrame(src,evnt)

switch evnt.Character,
case {'+','='},
	threshold = min(1,threshold+.05);
case {'-','_'},
	threshold = max(0,threshold-.05);
case '1',
	alphaValue = min(1,alphaValue+.05);
case '2',
	alphaValue = max(0,alphaValue-.05);
case 'R',
	color_map = single(rand(1e6,3));
case 'J',
	jumpToFrame = inputdlg(['Jump to frame [1-' num2str(nFrames) ']']);
	jumpToFrame = max(1,min(nFrames,str2num(jumpToFrame{1})));
	if jumpToFrame ~= iFrame,
		iFrame = jumpToFrame;
		iSeg = 1;
	end
end

switch evnt.Key,
case 'uparrow',
	iFrame = min(iFrame+1,nFrames);
	iSeg = 1;
case 'downarrow',
	iFrame = max(iFrame-1,1);
	iSeg = 1;
case 'pageup',
	iFrame = min(iFrame+10,nFrames);
	iSeg = 1;
case 'pagedown',
	iFrame = max(iFrame-10,1);
	iSeg = 1;
case 'leftarrow',
	iSeg = max(1,iSeg-1);
case 'rightarrow',
	iSeg = min(length(segTrue{iFrame}),iSeg+1);
end

plotFrame

end

function plotFrame

	figure(f1)

	subplot(2,nConn+1,1)
	imagesc(squeeze(im{iFrame}))
	axis image
	title(['Image ' num2str(iFrame) ' (use up/dn keys to navigate)'])

	subplot(2,nConn+1,nConn+2)
	imagesc(alphaValue*squeeze(im{iFrame})+(1-alphaValue)*ind2rgb(int32(segTrue{iFrame}{iSeg})+int32(segTrue{iFrame}{iSeg}~=0),color_map))
	axis image
	title(['Human segmentation ' num2str(iSeg) ' (use lt/rt keys to change)'])

	for iConn = 1:nConn,
		conn = connList{iConn};

		subplot(2,nConn+1,1+iConn)
		imagesc(ind2rgb(floor(1e3*mean(squeeze(conn{iFrame}),3)),gray(1e3)))
		axis image
		title(legendStr{iConn})

		subplot(2,nConn+1,nConn+2+iConn)
		segEst = connectedComponents(conn{iFrame}>threshold,mknhood2d(1));
		alphaMap = repmat(alphaValue*(segEst==0),[1 1 3]);
		imagesc(alphaMap.*squeeze(im{iFrame})+(1-alphaMap).*ind2rgb(int32(segEst)+int32(segEst~=0),color_map))
		%imagesc(alphaValue*squeeze(im{iFrame})+(1-alphaValue)*ind2rgb(int32(segEst),color_map))
		axis image
		title(['Segmentation thresholded at ' num2str(threshold) ' (used +/- keys to change)'])

	end

end

end
