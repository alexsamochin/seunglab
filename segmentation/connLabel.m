function comp = connLabel(conn,verbose)
% Finds connected components according to the connectivity structure conn
% Usage:
% components = connLabel(conn)

% normalize the inputs...
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


% segment
cmpMax = 0;
nCmpGuess=5e5; equiv = sparse(nCmpGuess,nCmpGuess);	% 'pre-allocate'
comp = zeros([size(conn,1) size(conn,2) size(conn,3)]);
connAll = sum(mkSymmConn(conn),4);

% 1 pass through matrix, making label estimates, and recording label equivalences
for i = 1:size(conn,1),
[i cmpMax]
	for j = 1:size(conn,2),
		for k = 1:size(conn,3),


			if connAll(i,j,k)~=0,		% atleast one connected neighbor in any direction
				% find the connected components
				nLabels = []; idx = 0;
				for ii = -1:0,
					for jj = -1:(0-ii),
						for kk = -1:(0-min(ii,jj)),
							idx = idx+1;
							if conn(i,j,k,idx), nLabels(end+1) = comp(i+ii,j+jj,k+kk); end
						end
					end
				end

				if isempty(nLabels),
					% create a new component
					cmpMax = cmpMax + 1;
					equiv(cmpMax,cmpMax) = 1;
					cmp = cmpMax;
				else 
					cmpNeighbors = unique(nLabels);
					% assign to smallest component #
					cmp = cmpNeighbors(1);
					% record equivalence of all these components
					for nn = 2:length(cmpNeighbors),
						equiv(cmp,cmpNeighbors(nn)) = 1;
						equiv(cmpNeighbors(nn),cmp) = 1;
					end
				end

				% mark label
				comp(i,j,k) = cmp;
			end

						
		end
	end
end
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

% label the equivalent components
comp(comp>0) = blocks(comp(comp>0));
% for cmp = unique(blocks),
% 	for otherCmp = find(blocks==cmp);
% 		comp(comp==otherCmp) = cmp;
% 	end
% end
