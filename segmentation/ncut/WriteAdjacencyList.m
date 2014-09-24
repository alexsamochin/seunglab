function WriteAdjacencyList(G,fname)
% Writes a sparse adjacency matrix graph to file as an adjacency list in 'graclus' format

numNodes = size(G,1);
numEdges = nnz(G)/2;

% graclus only takes integer wts, we scale the floating pt wts to use the
% whole integer range
% scale edge values to be integers in the range 0 - 2,147,483,647
maxInt = 2^10;
G = (maxInt/max(G(:)))*G;

% write header
fid = fopen(fname,'w');
fprintf(fid,'%i %i 1\n',numNodes,numEdges);

% write adjacency list
for node = 1:numNodes,
	row = G(:,node);
	[nbors,jnk,wts] = find(row);
	fprintf(fid,[num2str(reshape(int32([nbors wts])',1,[]),'%i ') '\n']);
end

fclose(fid);
