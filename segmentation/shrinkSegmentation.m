function compOut = shrinkSegmentation(compIn,radius)

compOut = zeros(size(compIn));

radius2 = ceil(radius);
[x,y,z] = meshgrid(-radius2:radius2,-radius2:radius2,-radius2:radius2);
sph = sqrt(x.^2+y.^2+z.^2)<=radius;

cmps = unique(compIn(:));
cmps = cmps(cmps>0);	% prune zero component (out space)

for icmp = cmps',
	disp(['Eroding component ' num2str(icmp)])
	cmpErode = imerode(compIn==icmp,sph);
	if any(cmpErode(:)),
		compOut(cmpErode) = icmp;
	end
end
