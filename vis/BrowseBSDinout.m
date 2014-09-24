function BrowseBSDinout(f1,im,segTrue,varargin)
% BrowseBSD(fig,im,segTrue)
% BrowseBSD(fig,im,segTrue,inout1,inout2,...)
% BrowseBSD(fig,im,segTrue,inout1,inout2,...,{'title inout1','title inout2',...})


if isempty(f1),
	f1 = figure;
else,
	figure(f1)
	clf(f1)
end


alphaValue = 0.8;

set(f1,'KeyPressFcn',@updateFrame);
load component_colormap; color_map(1,:) = 0;
nFrames = length(im);
iFrame = 1;
iSeg = 1;
threshold = 0.5;

if isempty(varargin),
	nInout = 0;
elseif iscellstr(varargin{end}),
	inoutList = varargin(1:end-1);
	nInout = length(inoutList);
	legendStr = varargin{end};
else,
	inoutList = varargin;
	nInout = length(inoutList);
	for k = 1:nInout,
		legendStr{k} = 'connectivity graph';
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

	ax(1) = subplot(2,nInout+1,1);
	imagesc(squeeze(im{iFrame}))
	axis image
	title(['Image ' num2str(iFrame) ' (use up/dn keys to navigate)'])

	ax(2) = subplot(2,nInout+1,nInout+2);
	alphaMap = repmat(alphaValue*(segTrue{iFrame}{iSeg}>0),[1 1 3]);
	imagesc((1-alphaMap).*squeeze(im{iFrame})+alphaMap.*ind2rgb(int32(segTrue{iFrame}{iSeg}),color_map))
	axis image
	title(['Human segmentation ' num2str(iSeg) ' (use lt/rt keys to change)'])

	for iInout = 1:nInout,
		inout = inoutList{iInout};

		ax(2*iInout+1) = subplot(2,nInout+1,1+iInout);
		imagesc(ind2rgb(floor(1e3*mean(squeeze(inout{iFrame}),3)),gray(1e3)))
		axis image
		title(legendStr{iInout})

		ax(2*iInout+2) = subplot(2,nInout+1,nInout+2+iInout);
		conn = inout2conn(squeeze(inout{iFrame}),mknhood2d(1));
        segEst = connectedComponents(conn>threshold,mknhood2d(1));
        segEst = markerWatershed(conn,mknhood2d(1),segEst);
		alphaMap = repmat(alphaValue*(segEst>0),[1 1 3]);
		imagesc((1-alphaMap).*squeeze(im{iFrame})+alphaMap.*ind2rgb(int32(segEst),color_map))
		%imagesc(alphaValue*squeeze(im{iFrame})+(1-alphaValue)*ind2rgb(int32(segEst),color_map))
		axis image
		title(['Segmentation thresholded at ' num2str(threshold) ' (used +/- keys to change)'])

    end
    linkaxes(ax)

end

end
