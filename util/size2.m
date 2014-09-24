function sz = size2(x,dims)

sz = zeros(1,length(dims));
for i = 1:length(dims),
	sz(i) = size(x,dims(i));
end
