function [comp,numObjs] = connectedComponentsBlocks(G,nhood,verbose)
% Finds connected components according to the connectivity structure G
% Usage:
% components = connectedComponentsParallel(G,nhood)

%% developed and maintained by Srinivas C. Turaga <sturaga@mit.edu>
%% do not distribute without permission.

if ~exist('nhood') || isempty(nhood),
	nhood = [-1 0 0; 0 -1 0; 0 0 -1];
end

if ~exist('verbose')
    verbose = 0;
end
if verbose
    fprintf('parallel connected components\n');
end

sz = size(G(:,:,:,1));
%log_message([], num2str(sz));

G = logical(G);
blksz = [250 250 250];

% initialize storage
comp = zeros(sz,'int32');
cmpMax = 0;

%% connect components of the blocks
% -------------- Begin Parallel -----------------
for iblk = 1:blksz(1):sz(1),
	idxi = iblk:min(sz(1),iblk+blksz(1)-1);
	for jblk = 1:blksz(2):sz(2),
		idxj = jblk:min(sz(2),jblk+blksz(2)-1);
		for kblk = 1:blksz(3):sz(3),
			idxk = kblk:min(sz(3),kblk+blksz(3)-1);

			[cmpblk,nObj] = connectedComponents(G(idxi,idxj,idxk,:),nhood,verbose);
			cmpin = cmpblk>0;
			cmpblk(cmpin) = cmpblk(cmpin) + cmpMax;
			comp(idxi,idxj,idxk) = cmpblk;
			cmpMax = cmpMax + nObj;

		end
	end
end
% -------------- End Parallel -----------------

%% fix up the block boundaries
equiv = sparse(1:cmpMax,1:cmpMax,1,cmpMax,cmpMax,1e6);	% 'pre-allocate'
for iblk = 1:blksz(1):sz(1),
	for jblk = 1:blksz(2):sz(2),
		for kblk = 1:blksz(3):sz(3),

			% look at all the "faces" of this block
			% top face
			for i = iblk+[0:(1+min(nhood(:,1)))],
				for j = jblk:min(sz(2),jblk+blksz(2)-1),
					for k = kblk:min(sz(3),kblk+blksz(3)-1),
						findlinks;
					end
				end
			end
			% front face
			for j = jblk+[0:(1+min(nhood(:,2)))],
				for i = iblk:min(sz(1),iblk+blksz(1)-1),
					for k = kblk:min(sz(3),kblk+blksz(3)-1),
						findlinks
					end
				end
			end
			% left face
			for k = kblk+[0:(1+min(nhood(:,3)))],
				for i = iblk:min(sz(1),iblk+blksz(1)-1),
					for j = jblk:min(sz(2),jblk+blksz(2)-1),
						findlinks
					end
				end
			end

		end
	end
end

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

% label the equivalent components
comp(comp>0) = blocks(comp(comp>0));


%% nested function to link up components
function findlinks
mycmp = comp(i,j,k);
for nbor = 1:size(nhood,1),
	if G(i,j,k,nbor),
		ii2 = i+nhood(nbor,1); jj2 = j+nhood(nbor,2); kk2 = k+nhood(nbor,3);
		try,%if (ii2>0)&&(jj2>0)&&(kk2>0),
			nncmp = comp(ii2,jj2,kk2);
			% check if your neighbor has been set to 0 and "push" a label
			if nncmp == 0,
				comp(ii2,jj2,kk2) = mycmp;
			else, % else, add a link
				equiv(mycmp,nncmp) = 1;
				equiv(nncmp,mycmp) = 1;
			end
		end
	end
end
end

end
