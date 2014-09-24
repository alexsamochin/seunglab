function [min_y, max_y, min_x, max_x, first_section, last_section] = TracingBoundingBox(files)

min_x=inf; min_y=inf;
max_x=0; max_y=0;
first_section=inf;
last_section=0;

for i=1:length(files)	
	tracing =imread(files(i).name);
	i
	
    if(sum(tracing(:))>0)
    	if(first_section==inf) first_section=i;  end
        last_section=i;
		
		 % update bounding boxes if needed
        [r,c]=find(tracing > 0);
        bx=min(c); fx=max(c);
        by=min(r); fy=max(r);

        if(bx < min_x) min_x=bx; end
        if(fx > max_x) max_x=fx; end
        if(by < min_y) min_y=by; end
        if(fy > max_y) max_y=fy; end
	end
end


