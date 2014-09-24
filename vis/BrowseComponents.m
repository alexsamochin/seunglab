function [varargout] = BrowseComponents(im_type, varargin)
% BrowseComponents -- Flips between different sections with keyboard,
%   shows the image, inout labels and generated labels.  Assume the
%   last two images are components that should be display with a
%   random colormap.
%
%   im_type - String with up to 4 characters giving type of image, where
%           'i' will plot an image stack (using imagesc) and
%           'c' will plot a component stack (using colormap cm),
%           'o' will plot the components overlaid on the first image stack
%           e.g. 'icic'
%   imageN - 1 - 4 images
%
% Keyboard commands:
%   Up or 'i' - Go to next section
%   Down or 'k' - Go to previous section
%   q - Up 10 sections
%   a - Down 10 sections
%   z - zoom in (click mouse twice to select two corners of a rectangle)
%   x - zoom out 
%	r/t - adjust contrast
%	f - return contrast to original scaling
%   Esc - Quits
%
% Load some workspaces:
%    workspace_mb = load('~/project/semdata/viren/e324/mb_labeled.mat')
%    workspace_aw = load('~/project/semdata/viren/e324/aw_labeled.mat')
%
% JFM   2/16/2006
% Rev:  7/5/2006
% Rev by V. JAIN: 2/8/07: added global normalization, zoom
% Rev. V. JAIN: 6/11/07: added photoshop hooks and output 

KEY_ESC = 27;
KEY_UP = 30;
KEY_DOWN = 31;
KEY_RIGHT = 29;
KEY_LEFT = 28;

% Since cursor keys don't seem to get mapped in -nojvm mode,
% use also:  i = up, k = down, j = left, l = right

x = 1;
y = 1;
z = 1;
key = 1;
threshold = 128;
do_edit=false;
editing_comp=0;

if(isequal(size(varargin{end}),[3 2]))
	bb=varargin{end};
	num_stacks=nargin-2;
else
	bb=[];
	num_stacks=nargin-1;
end

if(num_stacks==1)
	stack1=varargin{1};
elseif(num_stacks==2);
	stack1=varargin{1};
	stack2=varargin{2};
elseif(num_stacks==3);
	stack1=varargin{1};
	stack2=varargin{2};
	stack3=varargin{3};
elseif(num_stacks==4);
	stack1=varargin{1};
	stack2=varargin{2};
	stack3=varargin{3};
	stack4=varargin{4};
end

if(~isempty(bb))
	stack1=stack1(bb(1,1):bb(1,2),bb(2,1):bb(2,2),bb(3,1):bb(3,2),:);
	if(num_stacks>1)
		stack2=stack2(bb(1,1):bb(1,2),bb(2,1):bb(2,2),bb(3,1):bb(3,2),:);
	end
	if(num_stacks>2)
		stack3=stack3(bb(1,1):bb(1,2),bb(2,1):bb(2,2),bb(3,1):bb(3,2),:);
	end
	if(num_stacks>3)
		stack4=stack4(bb(1,1):bb(1,2),bb(2,1):bb(2,2),bb(3,1):bb(3,2),:);
	end
end

scale_adj=1;
%thresh_inout = (256*gen_inout > threshold);

% Load color_map (made with rand(5000,3) and saved)
try
        [aa,home]=unix('echo $HOME');
        % sometimes (as on brainiac), the last character is a \n. get rid of all non-letters.
        home = deblank(home);
    	load([home, '/component_colormap.mat']);
catch
    % File isn't there, so create it in the home directory
        disp('Couldnt find component_colormap.mat, regenerating new one...');
        [aa,home]=unix('echo $HOME');
        % sometimes (as on brainiac), the last character is a \n. get rid of all non-letters.
        home = deblank(home);
    color_map = single(rand(1e6,3));
    save([home,'/component_colormap.mat'], 'color_map'); 
end

% if passed a bounding box, crop all arguments


figure(1);
% Keeps the Matlab command window from resuming focus
% when a key is hold down (to rapidly flip through the
% sections.)
set(0,'DefaultFigureRenderer','opengl');
gcfOldWindowStyle = get(gcf,'WindowStyle');
set(gcf, 'WindowStyle', 'modal');
%set(gcf, 'DoubleBuffer','off');
%set(gcf, 'doublebuffer','off');

% Find global image scaling
min_scale=[]; max_scale=[];
if(find(im_type == 'i'))
	display('finding global image scaling for each image stack..')
	if(im_type(1) == 'i')
		min_scale{1}=min(stack1(:));
		max_scale{1}=max(stack1(:));
	end
	if(num_stacks > 1 && im_type(2) == 'i')
		min_scale{2}=min(stack2(:));
		max_scale{2}=max(stack2(:));
	end
	if(num_stacks > 2 && im_type(3) == 'i')
		min_scale{3}=min(stack3(:));
		max_scale{3}=max(stack3(:));
	end
	if(num_stacks > 3 && im_type(4) == 'i')
		min_scale{4}=min(stack4(:));
		max_scale{4}=max(stack4(:));
	end
end

orig_min_scale=min_scale;
orig_max_scale=max_scale;

% get max coordinates
ycoords{1}=[1:size(stack1,1)];
xcoords{1}=[1:size(stack1,2)];

if(num_stacks>1)
	ycoords{2}=[1:size(stack2,1)];
	xcoords{2}=[1:size(stack2,2)];
end

if(num_stacks>2)
	ycoords{3}=[1:size(stack3,1)];
	xcoords{3}=[1:size(stack3,2)];
end

if(num_stacks>3)
	ycoords{4}=[1:size(stack4,1)];
	xcoords{4}=[1:size(stack4,2)];
end

if(num_stacks == 4)
    image1(:,:,1,:) = stack1( :,:,min(z,size(stack1,3)),: );
    image2(:,:,1,:) = stack2( :,:,min(z,size(stack2,3)),: );
    image3(:,:,1,:) = stack3( :,:,min(z,size(stack3,3)),: );
    image4(:,:,1,:) = stack4( :,:,min(z,size(stack4,3)),: );
    
    PlotSectionComponents(1, color_map, min_scale, max_scale, im_type, image1, image2, image3, image4);       
elseif(num_stacks == 3)
    image1(:,:,1,:) = stack1( :,:,min(z,size(stack1,3)),: );
    image2(:,:,1,:) = stack2( :,:,min(z,size(stack2,3)),: );
    image3(:,:,1,:) = stack3( :,:,min(z,size(stack3,3)),: );
    
    PlotSectionComponents(1, color_map, min_scale, max_scale, im_type, image1, image2, image3);
elseif(num_stacks == 2)
    image1(:,:,1,:) = stack1( :,:,min(z,size(stack1,3)),: );
    image2(:,:,1,:) = stack2( :,:,min(z,size(stack2,3)),: );

    PlotSectionComponents(1, color_map, min_scale, max_scale, im_type, image1, image2);
else
    image1(:,:,1,:) = stack1( :,:,min(z,size(stack1,3)),: );

    PlotSectionComponents(1, color_map, min_scale, max_scale, im_type, image1);
end

%fprintf('Section: %d     Threshold: %d    ', z, threshold);
% Find image scaling for each image stack - V. JAIN 2/8/07
do_zoom=0;



while(isempty(key) | key ~= KEY_ESC)

	if(~do_zoom)
	    [x,y,key] = ginput(1);
    else
    	[xzoom,yzoom]=ginput(2);
    	
    	ycoords{1}=[max(1,round(min(yzoom))):min(size(stack1,1),round(max(yzoom)))]+(ycoords{1}(1)-1);
    	xcoords{1}=[max(1,round(min(xzoom))):min(size(stack1,2),round(max(xzoom)))]+(xcoords{1}(1)-1);   	
		
		[ycoords, xcoords]=set_all_zoom(num_stacks, ycoords, xcoords);

    	do_zoom=0;
    	key='';
    end
    
    x = max(round(x),1);
    y = max(round(y),1);
   
   if(do_edit && editing_comp>0)
   		try,  	 	
	   		newimg=psgetpixels;	
   			new_comp_idxs=find(newimg~=0);
   	 	
	   		if(editing_source_stack==1)
   				editing_layer=stack1(:,:,z);
   				editing_layer(find(editing_layer==editing_comp))=0;
   				editing_layer(new_comp_idxs)=editing_comp;
				stack1(:,:,z)=editing_layer;
			elseif(editing_source_stack==2)
  				editing_layer=stack2(:,:,z);
   				editing_layer(find(editing_layer==editing_comp))=0;
   				editing_layer(new_comp_idxs)=editing_comp;
				stack2(:,:,z)=editing_layer;
			elseif(editing_source_stack==3)
  				editing_layer=stack3(:,:,z);
   				editing_layer(find(editing_layer==editing_comp))=0;
   				editing_layer(new_comp_idxs)=editing_comp;
				stack3(:,:,z)=editing_layer;
			elseif(editing_source_stack==4)
  				editing_layer=stack4(:,:,z);
   				editing_layer(find(editing_layer==editing_comp))=0;
   				editing_layer(new_comp_idxs)=editing_comp;
				stack4(:,:,z)=editing_layer;
			end
		catch,
			display('exception while trying to read back changes from photoshop');
		end
		
   end
   
    if(key == KEY_UP | key == 'i') 
        z = z + 1; 
        z = min(z,size(stack1,3));
    end
    if(key == KEY_DOWN | key == 'k') 
        z = z - 1; 
        z = max(z,1);
    end
	
	% toggle edit mode
	if(key=='e')
		1
		if(do_edit)
			do_edit=false;
			psclosedoc(1)
		else
			do_edit=true;
			
			ru = psconfig();
			if ~strcmp(ru, 'pixels')
    			psconfig('pixels');
			end
			psnewdoc(size(stack1,2), size(stack1,1), 'undefined', 'undefined', 'grayscale');
			psnewlayer('components');
			clicked_on=0;
		end
	end
	
	% manually input component number to edit
	if(key=='n')
		if(clicked_on==0)
			display('first select a stack by clicking on its subplot');
		else
			editing_comp=input('which component? ');
		end
		
	end

	% backup all stacks to a file
	if(key=='b')
		if(num_stacks==1)
			save('backup','stack1');
		elseif(num_stacks==2)
			save('backup','stack1','stack2');
		elseif(num_stacks==3)
			save('backup','stack1','stack2','stack3');
		elseif(num_stacks==4)
			save('backup', 'stack1', 'stack2', 'stack3');
		end
	end
	

	if(key=='r')
		for ii=1:size(min_scale,1)
			scale_change=.1*(max_scale{ii}-min_scale{ii});
			min_scale{ii}=min_scale{ii}+scale_change;
			max_scale{ii}=max_scale{ii}-scale_change;
		end
	end

	if(key=='t')
		for ii=1:size(min_scale,1)
			scale_change=.1*(max_scale{ii}-min_scale{ii});
			min_scale{ii}=min_scale{ii}-scale_change;
			max_scale{ii}=max_scale{ii}+scale_change;
		end
	end
	if(key=='f')
		min_scale=orig_min_scale;
		max_scale=orig_max_scale;
	end

	% page up
    if(key == 'q')
    	z = z + 10;
        z = min(z,size(stack1,3));
    end
    % page down
    if(key == 'a')
    	z = z - 10;
        z = max(z,1);
    end
    % zoom out
    if(key=='z')
    	do_zoom=1;
    end
    % zoom in
    if(key=='x')
        	
    	ycoords{1}=[max(1, ycoords{1}(1)-round(.5*length(ycoords{1}))):min(size(stack1,1),ycoords{1}(end)+round(.5*length(ycoords{1})))];
    	xcoords{1}=[max(1, xcoords{1}(1)-round(.5*length(xcoords{1}))):min(size(stack1,2),xcoords{1}(end)+round(.5*length(xcoords{1})))];
		
		[ycoords, xcoords]=set_all_zoom(num_stacks, ycoords, xcoords);
	
    	key='';
    end

%     if(key == 'a') 
%         threshold = threshold + 1;
%         threshold = min(threshold,256);
%         thresh_inout = (256*gen_inout > threshold);
%     end
%     if(key == 'z') 
%         threshold = threshold - 1; 
%         threshold = max(threshold,1);
%         thresh_inout = (256*gen_inout > threshold);
%     end
%       

    %waitforbuttonpress;
    %key = single(get(gcf,'CurrentCharacter'))
    h = gca;
    
    try
        if(h == subplot(1,num_stacks,1))
            str = sprintf('  (%d,%d,%d) = %.3f\n',  y+ycoords{1}(1)-1, x+xcoords{1}(1)-1, z, stack1(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z) );
            clicked_on=1;
            editing_comp=stack1(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z);
        elseif(h == subplot(1,num_stacks,2) & exist('stack2'))
            str = sprintf('  (%d,%d,%d) = %.3f\n',  y+ycoords{1}(1)-1, x+xcoords{1}(1)-1, z, stack2(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z) );
            clicked_on=2;
            editing_comp=stack2(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z);
        elseif(h == subplot(1,num_stacks,3) & exist('stack3'))
            str = sprintf('  (%d,%d,%d) = %.3f\n',  y+ycoords{1}(1)-1, x+xcoords{1}(1)-1, z, stack3(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z) );
            clicked_on=3;
            editing_comp=stack3(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z);
        elseif(h == subplot(1,num_stacks,4) & exist('stack4'))
            str = sprintf('  (%d,%d,%d) = %.3f\n',  y+ycoords{1}(1)-1, x+xcoords{1}(1)-1, z, stack4(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z) );
            clicked_on=4;
            editing_comp=stack4(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z);
        end
    catch
        str = ' ';
    end
	

    if(num_stacks == 4)
        image1 = stack1( ycoords{1},xcoords{1},min(z,size(stack1,3)),: );
        image2 = stack2( ycoords{2},xcoords{2},min(z,size(stack2,3)),: );
        image3 = stack3( ycoords{3},xcoords{3},min(z,size(stack3,3)),: );
        image4 = stack4( ycoords{4},xcoords{4},min(z,size(stack4,3)),: );

    	
	    PlotSectionComponents(1, color_map, min_scale, max_scale, im_type, image1, image2, image3, image4);       

    elseif(num_stacks == 3)
        image1 = stack1( ycoords{1},xcoords{1},min(z,size(stack1,3)),: );
        image2 = stack2( ycoords{2},xcoords{2},min(z,size(stack2,3)),: );
        image3 = stack3( ycoords{3},xcoords{3},min(z,size(stack3,3)),: );

        PlotSectionComponents(1, color_map,  min_scale, max_scale,im_type, image1, image2, image3);
    elseif(num_stacks == 2)
        image1 = stack1( ycoords{1},xcoords{1}, min(z,size(stack1,3)),: );
        image2 = stack2( ycoords{2},xcoords{2},min(z,size(stack2,3)),: );

        PlotSectionComponents(1, color_map,  min_scale, max_scale, im_type, image1, image2);
    else
        image1 = stack1( ycoords{1},xcoords{1}, min(z,size(stack1,3)),: );

        PlotSectionComponents(1, color_map,  min_scale, max_scale,im_type, image1);
    end

    % Display info in title and output
    str2 = sprintf('Section: %d     Threshold: %d    ', z, threshold);
    
    if(do_edit)
		
		if(clicked_on==0)
			editing_comp=0;
		end
		
    	if(clicked_on==1)
    		editing_comp=stack1(y+ycoords{1}(1)-1,x+xcoords{1}(1)-1,z);
    		editing_img=uint8(stack1(:,:,z)==editing_comp)*255;
			pssetpixels(editing_img);	
			editing_source_stack=1;
		elseif(clicked_on==2)
			pssetactivelayer('Background');
			pssetpixels(uint8(stack1(:,:,z)));
			pssetactivelayer('components');
    		editing_img=uint8(stack2(:,:,z)==editing_comp)*255;
    		pssetpixels(ones(size(editing_img),'uint8')*255, 16);
			pssetpixels(editing_img);
			editing_source_stack=2;

    	end
    	
    end
    
 	h = axes('Position', [0 0 1 1], 'Visible', 'off');
	text(0.1, 0.95, str2, 'FontSize', 9);
    
 	h = axes('Position', [0 0 1 1], 'Visible', 'off');
	text(0.8, 0.95, str, 'FontSize', 9);

    %fprintf('%s %s\n', str2, str);
 
end

set(gcf,'WindowStyle',gcfOldWindowStyle)

if(do_edit)
	psclosedoc(1)
end

%varargout{1}=stack1;
%if(num_stacks>1),	varargout{2}=stack2; end
%if(num_stacks>2),	varargout{3}=stack3; end
%if(num_stacks>3),	varargout{4}=stack4; end
end

function [ycoords, xcoords]=set_all_zoom(num_stacks, ycoords, xcoords)


		if(num_stacks>1)
	    	ycoords{2}=ycoords{1};
   		 	xcoords{2}=xcoords{1};    	
		end

		if(num_stacks>2)
	    	ycoords{3}=ycoords{1};
   		 	xcoords{3}=xcoords{1};    	
		end

		if(num_stacks>3)
	    	ycoords{4}=ycoords{1};
   		 	xcoords{4}=xcoords{1};    	
		end


end
