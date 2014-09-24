function [mins, maxs, labels] = ComponentBoundingBox(comp, varargin)
% [mins, maxs, labels] = ComponentBoundingBox(comp)
%
% Finds the bounding box of all the components in a stack
%
%   comp - Components 
%
% Returns:
%   mins - [ y x z ] min coord for components (n_comp x 3)
%   maxs - [ y x z ] max coord for components (n_comp x 3)
%   labels - Component numbers
%
% JFM   7/21/2006
% Rev:  9/5/2006
% V. Jain Rev: 2/26/07

if(nargin==1)
	labels = unique(comp);
else
	labels = varargin{1};
end

for i=1:length(labels)
	if(labels(i)>0)
		label_hash{labels(i)}=i;
	end
end

% if labels(1) = 0;
%     labels = labels(2:end);
% end

mins = ones(length(labels), 3);
maxs = zeros(length(labels), 3);

sz = size(comp);
mins = mins * max(sz);

for z = 1:sz(3)
    %fprintf('z = %d\n', z);
    for y = 1:sz(1)
        %fprintf('  y = %d\n', y);
        for x = 1:sz(2)
            c = comp(y, x, z);
            
            if c == 0 
                continue;
            end
            
	 	    ind = label_hash{c};
            mins(ind, :)=min([y,x,z], mins(ind,:));
			maxs(ind, :)=max([y,x,z], maxs(ind,:));            
        end
    end
end

% !! Bug, comp 0 size not reported correctly!...lazy!!
if labels(1) == 0
    mins(1,:) = [ 1 1 1 ];
    maxs(1,:) = size(comp);
end

            