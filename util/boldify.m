function[] = boldify(varargin)
%BOLDIFY	Make lines and text bold for standard viewgraph style.
%		BOLDIFY boldifies the lines and text of the current figure.
%		BOLDIFY(H) applies to the graphics handle H.
%
%		BOLDIFY(X,Y) specifies an X by Y inch graph of the current
%		figure.  If text labels have their 'UserData' data property
%		set to 'slope = ...', then the 'Rotation' property is set to
%		account for changes in the graph's aspect ratio.  The
%		default is MATLAB's default.

%		S. T. Smith

% The name of this function does not represent an endorsement by the author
% of the egregious grammatical trend of verbing nouns.

% *** UNCLASSIFIED ***
% $Id: boldify.m,v 1.6 2002/12/16 15:15:37 sturaga Exp $

showHiddenHandles = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')

fontSize = 14;
if nargin == 0
  h = gcf;
elseif nargin == 1
  h = varargin{1};
elseif nargin == 2
  if ishandle(varargin{1})
    h = varargin{1};
    fontSize = varargin{2};
  else
    h = gcf;
    sizFig = [varargin{1} varargin{2}]; % User specified graph size
  end
end
fontSize = max(fontSize,2);

if ~ishandle(h)
  set(0,'ShowHiddenHandles',showHiddenHandles)
  error('Invalid handle.')
elseif h == 0 % Root handle
  set(0,'ShowHiddenHandles',showHiddenHandles)
  return
end

% Get figure handle
hFig = h;
while ~strcmp(get(hFig,'Type'),'figure') & ~isempty(hFig)
  hFig = get(hFig,'Parent');
end

% Set the paper position of the current figure
oldUnits = get(hFig,'PaperUnits');
set(hFig,'PaperPosition','default','PaperUnits','inches');
sizPaper = get(hFig,'PaperSize');

if ~exist('sizFig','var')
  sizFig = get(hFig,'PaperPosition');
  sizFig = sizFig(3:4); % Figure size (X" x Y") on paper.
end

newSizFig = [(sizPaper(1)-sizFig(1))/2 (sizPaper(2)-sizFig(2))/2 sizFig(1) sizFig(2)];
set(hFig,'PaperPosition',newSizFig,'PaperUnits',oldUnits);

% Modify text boxes
hTexts = [findobj(h,'Type','text'); findobj(h,'Type','uicontrol',...
					    'Style','text')];
if ~isempty(hTexts)
  oldSizes = cellcat(get(hTexts,'FontSize'));
  %newSizes = max(oldSizes,(6/7)*fontSize);
  newSizes = (6/7)*fontSize*ones(size(oldSizes));
  for ii = 1:length(hTexts)
    hText = hTexts(ii);
    set(hText,'FontSize',newSizes(ii),'FontWeight','bold')
    ud = get(hText,'UserData');
    if ischar(ud) & strncmp(ud,'slope = ',8)
      slope = sscanf(ud,'slope = %g');
      idxAxes = find(hAxes == get(hText,'Parent'));
      if ~isempty(idxAxes)
	slope = slope * (sizFig(2)/sizFig(1)) / ratio(idxAxes);
	set(hText,'Rotation',atan(slope)/pi*180);
      end
    end
  end
end

% Modify axes
hAxes = findobj(h,'Type','axes');
nAxes = length(hAxes);
if nAxes
  oldUnits = cellcat(get(hAxes,'Units'));
  set(hAxes,'Units','normalized','FontSize',fontSize,'FontWeight','bold',...
	    'LineWidth',1)
  posAxes = cellcat(get(hAxes,'Position')); % Axes Position (normalized)
  sizAxes = posAxes(:,3:4);
  ratio = sizAxes(:,2) ./ sizAxes(:,1);

  [trash,jj] = max(sizAxes,[],2);
  [trash,kk] = min(sizAxes,[],2);

  for ii = 1:nAxes
    j = jj(ii);
    k = kk(ii);
    if sizAxes(ii,k) > 1/2
      tickLength = [1/8 5/16] / (sizAxes(ii,j) * sizFig(j)); % Gives 1/8" ticks
    else
      tickLength = [3/32 15/64] / (sizAxes(ii,j) * sizFig(j)); % Gives 3/32" ticks
    end
    set(hAxes(ii),'TickLength',tickLength,'Units',oldUnits(ii,:));
  end

  % Modify titles and axes labels
  hTitles = cellcat(get(hAxes,'Title'));
  set(hTitles,'FontSize',(8/7)*fontSize,'FontWeight','bold')

  hXLabels = cellcat(get(hAxes,'XLabel'));
  set(hXLabels,'FontSize',fontSize,'FontWeight','bold',...
	       'VerticalAlignment','top')

  hYLabels = cellcat(get(hAxes,'YLabel'));
  set(hYLabels,'FontSize',fontSize,'FontWeight','bold',...
	       'VerticalAlignment','baseline')

  hZLabels = cellcat(get(hAxes,'ZLabel'));
  set(hZLabels,'FontSize',fontSize,'FontWeight','bold',...
	       'VerticalAlignment','baseline')
end

% Modify lines
hLines = findobj(h,'Type','line');
set(hLines,'LineWidth',2)

set(0,'ShowHiddenHandles',showHiddenHandles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[y] = cellcat(x)

if isempty(x) | ~iscell(x)
  y = x;
else
  y = vertcat(x{:});
end
