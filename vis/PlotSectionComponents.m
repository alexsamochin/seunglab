function PlotSectionComponents(varargin)
% function PlotSectionComponents(z, cm, im_type, image1, image2, image3, image4)
%
% PlotSectionComponents -- Plots section z of each of the images in the same figure.
%   One to four images may be plotted
%
%   z - Section to display
%   cm - Colormap for component images (assumed to be the last two images)
%   im_type - String with up to 4 characters giving type of image, where
%           'i' will plot an image stack (using imagesc) and
%           'c' will plot a component stack (using colormap cm),
%           'o' will plot the components overlaid on the first image stack
%           e.g. 'icic'
%   imageN - 1 - 4 images
%
%  JFM   2/16/2006
%  Rev:  7/3/2006

num_images = nargin - 5;

z = varargin{1};
cm = varargin{2};
min_scale = varargin{3};
max_scale = varargin{4};
im_type = varargin{5};

% Make sure colormap(1) is black
cm(1,:) = [0 0 0];

% Find index of first image (the overlay image)
ind = find(im_type == 'i');
over_im = [];
if ~isempty(ind)
    img = varargin{ind(1) + 5};

    % Check input image type
    whs = whos('img');
    if strcmp(whs.class, 'uint8')
    %    fprintf('Warning:  Converting uint8 image to double\n');
        over_im = single(img(:,:,z)) / 256;
    else
        over_im = single(img(:,:,z));
    end
end
    
if( ~isempty(find(im_type=='o')) & isempty(over_im) )
    fprintf('Error:  No image given for overlay mode\n');
    return
end
   
for i = 1:num_images
    subplot(1,num_images,i);
    
	if(im_type(i)=='i' && isequal(min_scale{i},max_scale{i}))
		max_scale{i}=min_scale{i}+1;
	end
	
    if(z <= size(varargin{5+i},3))
        if(im_type(i) == 'i')
			slice = squeeze(varargin{5+i}(:,:,z,:));
			slice = (slice-min_scale{i})/(max_scale{i}-min_scale{i});
            imagesc(slice);
            axis tight
        elseif(im_type(i) == 'c')
            img = varargin{5+i};
            img = ind2rgb(int32(img(:,:,z))+int32(img(:,:,z)~=0),cm);
            image(img);
        elseif(im_type(i) == 'o')
            img = varargin{5+i};
            img = ind2rgb(int32(img(:,:,z))+int32(img(:,:,z)~=0), cm);
            im_mask = (img == 0);

            img(:,:,1) = over_im .* img(:,:,1);
            img(:,:,2) = over_im .* img(:,:,2);
            img(:,:,3) = over_im .* img(:,:,3);

            img(:,:,1) = img(:,:,1) + over_im .* im_mask(:,:,1);
            img(:,:,2) = img(:,:,2) + over_im .* im_mask(:,:,2);
            img(:,:,3) = img(:,:,3) + over_im .* im_mask(:,:,3);  

            image(img);                
        else                
            fprintf('Unknown image type\n');
        end
    end

    %axis image;
    colormap(gray(256));
	axis xy
end
