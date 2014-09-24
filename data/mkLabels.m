function [components,x,y] = mkLabels(labels,sampFact)

%load(KLEEfileName);
%labels = ssem_savedWork; clear ssem_savedWork;

% find bounding box (x,y)
% count # of objects
% count # of sections
num_sections=size(labels,2);
num_objects=0; mn=[Inf Inf]; mx=-[Inf Inf];
for section=1:num_sections,
	nobj = size(labels(section).AllCoords,2);
	num_objects=max(num_objects,nobj);
	for obj_idx=1:nobj,
		if ~isempty(labels(section).AllCoords(obj_idx).chord)
			mn = min([mn;labels(section).AllCoords(obj_idx).chord]);
			mx = max([mx;labels(section).AllCoords(obj_idx).chord]);
		end
	end
end

x = floor(mn(1)):1/sampFact:ceil(mx(1));
y = floor(mn(2)):1/sampFact:ceil(mx(2));
[xx,yy] = meshgrid(x,y);	% test points
imSz = [size(xx) num_sections];
components = zeros(imSz,'single');		% storage for components


for section=1:min(num_sections,size(labels,2))
	for obj_idx=1:size(labels(section).AllCoords,2)
		disp(['section ' num2str(section) ': obj ' num2str(obj_idx)]);
		if(~isempty(labels(section).AllCoords(obj_idx).chord))
			inout = pointInPolygon(labels(section).AllCoords(obj_idx).chord',xx,yy);
			components(:,:,section) = components(:,:,section) + obj_idx*inout;
imagesc(x,y,components(:,:,section)),title(num2str(section)),drawnow
		end
	end
end

if sampFact>1, components = interpZ(components,sampFact); end

return


function inout = pointInPolygon(segs,x,y)
% x,y test points.
% segs sequence of control points indicating a closed contour
% NaN's used to indicate boundaries of multiple closed contours

segs=segs+(1e-6*randn(size(segs))); % in case two point are on top of each other

warning('off','MATLAB:divideByZero');

nCrossings = zeros(size(x),'single');
firstPt = 1;
for k = 1:size(segs,2),
	if ~isnan(segs(:,k)),
		x1=segs(1,k); y1=segs(2,k);
		if( k+1<=size(segs,2))
			if(~isnan(segs(:,k+1)))
				x2=segs(1,k+1); y2=segs(2,k+1);
			else
				x2=segs(1,firstPt); y2=segs(2,firstPt);
			end
		else,
			x2=segs(1,firstPt); y2=segs(2,firstPt);
		end
	else,
		firstPt = k+1;
		continue;
	end
	crossing = ((y<y1 & y>y2) | (y<y2 & y>y1)) & (x > (x1 + (y-y1)*(x1-x2)/(y1-y2)));
	nCrossings = nCrossings + crossing;
end
inout = mod(nCrossings,2)>0;

warning('on','MATLAB:divideByZero');

return
