function hinton_diagram(w,max_m,min_m)
layers=size(w,3);

for l=1:layers
	subplot(1,layers,l)
	hintonv(w(:,:,l));
	hold on;
end

