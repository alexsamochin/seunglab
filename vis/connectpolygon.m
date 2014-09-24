function [h1 h2 h12]=connectpolygon(poly1,poly2,varargin);
% draw two N-gons, and connect the corresponding vertices
% POLY1 and POLY2 are 3xN matrices. Each column is one vertex.
% lines connecting poly1 to poly2
h12=line([poly1(1,:);poly2(1,:)],[poly1(2,:);poly2(2,:)],[poly1(3,:); poly2(3,:)],varargin{:});
% draw poly1
h1=line(poly1(1,[1:end 1]),poly1(2,[1:end 1]),poly1(3,[1:end 1]),varargin{:}); 
% draw poly2
h2=line(poly2(1,[1:end 1]),poly2(2,[1:end 1]),poly2(3,[1:end 1]),varargin{:});
