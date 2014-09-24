function SaveComponentsAmira2(filename, comp, img)
% SaveComponentsAmira2(filename, comp, image)
%
%
%  comp - Components to save
%  filename - Output filename (without extension of '_comp.bin')
%
% JFM   4/9/2006
% Rev:  10/18/2006

% Voxel size in real-world coordinates (nm) (y,x,z)
voxel_size = [26.4 26.4 50];

if max(comp(:)) > 255
    fprintf('Warning:  Conveting comp to uint8, components > 255 are not saved\n');
end

comp = uint8(comp);

% Save the data to binary
fid = fopen(sprintf('%s_comp.bin',filename),'wb'); 
fwrite(fid, comp, 'uint8'); 
fclose(fid);

if exist('img','var')
    img = single(img);
    fid = fopen(sprintf('%s_img.bin',filename),'wb'); 
    fwrite(fid, img, 'single'); 
    fclose(fid);
end

% Create a random id number for blocks like SurfaceGen### in Amira,
% this lets more than one block of 255 components be loaded.
id = round(999*rand);

[pathstr, name] = fileparts(filename);

% ----------------------Write out the Amira script
fid = fopen(sprintf('%s_comp.hx', filename),'w');

fprintf(fid, '# Amira Script generate by SaveComponentsAmira.m \n');
%fprintf(fid, 'remove -all\n');
%fprintf(fid, 'remove %s_comp.bin %s_img.bin %s.am \n\n',name,name,name);

fprintf(fid, '# Create viewers\n');
fprintf(fid, 'viewer setVertical 0\n\n');

fprintf(fid, 'viewer 0 setBackgroundMode 1\n');
fprintf(fid, 'viewer 0 setBackgroundColor 0.06 0.13 0.24\n');
fprintf(fid, 'viewer 0 setBackgroundColor2 0.72 0.72 0.78\n');
fprintf(fid, 'viewer 0 setTransparencyType 5\n');
fprintf(fid, 'viewer 0 setAutoRedraw 0\n');
fprintf(fid, 'viewer 0 show\n');
fprintf(fid, 'mainWindow show\n\n');

fprintf(fid, 'set hideNewModules 0\n');
fprintf(fid, '[ load -raw ${SCRIPTDIR}/%s_comp.bin little xfastest byte 1 %d %d %d %d %d %d %d %d %d ] setLabel %s_comp.bin\n', ...
        name, size(comp,1), size(comp,2), size(comp, 3), 0, ...
        voxel_size(1) * (size(comp,1)-1), 0, ...
        voxel_size(2) * (size(comp,2)-1), 0, ...
        voxel_size(3) * (size(comp,3)-1), name);
fprintf(fid, '%s_comp.bin setIconPosition 20 10\n',name);
fprintf(fid, '%s_comp.bin fire\n',name);
fprintf(fid, '%s_comp.bin fire\n',name);
fprintf(fid, '%s_comp.bin setViewerMask 65535\n\n',name);

% Create the SurfaceGen

% set hideNewModules 0
fprintf(fid,'create HxGMC {SurfaceGen%0d}\n', id);
fprintf(fid,'SurfaceGen%0d setIconPosition 160 60\n', id);
fprintf(fid,'SurfaceGen%0d data connect %s_comp.bin\n', id, name);
fprintf(fid,'SurfaceGen%0d fire\n', id);
fprintf(fid,'SurfaceGen%0d smoothing setValue 0 2\n', id);
fprintf(fid,'SurfaceGen%0d options setValue 0 1\n', id);
fprintf(fid,'SurfaceGen%0d options setValue 1 0\n', id);
fprintf(fid,'SurfaceGen%0d border setValue 0 1\n', id);
fprintf(fid,'SurfaceGen%0d border setValue 1 0\n', id);
fprintf(fid,'SurfaceGen%0d minEdgeLength setMinMax 0 0 0.800000011920929\n', id);
fprintf(fid,'SurfaceGen%0d minEdgeLength setValue 0 0\n', id);
fprintf(fid,'SurfaceGen%0d materialList setValue 0 0\n', id);
fprintf(fid,'SurfaceGen%0d fire\n', id);

%fprintf(fid,'set hideNewModules 0
fprintf(fid,'[ {SurfaceGen%0d} create {%s_comp.surf} ] setLabel {%s_comp.surf}\n', id, name, name);

% Create the actual view of the surface we just generated 
fprintf(fid,'create HxDisplaySurface {SurfaceView%0d}\n', id);
fprintf(fid,'SurfaceView%0d setIconPosition 227 80\n', id);
fprintf(fid,'SurfaceView%0d data connect %s_comp.surf\n', id, name);
fprintf(fid,'SurfaceView%0d colormap setDefaultColor 1 0.1 0.1\n', id);
fprintf(fid,'SurfaceView%0d colormap setDefaultAlpha 0.500000\n', id);
fprintf(fid,'SurfaceView%0d fire\n', id);

% Adjust the viewer position

fprintf(fid,'viewer 0 setCameraPosition 17000 2300 1500\n');
fprintf(fid,'viewer 0 setCameraOrientation -0.571934 0.614557 -0.543334 2.19681\n');
fprintf(fid,'viewer 0 setCameraFocalDistance 17000\n');
fprintf(fid,'viewer 0 setAutoRedraw 1\n');
fprintf(fid,'viewer 0 redraw\n');

% --- Load the image data
if exist('img')
    fprintf(fid, 'set hideNewModules 0\n');
    % [ load -raw ${SCRIPTDIR}/retina_2x_img.bin little xfastest byte 1 162 82 16 0 161 0 81 0 15 ] setLabel retina_2x_img.bin
    fprintf(fid, '[ load -raw ${SCRIPTDIR}/%s_img.bin little xfastest float 1   %d %d %d   %d %d %d %d %d %d ] setLabel %s_img.bin\n', ...
            name, size(img,1), size(img,2), size(img, 3), 0, ...
            voxel_size(1) * (size(comp,1)-1), 0, ...
            voxel_size(2) * (size(comp,2)-1), 0, ...
            voxel_size(3) * (size(comp,3)-1), name);

       
    fprintf(fid, '%s_img.bin setIconPosition 10 100\n',name);
    fprintf(fid, '%s_img.bin fire\n',name);
    fprintf(fid, '%s_img.bin fire\n',name);
    fprintf(fid, '%s_img.bin setViewerMask 65535\n\n',name);
end


fclose(fid);
