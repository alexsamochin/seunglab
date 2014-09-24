function comp = connLabelSymm1Pass(conn, verbose)
% Finds connected components according to the connectivity structure conn
% Usage:
% components = connLabelSymm1Pass(conn)
%
% Srini
% Rev:  5/2/2006 JFM

if ~exist('verbose')
    verbose = 0;
end

idx = 0;
for ii = -1:0, for jj = -1:(0-ii), for kk = -1:(0-min(ii,jj)),
idx = idx+1;
	if ii==-1,conn(1,:,:,idx)=0;end
	if jj==-1,conn(:,1,:,idx)=0;end
	if jj==1,conn(:,end,:,idx)=0;end
	if kk==-1,conn(:,:,1,idx)=0;end
	if kk==1,conn(:,:,end,idx)=0;end
end, end, end
conn(:,:,:,14) = 0;


% If the connectivity only has 13 dim then we need to make
% a symmetric connectivity 
% if size(conn,4) <= 14
%     fprintf('Connectivity is not symmetric, running mkSymmConn.\n');
%     conn = mkSymmConn(conn);
% end

% ---- Make sure there are no connections outside
% the volume (See notes 4/12/2006)
[sy, sx, sz, sc] = size(conn);
% conn(:,:,1, 1:9) = 0;
% conn(sy,:,:, [3,6,9, 12,15,18, 21,24,27]) = 0;
% conn(:,sx,:, [7,8,9, 16,17,18, 25,26,27]) = 0;
% conn(:,:,sz, 19:27) = 0;
% conn(1,:,:,  [1,4,7, 10,13,16, 19,22,25]) = 0;
% conn(:,1,:,  [1,2,3, 10,11,12, 19,20,21]) = 0;

connAll = sum(mkSymmConn(conn),4);
comp = zeros([size(conn,1) size(conn,2) size(conn,3)]);
cmpMax = 0;

% Making this much bigger (e.g. 10^6) slows down the function a lot, 
% but why?
nCmpGuess = 500000; % 200;
equiv = sparse(nCmpGuess,nCmpGuess);	% 'pre-allocate'


% TODO should be able to speed up 2-3 times.
%	- only look at connections behind you (ones in front aren't labeled yet!) [use unsymmetrized conn]
%	- only look at voxels that are connected at all [use symmetrized conn]

% ---- 1 pass through matrix, making label estimates, and
% recording label equivalences
for i = 2:sy-1 % Y
%for k = 2:sz-1 % Z
%     if verbose
%         fprintf('%3d  %8d ', k, cmpMax);
%         if( mod(k,4)==0 ) 
%             fprintf('\n'); 
%         end
%     end
        
	for j = 2:sx-1  % X 
    %for i = 2:sy-1 % Y
		for k = 2:sz-1 % Z
        %for j = 2:sx-1 % X

            % Create n-connected components
            if connAll(i,j,k) >= 1
                                
                % Find the component labels of connected neighbors
				nLabels = comp(i-1:i+1, j-1:j+1, k-1:k+1);
 
                % AND this together with the conn at this location
                cl = reshape(conn(i,j,k,:), [3,3,3]);
                nLabels = nLabels(cl);

                cmpNeighbors = unique(nLabels);
    
                % If this voxel and its neighbors aren't already in a 
                % component, create a new one. 
                if isempty(cmpNeighbors) %|| max(cmpNeighbors) == 0
                    cmpMax = cmpMax + 1;
        			equiv(cmpMax,cmpMax) = 1;
    				cmp = cmpMax;
                else
%                     % Use the smallest component # > 0
%                     if(cmpNeighbors(1) == 0)
%                         cmpNeighbors(1) = [];
%                     end
                    cmp = cmpNeighbors(1);
cmpNeighbors(1)
                end
                
                % If there are any labeled neighbors, create the
                % equivalences
                for nn = 2:length(cmpNeighbors)
                    % record equivalence of all these components, any
                    % component already here is also n-connected.                                       
                    equiv(cmp,cmpNeighbors(nn)) = 1;
                    equiv(cmpNeighbors(nn),cmp) = 1;                   
                end
            
    			% mark label
        		comp(i,j,k) = cmp;
            end % End n-connectedness
						
        end % End Z
    end % End X
    
%     % Figures for debugging
%     
%     figure(2); clf;
%     subplot(1,2,1);
%     img = connAll(:,:,k); %(i,:,:);
%     img2 = reshape(img, size(img,1), size(img,2) );;
%     imagesc(img2);
% 
%     subplot(1,2,2);
%     img = comp(:,:,k); %(i,:,:);
%     img2 = reshape(img, size(img,1), size(img,2) );;
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

% This part is very time consuming with many components
if verbose
    fprintf('\nLabeling equivalences\n');
end


% label the equivalent components
comp(comp>0) = blocks(comp(comp>0));

if verbose
    fprintf('\n');
end
