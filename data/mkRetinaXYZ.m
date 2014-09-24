load /net/data/viren/projects/em/data/retina/full_retina.mat im
boundingBox = [120, 200; 30, 70; 5, 19];
sampFact = 2;
y = 1:(1/sampFact):size(im,1); x = 1:(1/sampFact):size(im,2); z = 1:(1/sampFact):size(im,3);
cmpSz = [length(y) length(x) length(z)];

[cmp,xx,yy] = mkLabels('/net/data/viren/projects/em/data/retina/KLEE_first.mat',sampFact);
zz = 1:(1/sampFact):((size(cmp,3)-1)/sampFact+1);
components_yx = zeros(cmpSz,'single');
components_yx((y>=yy(1))&(y<=yy(end)),(x>=xx(1))&(x<=xx(end)),(z>=zz(1))&(z<=zz(end))) = ...
	cmp((yy>=y(1))&(yy<=y(end)),(xx>=x(1))&(xx<=x(end)),(zz>=z(1))&(zz<=z(end)));


[cmp,xx,zz] = mkLabels('/net/data/viren/projects/em/data/retina/KLEE_second.mat',sampFact);
yy = 1:(1/sampFact):((size(cmp,3)-1)/sampFact+1);
cmp = permute(cmp,[3 2 1]);
cmp(cmp==23) = 15;
components_zx = zeros(cmpSz,'single');
components_zx((y>=yy(1))&(y<=yy(end)),(x>=xx(1))&(x<=xx(end)),(z>=zz(1))&(z<=zz(end))) = ...
	cmp((yy>=y(1))&(yy<=y(end)),(xx>=x(1))&(xx<=x(end)),(zz>=z(1))&(zz<=z(end)));


[cmp,zz,yy] = mkLabels('/net/data/viren/projects/em/data/retina/KLEE_third.mat',sampFact);
xx = 1:(1/sampFact):((size(cmp,3)-1)/sampFact+1);
cmp = permute(cmp,[1 3 2]);
components_yz = zeros(cmpSz,'single');
components_yz((y>=yy(1))&(y<=yy(end)),(x>=xx(1))&(x<=xx(end)),(z>=zz(1))&(z<=zz(end))) = ...
	cmp((yy>=y(1))&(yy<=y(end)),(xx>=x(1))&(xx<=x(end)),(zz>=z(1))&(zz<=z(end)));

save /net/data/sturaga/EM/data/retina1/retina2x.mat im components_* sampFact boundingBox
