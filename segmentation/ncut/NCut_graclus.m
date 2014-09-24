function cmp = NCut_graclus(fname,k)
% performs k-way ncut of graph in fname using graclus (binary)
% returns the partitioning

[status,output] = unix(['graclus -o ncut -l 1000 ' fname]);
fprintf(output)
cmp = load([fname '.part.' num2str(k)]);
