function nhood = mknhood(nconnect)
% Makes nhood structures for some most used dense graphs.
% mknhood(6) makes the nhood for a 6-connected lattice graph
% mknhood(26) makes the nhood for a 26-connected lattice graph
%
% The neighborhood reference for the dense graph representation we use
% nhood(1,:) is a 3 vector that describe the node that conn(:,:,:,1) connects to
% so to use it: conn(23,12,42,3) is the edge between node [23 12 42] and [23 12 42]+nhood(3,:)
% See? It's simple! nhood is just the offset vector that the edge corresponds to.


switch nconnect,
case 6,
	nhood = [-1 0 0;
			0 -1 0;
			0 0 -1];
case 26,
	nbor = 0;
	for i = -1:0,
		for j = -1:(-i),
			for k = -1:(0-min(i,j)),
				if ~(i==0 && j==0 && k==0)
					nbor = nbor+1;
					nhood(nbor,:) = [i j k];
				end
			end
		end
	end
case 124,
 nbor = 0;
 for i = -2:0,
   for j = -2:2,
     for k = -2:2
       if (i<0 || j<=k)
	 if (i==0 && j>=0 && j==k) continue; end
	 nbor = nbor+1;
	 nhood(nbor,:) = [i j k];
       end
     end
   end
 end
 
 
 otherwise,
	error(['only nconnect values of 6 or 26 or 124 supported']);
end
