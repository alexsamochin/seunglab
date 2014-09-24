function SaveComponentsAmira(filename, comp, img)
% SaveComponentsAmira(filename, comp, image)
%
%
%  comp - Components to save
%  filename - Output filename (without extension of '_comp.bin')
%
% JFM   4/9/2006
% Rev:  8/2/2006

comp = int32(comp);

% Save the data to binary
fid = fopen(sprintf('%s_comp.bin',filename),'wb'); 
fwrite(fid, comp, 'int32'); 
fclose(fid);

if exist('img','var')
    img = single(img);
    fid = fopen(sprintf('%s_img.bin',filename),'wb'); 
    fwrite(fid, img, 'single'); 
    fclose(fid);
end

[pathstr, name] = fileparts(filename);

% ----------------------Write out the Amira script
fid = fopen(sprintf('%s_comp.hx', filename),'w');

fprintf(fid, '# Amira Script generate by SaveComponentsAmira.m \n');
fprintf(fid, 'remove -all\n');
fprintf(fid, 'remove %s_comp.bin %s_img.bin %s.am CastField\n\n',name,name,name);

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
fprintf(fid, '[ load -raw ${SCRIPTDIR}/%s_comp.bin little xfastest int 1 %d %d %d %d %d %d %d %d %d ] setLabel %s_comp.bin\n', ...
        name, size(comp,1), size(comp,2), size(comp, 3), 0, size(comp,1)-1, 0, size(comp,2)-1, 0, size(comp,3)-1, name);
fprintf(fid, '%s_comp.bin setIconPosition 20 10\n',name);
fprintf(fid, '%s_comp.bin fire\n',name);
fprintf(fid, '%s_comp.bin fire\n',name);
fprintf(fid, '%s_comp.bin setViewerMask 65535\n\n',name);


% Create the cast field
fprintf(fid, 'set hideNewModules 0\n');
fprintf(fid, 'create HxCastField {CastField}\n');
fprintf(fid, 'CastField setIconPosition 160 40\n');
fprintf(fid, 'CastField data connect %s_comp.bin\n',name);
fprintf(fid, 'CastField colormap setDefaultColor 1 0.8 0.5\n');
fprintf(fid, 'CastField colormap setDefaultAlpha 0.500000\n');
fprintf(fid, 'CastField fire\n');
fprintf(fid, 'CastField outputType setValue 2 3\n'); % 6 == LabelField? %setValue 0 0\n');
fprintf(fid, 'CastField scaling setMinMax 0 -1.00000001384843e+24 1.00000001384843e+24\n');
fprintf(fid, 'CastField scaling setValue 0 1\n');
fprintf(fid, 'CastField scaling setMinMax 1 -1.00000001384843e+24 1.00000001384843e+24\n');
fprintf(fid, 'CastField scaling setValue 1 0\n');
fprintf(fid, 'CastField voxelGridOptions setValue 0 1\n');
fprintf(fid, 'CastField colorFieldOptions setValue 0 0\n');
fprintf(fid, 'CastField fire\n');
fprintf(fid, 'CastField setViewerMask 65535\n');
%fprintf(fid, 'CastField select\n\n');

% Apply the cast field to create LabelField
fprintf(fid,'set hideNewModules 0\n');
fprintf(fid,'[ {CastField} create {%s_comp.LabelField} ] setLabel %s_comp.LabelField\n', name, name); 
%[ load ${SCRIPTDIR}/e324_test_comp.am ] setLabel e324_test_comp.am
%[ {SurfaceGen} create {e324_test_comp.surf} ] setLabel {e324_test_comp.surf}
fprintf(fid,'%s_comp.LabelField setIconPosition 20 70\n', name);
fprintf(fid,'%s_comp.LabelField master connect CastField\n', name);
fprintf(fid,'%s_comp.LabelField fire\n', name);
%fprintf(fid,'%s_comp.LabelField primary setValue 0 0\n', name);
fprintf(fid,'%s_comp.LabelField fire\n', name);
fprintf(fid,'%s_comp.LabelField setViewerMask 65535\n', name);

% set hideNewModules 0
fprintf(fid,'create HxGMC {SurfaceGen}\n');
fprintf(fid,'SurfaceGen setIconPosition 160 100\n');
fprintf(fid,'SurfaceGen data connect %s_comp.LabelField\n', name);
fprintf(fid,'SurfaceGen fire\n');
fprintf(fid,'SurfaceGen smoothing setValue 0 2\n');
fprintf(fid,'SurfaceGen options setValue 0 1\n');
fprintf(fid,'SurfaceGen options setValue 1 0\n');
fprintf(fid,'SurfaceGen border setValue 0 1\n');
fprintf(fid,'SurfaceGen border setValue 1 0\n');
fprintf(fid,'SurfaceGen minEdgeLength setMinMax 0 0 0.800000011920929\n');
fprintf(fid,'SurfaceGen minEdgeLength setValue 0 0\n');
fprintf(fid,'SurfaceGen materialList setValue 0 0\n');
fprintf(fid,'SurfaceGen fire\n');

%fprintf(fid,'set hideNewModules 0
fprintf(fid,'[ {SurfaceGen} create {%s_comp.surf} ] setLabel {%s_comp.surf}\n', name, name);

% Create the actual view of the surface we just generated 
fprintf(fid,'create HxDisplaySurface {SurfaceView}\n');
fprintf(fid,'SurfaceView setIconPosition 227 150\n');
fprintf(fid,'SurfaceView data connect %s_comp.surf\n', name);
fprintf(fid,'SurfaceView colormap setDefaultColor 1 0.1 0.1\n');
fprintf(fid,'SurfaceView colormap setDefaultAlpha 0.500000\n');
fprintf(fid,'SurfaceView fire\n');

% Adjust the viewer position

fprintf(fid,'viewer 0 setCameraPosition 554.375 274.259 243.822\n');
fprintf(fid,'viewer 0 setCameraOrientation -0.415047 0.905166 0.091705 1.19403\n');
fprintf(fid,'viewer 0 setCameraFocalDistance 467.057\n');
fprintf(fid,'viewer 0 setAutoRedraw 1\n');
fprintf(fid,'viewer 0 redraw\n');

% --- Load the image data
if exist('img')
    fprintf(fid, 'set hideNewModules 0\n');
    % [ load -raw ${SCRIPTDIR}/retina_2x_img.bin little xfastest byte 1 162 82 16 0 161 0 81 0 15 ] setLabel retina_2x_img.bin
    fprintf(fid, '[ load -raw ${SCRIPTDIR}/%s_img.bin little xfastest float 1   %d %d %d   %d %d %d %d %d %d ] setLabel %s_img.bin\n', ...
            name, size(img,1), size(img,2), size(img, 3), ...
            0, size(img,1)-1, 0, size(img,2)-1, 0, size(img,3)-1, name);
    fprintf(fid, '%s_img.bin setIconPosition 10 180\n',name);
    fprintf(fid, '%s_img.bin fire\n',name);
    fprintf(fid, '%s_img.bin fire\n',name);
    fprintf(fid, '%s_img.bin setViewerMask 65535\n\n',name);
end


fclose(fid);
