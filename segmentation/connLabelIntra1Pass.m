function comp = connLabelIntra1Pass(conn, verbose)
% Finds connected components according to the connectivity structure conn
% Usage:
% components = connLabelIntra1Pass(conn)
%
% Srini
% Rev:  5/4/2006 JFM

if ~exist('verbose')
    verbose = 0;
end

if verbose
    fprintf('connLabelIntra1Pass\n');
end

% ---- Make sure there are no connections outside
% the volume
idx = 0;
for ii = -1:0,
	for jj = -1:(0-ii),
		for kk = -1:(0-min(ii,jj)),
			idx = idx+1;
			if ii==-1,conn(1,:,:,idx)=0;end
			if jj==-1,conn(:,1,:,idx)=0;end
			if jj==1,conn(:,end,:,idx)=0;end
			if kk==-1,conn(:,:,1,idx)=0;end
			if kk==1,conn(:,:,end,idx)=0;end
		end
	end
end
conn(:,:,:,14) = 0;
connAll = sum(mkSymmConn(conn),4);
comp = zeros([size(conn,1) size(conn,2) size(conn,3)]);
cmpMax = 0;

% Making this much bigger (e.g. 10^6) slows down the function a lot, 
% but why?
nCmpGuess = 100000; % 200;
equiv = sparse(nCmpGuess,nCmpGuess);	% 'pre-allocate'



% ---- 1 pass through matrix, making label estimates, and
% recording label equivalences
for i = 1:size(conn,1) % Y
    if verbose
        fprintf('%3d  %8d ', i, cmpMax);
        if( mod(i,4)==0 ) 
            fprintf('\n'); 
        end
    end
        
	for j = 1:size(conn,2)  % X 
		for k = 1:size(conn,3) % Z

            % Create n-connected components
            if connAll(i,j,k) >= 1
                
                % Find the component labels of connected neighbors
				nLabels = []; idx = 0;
				for ii = -1:0
					for jj = -1:(0-ii)
						for kk = -1:(0-min(ii,jj))
							idx = idx+1;
							if conn(i,j,k,idx)
                                nLabels(end+1) = comp(i+ii,j+jj,k+kk); 
                            end
						end
					end
                end

                % If this voxel and its neighbors aren't already in a 
                % component, create a new one. 
                if isempty(nLabels),
                    cmpMax = cmpMax + 1;
        			equiv(cmpMax,cmpMax) = 1;
    				cmp = cmpMax;
                else
                	cmpNeighbors = unique(nLabels);
%                     % Use the smallest component # > 0
%                     if(cmpNeighbors(1) == 0)
%                         cmpNeighbors(1) = [];
%                     end
                    cmp = cmpNeighbors(1);
					% If there are any labeled neighbors, create the
					% equivalences
					for nn = 2:length(cmpNeighbors)
						% record equivalence of all these components, any
						% component already here is also n-connected.                                       
						equiv(cmp,cmpNeighbors(nn)) = 1;
						equiv(cmpNeighbors(nn),cmp) = 1;                   
					end
                end
                
            
    			% mark label
        		comp(i,j,k) = cmp;
            end % End n-connectedness

        end % End Z
    end % End X
    
    % Figures for debugging
%     
%     figure(2); clf;
%     subplot(1,2,1);
%     img = connAll(i,:,:);
%     img2 = reshape(img, size(img,2), size(img,3) );;
%     imagesc(img2);
% 
%     subplot(1,2,2);
%     img = comp(i,:,:);
%     img2 = reshape(img, size(img,2), size(img,3) );;
%     imagesc(img2);

    %keyboard;
    %pause;
end % End Y

% ---- Find the equivalence tables

% Make square, size (cmpMax x cmpMax)
equiv = equiv(1:cmpMax,1:cmpMax);

% resolve equivalences
% copied from http://web.ccr.jussieu.fr/ccr/Documentation/Calcul/matlab5v11/docs/ftp.mathworks.com/pub/mathworks/toolbox/images/cclabel.m
[p,p,r,r] = dmperm(equiv);
sizes = diff(r);				% Sizes of components, in vertices.
numObjs = length(sizes);		% Number of components.
% Now compute an array "blocks" that maps vertices of equiv to components;
% First, it will map vertices of equiv(p,p) to components...
blocks = zeros(1,cmpMax);
blocks(r(1:numObjs)) = ones(1,numObjs);
blocks = cumsum(blocks);
% Second, permute it so it maps vertices of equiv to components.
blocks(p) = blocks;


% ---- Relabel the equivalent sections
if verbose
    fprintf('\nLabeling equivalences\n');
end

% label the equivalent components
comp(comp>0) = blocks(comp(comp>0));
