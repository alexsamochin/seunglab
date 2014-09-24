function comp = Conn3Label1Pass(conn, verbose)
% comp = Conn3Label1Pass(conn, verbose)
%
% Finds connected components according to the connectivity structure conn
% Usage:
%
% JFM   8/14/2006 (from connLabelIntra1Pass.m, Srini)
% Rev:  10/14/2006 JFM

if ~exist('verbose','var')
    verbose = 0;
end

if verbose
    fprintf('Conn3Label1Pass\n');
end

% ---- Make sure there are no connections outside the volume
conn(end,:,:,1) = 0;
conn(:,end,:,2) = 0;
conn(:,:,end,3) = 0;

%conn(:,:,:,14) = 0;
%connAll = sum(conn,4);
connAll = sum(MakeSymmConn3(conn),4);
comp = zeros([size(conn,1) size(conn,2) size(conn,3)],'single');
cmpMax = 0;

% Making this much bigger (e.g. 10^6) slows down the function a lot, 
% but why?
nCmpGuess = 100000; % 200;
equiv = sparse([],[],[],nCmpGuess,nCmpGuess,10^6);	% Pre-allocate


% ---- 1 pass through matrix, making label estimates, and
% recording label equivalences
%for i = 2:size(conn,1) % Y

% Find first non-zero section
for sk = 1:size(conn,3)-1
    sec = conn(:,:,sk,:);
    if any(sec(:) ~= 0)
        break;
    end
end

sk = sk + 1;

for k = sk:size(conn,3)-1 % Z
    if verbose
        fprintf('%3d  %8d ', k, cmpMax);
        if( mod(k,4)==0 ) 
            fprintf('\n'); 
        end
    end
        
	for j = 2:size(conn,2)-1  % X 
        %for k = 2:size(conn,3) % Z
        for i = 2:size(conn,1)-1 % Y
		

            % Create n-connected components
            if connAll(i,j,k) >= 1
                
                % Find the component labels of connected neighbors
				nLabels = 0; idx = 0;

                if conn(i,j,k,1) == 1  % Up
                    nLabels(end+1) = comp(i-1,j,k);
                end
                if conn(i,j,k,2) == 1  % Left
                    nLabels(end+1) = comp(i,j-1,k);
                end
                if conn(i,j,k,3) == 1  % Up-z
                    nLabels(end+1) = comp(i,j,k-1);
                end
                
                cmpNeighbors = unique(nLabels);
    
                % If this voxel and its neighbors aren't already in a 
                % component, create a new one. 
                if max(cmpNeighbors) == 0
                    cmpMax = cmpMax + 1;
        			equiv(cmpMax,cmpMax) = 1;
    				cmp = cmpMax;
                else
                    % Use the smallest component # > 0
                    if(cmpNeighbors(1) == 0)
                        cmpNeighbors(1) = [];
                    end
                    cmp = cmpNeighbors(1);
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
    
    % Figures for debugging
%     
%     figure(2); clf;
%     subplot(1,2,1);
%     img = connAll(:,:,k);
%     img2 = reshape(img, size(img,1), size(img,2) );
%     imagesc(img2);
% 
%     subplot(1,2,2);
%     img = comp(:,:,k);
%     img2 = reshape(img, size(img,1), size(img,2) );
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
