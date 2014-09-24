function [im_aligned,final_components] = process_labeling(labels, sampFact, imSize)

[components,x,y]=mkLabels(labels, sampFact);
%save /tmp/processlabeling

% 'crop' output of srini's in/out generation script into super-sampled image dimensions

im_aligned=zeros(imSize.*[sampFact sampFact 1], 'single');

y_beg=min(find(y>=1))
x_beg=min(find(x>=1))

y_end=max(find(y<=imSize(1)))
x_end=max(find(x<=imSize(2)))

z_beg=1;
z_end=size(components,3);

% the -1 on the "end" terms is is because of the .5's in srini's scheme
% ie, y(y_beg)=1 and y(y_end)=512 means there is no labeling for 512.5 which is what 512*2 would include
% but the -1 is of course assuming the samplefactor is 2
%im_aligned((y(y_beg)-1)*sampFact+1:y(y_end)*sampFact-1,(x(x_beg)-1)*sampFact+1:x(x_end)*sampFact-1,z_beg:z_end)=components(y_beg:y_end,x_beg:x_end,:);

im_aligned((y(y_beg)-1)*sampFact+1:y(y_end)*sampFact-(sampFact-1),(x(x_beg)-1)*sampFact+1:x(x_end)*sampFact-(sampFact-1),z_beg:z_end)=components(y_beg:y_end,x_beg:x_end,:);


idcs=find(im_aligned>0);
[yy,xx,zz]=ind2sub(size(im_aligned),idcs);
cropped=im_aligned(min(yy):max(yy), min(xx):max(xx),min(zz):max(zz));
if(sampFact>1)
	cropped_interp=interpZ(cropped,sampFact);
	final_components=zeros(size(im_aligned).*[1 1 sampFact],'single');
	%components_2x(min(yy):max(yy), min(xx):max(xx),(min(zz)-1)*sampFact+1:(max(zz)*sampFact)-1)=cropped_interp;
	final_components(min(yy):max(yy), min(xx):max(xx),(min(zz)-1)*sampFact+1:(max(zz)*sampFact-(sampFact-1)))=cropped_interp;
else
	final_components=cropped;
end
