function [object_list,comp] = ReadReconstruct(reconSeries,sections,xyBegin,xyEnd)

[y,x] = ndgrid(xyBegin(1):xyEnd(1),xyBegin(2):xyEnd(2));
compSz = [size(x) length(sections)];
comp = zeros([prod(size(x)) compSz(3)],'single');
inout = false(compSz(1:2));

object_list = [];

for isection = 1:length(sections)
    % Load the Reconstruct section file
    filename = sprintf('%s.%d', reconSeries, sections(isection));
    fprintf('Loading traces from %s\n', filename);

    % xml_parseany is from the XML Toolbox
    stack_xml = xml_parseany(fileread(filename));

    fprintf('Number of elements in xml.Transform:  %d\n', size(stack_xml.Transform,2) );

    % Section parameters
	if isfield(stack_xml.Transform{1,1},'Image'),
	    scale = 1 / str2double(stack_xml.Transform{1,1}.Image{1,1}.ATTRIBUTE.mag);
	end

    img_point_str = stack_xml.Transform{1,1}.Contour{1,1}.ATTRIBUTE.points;
    img_point = sscanf(img_point_str, '%f %f,', [2 inf]);
    img_height = img_point(2,3);
    img_width = img_point(1,3);

    clear point_str

    for i = 1:length(stack_xml.Transform)
		for j = 1:length(stack_xml.Transform{i}.Contour),

			name=stack_xml.Transform{i}.Contour{j}.ATTRIBUTE.name;

			% ignore objects named 'domain*'
			if(isempty(strfind(name,'domain')))

				obj_idx=find(strcmp(object_list, name));

				if( isempty(obj_idx) )	% new object
					object_list=[object_list; cellstr(name)];
					obj_idx=find(strcmp(object_list,name));
				end

				point_str = stack_xml.Transform{i}.Contour{j}.ATTRIBUTE.points;
				contour = sscanf(point_str, '%f %f,', [2 inf]);

				% Convert to image pixel scale (default is mag=0.00254)
				contour(1,:) = scale*contour(1,:);              % X coords
				contour(2,:) = img_height-scale*contour(2,:);   % Y coords
				
				% convert to in/out image
				idx1 = max(1,floor(min(contour(2,:)))):min(compSz(1),ceil(max(contour(2,:))));
				idx2 = max(1,floor(min(contour(1,:)))):min(compSz(2),ceil(max(contour(1,:))));
				inout(idx1,idx2) = pointInPolygon(contour,x(idx1,idx2),y(idx1,idx2));
				inIdx = find(inout);
				inout(inIdx) = false;

				% add to the stack
				comp(inIdx,isection) = obj_idx;


% 			else,
% 				keyboard
			end

        end
    end
end
comp = reshape(comp,compSz);


function inout = pointInPolygon(segs,x,y)
% x,y test points.
% segs sequence of control points indicating a closed contour
% NaN's used to indicate boundaries of multiple closed contours

warning('off','MATLAB:divideByZero');
segs = segs + 1e-10*randn(size(segs));

inout = false(size(x));
firstPt = 1;
for k = 1:size(segs,2),
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
	crossing = ((y<y1 & y>y2) | (y<y2 & y>y1)) & (x > (x1 + (y-y1)*(x1-x2)/(y1-y2)));
	inout = xor(inout,crossing);
end

warning('on','MATLAB:divideByZero');

return
