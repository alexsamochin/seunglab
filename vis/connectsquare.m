function connectsquare(xlim1,ylim1,z1,xlim2,ylim2,z2,varargin);
% draw two squares in two z-planes and connect their vertices
% xlim1 and ylim1 are x and y limits of square 1, and z1 is the z-plane
% similar for other arguments
poly1=[xlim1(1) xlim1(1) xlim1(2) xlim1(2); ylim1(1) ylim1(2) ylim1(2) ylim1(1); z1 z1 z1 z1];
poly2=[xlim2(1) xlim2(1) xlim2(2) xlim2(2); ylim2(1) ylim2(2) ylim2(2) ylim2(1); z2 z2 z2 z2];
connectpolygon(poly1,poly2,varargin{:});
