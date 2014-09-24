function [inout,x,y,z,dist3] = mkInOut3D(cntrs3)
% makes a consensus inout from 3 orthogonal tracings

sampFact = 4;

% find bounding box (x,y)
mn = floor(min(cntrs3(:,1:3)));
mx = ceil(max(cntrs3(:,1:3)));
x = mn(1):1/sampFact:mx(1);
y = mn(2):1/sampFact:mx(2);
z = mn(3):1/sampFact:mx(3);
[xm ym zm] = meshgrid(x,y,z);
dist3 = zeros([size(xm) 3],'single');		% storage for components

% generate interpolated inout from xy contours
cntrPts = cntrs3(:,4)==3; xyorder = [1 2 3];
[inout,xx,yy,zz]=mkInOut(cntrs3(cntrPts,xyorder),sampFact);
d1 = bwdist(inout)-bwdist(~inout);
dist3(y>=yy(1)&y<=yy(end),x>=xx(1)&x<=xx(end),z>=zz(1)&z<=zz(end),1) = d1;

% generate interpolated inout from yz contours
cntrPts = cntrs3(:,4)==1; xyorder = [2 3 1];
[inout,xx,yy,zz]=mkInOut(cntrs3(cntrPts,xyorder),sampFact);
inout = permute(inout,[2 3 1]);
d2 = bwdist(inout)-bwdist(~inout);
dist3(y>=xx(1)&y<=xx(end),x>=zz(1)&x<=zz(end),z>=yy(1)&z<=yy(end),2) = d2;

% generate interpolated inout from yz contours
cntrPts = cntrs3(:,4)==2; xyorder = [1 3 2];
[inout,xx,yy,zz]=mkInOut(cntrs3(cntrPts,xyorder),sampFact);
inout = permute(inout,[3 2 1]);
d3 = bwdist(inout)-bwdist(~inout);
dist3(y>=zz(1)&y<=zz(end),x>=xx(1)&x<=xx(end),z>=yy(1)&z<=yy(end),3) = d3;

d=dist3; dist3(dist3==Inf)=0;
inout = sum(dist3,4)<0;

return




function [inout,x,y,z] = mkInOut(contrs,sampFact)
% contrs set of contours (x y z), sampFact sampling factor

z = unique(contrs(:,3))'; z = z(~isnan(z));
mn = floor(min(contrs(:,1:2)));
mx = ceil(max(contrs(:,1:2)));
x = mn(1):1/sampFact:mx(1);
y = mn(2):1/sampFact:mx(2);
[xx yy] = meshgrid(x,y);
inout = zeros([size(xx) length(z)],'single');

% remove NaNs from the z plane
zbnd = find(isnan(contrs(:,3)));
contrs(zbnd,3) = contrs(zbnd-1,3);

for k=1:length(z),
	inout(:,:,k) = pointInPolygon(contrs(contrs(:,3)==z(k),1:2)',xx,yy);
end

dd = zeros(size(inout),'single');
for k=1:length(z),
	dd(:,:,k) = bwdist(inout(:,:,k))-bwdist(~inout(:,:,k));
end
[xxm yym zzm] = meshgrid(x,y,z); [xxmnew yymnew zzmnew] = meshgrid(x,y,z(1):1/sampFact:z(end));
inout = interp3(xxm,yym,zzm,dd,xxmnew,yymnew,zzmnew)<0;
z = z(1):1/sampFact:z(end);

return


function inout = pointInPolygon(segs,x,y)
% x,y test points.
% segs sequence of control points indicating a closed contour
% NaN's used to indicate boundaries of multiple closed contours

warning('off','MATLAB:divideByZero');

nCrossings = zeros(size(x),'single');
firstPt = 1;
for k = 1:size(segs,2),
	if ~isnan(segs(:,k)),
		x1=segs(1,k); y1=segs(2,k);
		if ~isnan(segs(:,k+1)),
			x2=segs(1,k+1); y2=segs(2,k+1);
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
