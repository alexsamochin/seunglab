function [valid_comp] = Validate(valid_filename, comp_thresh_filename)
% [valid_comp] = Validate(valid_filename, comp_thresh_filename);
%    Starts the GUI to allow human-assisted merging and splitting
%    given components at various thresholds.
%
% 
% valid_filename - Filename of a validation file set to load, if it
%     doesn't exist, create one.  Saves are made to the same file.
%     [.mat file]
% 
% valid_input_filename - Filename of .mat file with network output components
%     at various levels of threshold (there should be some ordering
%     too, to indicate which levels are higher than others, to be
%     used for merging and splitting.  Created by CreateValidateInput.
%     [.mat file]
%
% Returns:
%   valid_comp - Stack of validated components (image sized)
%
%   [Also saves valid_filename .mat]
%
% Calling:
% cd /project/semdata/retina1
% Validate('retina1_valid', 'test_valentin1');
%
%
% Keyboard commands:
%   Up - Go to next section
%   Down - Go to previous section
%   PageUp or q - Up 10 sections
%   PageDown or a - Down 10 sections
%   Esc - Quits
%
%  JFM   8/16/2006
%  Rev:  10/8/2007

zratio = 26.4/50;

% ----- Load comp_thresh components at various thresholds
all_comp_thresh = load(comp_thresh_filename);

%feature('memstats');

% Check input image type
if ~strcmp(class(all_comp_thresh.im), 'single')
    fprintf('Warning:  Converting image to single\n');
    all_comp_thresh.im = single(all_comp_thresh.im) ./ 256;
end
mn = min(all_comp_thresh.im(:));
if mn<0, all_comp_thresh.im = all_comp_thresh.im-mn; end
mx = max(all_comp_thresh.im(:));
if mx>1, all_comp_thresh.im = all_comp_thresh.im/mx; end
sem_image = all_comp_thresh.im;

%feature('memstats');

% ----- Load the valid_filename or else create a new valid set -----
try 
    % --- Load valid components .mat file
    load(valid_filename,'state','valid_comp','valid_info','problem_area');

    if strcmp(state.cur_comp_thresh_filename, comp_thresh_filename) == 0
        % We're using a different set of components, so we have to reset some states
        state.n_cur_comp = [];
        state.n_cur_thresh = []; 
        state.thresh_ind = 1;
        state.thresholds = all_comp_thresh.thresholds;
        state.thresh = state.thresholds(state.thresh_ind);
    end
 
    % Create the current set of components
    all_comps = eval(sprintf('all_comp_thresh.comp%d', state.thresholds(state.thresh_ind) ));  %!! ok?
    [sy sx sz] = size(all_comps);

    cur_comp = SelectCurrentComponents;

    if ~exist('state.mode_alt','var')
        state.mode_alt = '';
    end
    
    if ~exist('state.plot3d_plane', 'var')
        state.plot3d_plane = true;
    end
    
    if state.plot2_show_valid  % !! ok?
        state.thresh = 999;
    end
        
catch % Create a new validation set
    last_err = lasterror;
    if strcmp(last_err.identifier, 'MATLAB:load:couldNotReadFile') == 0
        % Unknown loading error
        fprintf('Error:  Unexpected error loading file\n');
        disp(last_err.message);
        return;
    end
    
    fprintf('Warning:  Valid file %s not found, creating new validation set\n', valid_filename);
    
    % --- Set initial parameters 

    state.n_valid = 0;
    state.cur_comp_thresh_filename = comp_thresh_filename;
    
    % Current level of threshold to examine
    state.thresholds = all_comp_thresh.thresholds;

    state.thresh_ind = 1;
    state.thresh = state.thresholds(state.thresh_ind);
    %state.thresh_ind = find(state.thresholds == state.thresh);
    
    % List of the component number of the currently selected components
    % in the left 2d plot and the 3d plot
    state.n_cur_comp = [];
    % List of the thresholds of each of the current components.  If the
    % threshold == 999, then the component is from the valid set.
    state.n_cur_thresh = state.thresh * ones(length(state.n_cur_comp));
    
    %state.thresh = 96; %state.thresholds(state.thresh_ind);
    %state.n_cur_comp = [17 53];

    % All the components at the current threshold level for right 2d plot
    all_comps = eval(sprintf('all_comp_thresh.comp%d', ...
        state.thresholds(state.thresh_ind) ));  %!! ok?
    [sy sx sz] = size(all_comps);

    % Set of components are current treshold level
    cur_comp = SelectCurrentComponents;

    state.x = round(sx/2);
    state.y = round(sy/2);
    state.z = round(sz/2);

    % State of plots: components, orignal images or both
    state.plot1_comp = true;
    state.plot1_image = true;
    state.plot2_comp = true;
    state.plot2_image = false;
    state.plot2_show_valid = false;
    state.plot2_show_problem = false;
    state.plot3d_enable = true;
    state.plot3d_plane = false;
    
    % 3d view default state 
    state.CameraPosition = [ -670 -1040 360 ];
    state.CameraUpVector = [ 0 0 1];

    % Current state, 'add', 'delete', 'problem'
    state.mode = '';
    
    % Current alternate mode, 'merge'
    state.mode_alt = '';
    
    state.cell_type = { 'unknown', 'axon/dendrite', 'glia', 'rod/cone', 'fragment', 'cell body' };
    
    % Initialize the valid components structs
    valid_comp = zeros(size(all_comps),'uint16');
    valid_info(1).comp_num = 0;
    
    % Initialize problem_area struct array
    problem_area(1).loc{1} = [ 0 0 0 ];
    problem_area(sz).loc{1} = [ 0 0 0 ];
    problem_area(1).loc{1} = [];
    problem_area(sz).loc{1} = [];

    state.reject{1}.n_comp = [];
    state.reject{1}.n_thresh = [];
end
    

% ------------------------- Create the GUI ---------------------------

set(0,'DefaultFigureRenderer','opengl');

set(0,'Units','pixels');
screen_size = get(0,'ScreenSize');
screen_width = screen_size(3);
screen_height = screen_size(4);
curb_height = 70;  % To clear the menu bar at bottom (assume Win/KDE style bottom bar)


if screen_width < 1900
    %fprintf('Looks like someone needs a larger monitor!\n');
    small_screen = true;
else
    small_screen = false;
end

% ------ 2d plots (BrowseComponents style) ------
fig_text_width = 300; % Width of text window

if small_screen
    fig_width = screen_width - fig_text_width -10; 
    fig_height = screen_height - curb_height; 
else
    fig_width = screen_width/2-10; 
    fig_height = screen_height - curb_height; 
end

%if ispc
%    fig_height = fig_height - 24;
%end

plot_width = round(fig_width / 2) - 30;
plot_height = round(fig_height / 2) - 60;

h_fig = figure('Visible', 'off', ...
    'Position', [0, curb_height, fig_width, fig_height], ...
    'KeyPressFcn', {@KeyPressCallback}, ...
    'WindowButtonDownFcn', {@ButtonDown2dPlotCallback}, ...
    'CloseRequestFcn', {@CloseFigCallback}, ...
    'ResizeFcn', (@Resize2dCallback), ...
    'Interruptible', 'off');

background_color = get(h_fig,'Color');
set(h_fig,'doublebuffer','off');

% Hide the menu
set(h_fig,'MenuBar','none');  % Need this to get the size of the window right 
%set(h_fig,'MenuBar','figure');  % Standard menu, overridden by WindowStyle 'modal'

h_plot1 = axes('Units', 'Pixels', 'Position', [ 20, 30, plot_width, plot_height] );
h_plot2 = axes('Units', 'Pixels', 'Position', [ plot_width + 40, 30, plot_width, plot_height] );
h_plot3 = axes('Units', 'Pixels', 'Position', [ 20, plot_height + 80, plot_width, plot_height] );
h_plot4 = axes('Units', 'Pixels', 'Position', [ plot_width + 40, plot_height + 80, plot_width, plot_height] );

% Get the exact size in pixels of these windows
pos = get(h_plot1, 'Position');
plot_width = pos(3);
plot_height = pos(4);
%keyboard

% ------- Text figure for buttons and text info -------
fig_text_height = screen_height - curb_height;

%if ispc
%    fig_text_height = fig_text_height - 24;
%end

h_fig_text = figure('Visible', 'off', ...
    'Position', [fig_width + 10, curb_height, fig_text_width, fig_text_height],...
    'WindowButtonDownFcn', {@ButtonDownTextCallback}, ...
    'KeyPressFcn', {@KeyPressCallback}, ...
    'CloseRequestFcn', {@CloseFigCallback}, ...
    'Interruptible', 'off');

% Hide the menu
set(h_fig_text,'MenuBar','none');

%set(h_fig_text);
%get(h_fig_text);
ypos = fig_text_height-50;


% Won't display last word if the filename is too long
h_text_savename = uicontrol('Style','text',...
    'String', sprintf('%s\n', valid_filename),...
    'Position',[15,ypos,200,15],...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', background_color);
    
h_button_save = uicontrol('Style','pushbutton','String','Save',...
    'Position',[225,ypos,60,25],...
    'Callback',{@SaveCallback},...
    'BackgroundColor', background_color);    
    
ypos = ypos - 25;

h_text1 = uicontrol('Style','text','String','',...
    'Position',[15, ypos,270,15],...
    'BackgroundColor', background_color);

      
ypos = ypos - 25;

% Number of components to be listed in the text info window
if fig_text_height < 800
    n_comp_list = 10;
else
    n_comp_list = 20;
end

% Can't have a callback for a text string, so using pushbuttons
for i = 1:n_comp_list
    h_comp_list(i) = uicontrol('Style','pushbutton','String','',...
        'HorizontalAlignment','left',...        
        'Position',[15, ypos, 270, 18],...
        'BackgroundColor', background_color,...    
        'KeyPressFcn', {@KeyPressCallback}, ...
        'Callback',{@CompListCallback, i});  % Should pass back the button number when clicked
    ypos = ypos - 19;

end

ypos = ypos - 20;

% uibuttongroup could manage the exclusive selection of these buttons,
% but we don't use that for now.
h_button_add = uicontrol('Style','togglebutton','String','Add',...
          'Position',[15,ypos,70,25],...
          'Callback',{@AddCallback},...
          'BackgroundColor', background_color);
h_button_delete = uicontrol('Style','togglebutton','String','Delete',...
          'Position',[95,ypos,70,25],...
          'Callback',{@DeleteCallback},...
          'BackgroundColor', background_color);
h_button_problem = uicontrol('Style','togglebutton','String','Problem Area',...
          'Position',[180,ypos,100,25],...
          'Callback',{@ProblemCallback},...
          'BackgroundColor', background_color);

ypos = ypos - 30;

h_button_split_section = uicontrol('Style','pushbutton','String','Split Section',...
          'Position',[15,ypos,110,25],...
          'Callback',{@SplitSectionCallback},...
          'BackgroundColor', background_color);
h_button_split_all = uicontrol('Style','pushbutton','String','Split All',...
          'Position',[135,ypos,80,25],...
          'Callback',{@SplitAllCallback},...
          'Enable', 'on',...
          'BackgroundColor', background_color);

ypos = ypos - 30;

h_button_merge_fast = uicontrol('Style','pushbutton','String','Merge Fast',...
          'Position',[15,ypos,110,25],...
          'Callback',{@MergeFastCallback},...
          'BackgroundColor', background_color,...
          'Enable', 'on');
h_button_merge = uicontrol('Style','togglebutton','String','Merge',...
          'Position',[135,ypos,80,25],...
          'Callback',{@MergeCallback},...,
          'Enable', 'on',...
          'BackgroundColor', background_color);

ypos = ypos - 30;

h_button_accept = uicontrol('Style','pushbutton','String','Accept',...
          'Position',[15,ypos,70,25],...
          'Callback',{@AcceptCallback},...
          'BackgroundColor', background_color);
h_button_reject = uicontrol('Style','pushbutton','String','Reject',...
          'Position',[95,ypos,70,25],...
          'Callback',{@RejectCallback},...
          'BackgroundColor', background_color);
h_button_delete_all = uicontrol('Style','pushbutton','String','Delete All',...
          'Position',[175,ypos,80,25],...
          'Callback',{@DeleteAllCallback},...
          'BackgroundColor', background_color);

ypos = ypos - 30;


h_text_cell_type = uicontrol('Style','text','String','Cell type',...
            'Position',[15,ypos-5,70,15],...
            'HorizontalAlignment', 'left',...
            'BackgroundColor', background_color);
h_cell_type = uicontrol('Style','popupmenu','String',state.cell_type,...
           'Position',[75,ypos,95,15],...
           'Value', 1,... % Index into list of cell_types
           'BackgroundColor', background_color);      

       
ypos = ypos - 40;


h_button_find = uicontrol('Style','pushbutton','String','Find',...
          'Position',[15,ypos,70,25],...
          'Callback',{@FindCallback},...
          'BackgroundColor', background_color);
h_find_num = uicontrol('Style','edit','String','1',...
          'Position',[95,ypos,70,25],...
          'Callback',{@FindCallback},...
          'BackgroundColor', background_color);


ypos = ypos - 40;

% Set mode
if strcmp(state.mode,'add')
    set(h_button_add,'Value',true);
elseif strcmp(state.mode,'delete');
    set(h_button_delete,'Value',true);
elseif strcmp(state.mode,'problem');
    set(h_button_problem,'Value',true);
end

% Set alternate mode
if strcmp(state.mode_alt,'merge');
    set(h_button_merge,'Value',true);
end



% ----- 2d plot options -----    
h_text2 = uicontrol('Style','text','String','Left 2d plot',...
          'Position',[15, ypos,270,15],...
          'HorizontalAlignment', 'left',...
          'BackgroundColor', background_color);
ypos = ypos - 25;

h_button_comp1 = uicontrol('Style','radiobutton','String','Components (F4)',...
          'Position',[15,ypos,140,25],...
          'Callback',{@CompCallback, 1},...
          'Value', state.plot1_comp, ...
          'BackgroundColor', background_color);
h_button_image1 = uicontrol('Style','radiobutton','String','Images (F5)',...
          'Position',[155,ypos,100,25],...
          'Callback',{@ImageCallback, 1},...
          'Value', state.plot1_image,...
          'BackgroundColor', background_color);
ypos = ypos - 30;

h_text3 = uicontrol('Style','text','String','Right 2d plot',...
          'Position',[15, ypos,270,15],...
          'HorizontalAlignment', 'left',...
          'BackgroundColor', background_color);

ypos = ypos - 25;

h_button_comp2 = uicontrol('Style','radiobutton','String','Components (F6)',...
          'Position',[15,ypos,140,25],...
          'Callback',{@CompCallback, 2},...
          'Value', state.plot2_comp,...
          'BackgroundColor', background_color);
h_button_image2 = uicontrol('Style','radiobutton','String','Images (F7)',...
          'Position',[155,ypos,100,25],...
          'Callback',{@ImageCallback, 2},...
          'Value', state.plot2_image,...
          'BackgroundColor', background_color);

ypos = ypos - 20;

h_button_valid = uicontrol('Style','radiobutton','String','Valid (F8)',...
          'Position',[15,ypos,140,25],...
          'Callback',{@ValidCallback},...
          'Value', state.plot2_show_valid,...
          'BackgroundColor', background_color);
h_button_show_problem = uicontrol('Style','radiobutton','String','Problem (F9)',...
          'Position',[155,ypos,100,25],...
          'Callback',{@ShowProblemCallback},...
          'Value', state.plot2_show_problem,...
          'BackgroundColor', background_color);
      
      
% Listbox can't use multicolored text       
%h_comp_list = uicontrol('Style','listbox','String',{'Text1','Text2'},...
%           'ForegroundColor', [0 1 0], ...
%           'Position',[15, fig_text_height-110-150,250,150]);
    
ypos = ypos - 40;

% ----- 3d plot options -----    
h_text3 = uicontrol('Style','text','String','3d plot',...
          'Position',[15, ypos,270,15],...
          'HorizontalAlignment', 'left',...
          'BackgroundColor', background_color);
ypos = ypos - 25;

h_button_enable_3d = uicontrol('Style','radiobutton','String','Enabled (F10)',...
          'Position',[15,ypos,140,25],...
          'Callback',{@Enable3dCallback},...
          'Value', state.plot3d_enable, ...
          'BackgroundColor', background_color);

h_button_export_3d = uicontrol('Style','pushbutton','String','Export 3D',...
          'Position',[155,ypos,110,25],...
          'Callback',{@Export3dCallback},...
          'BackgroundColor', background_color);

ypos = ypos - 25;

h_button_plane_3d = uicontrol('Style','radiobutton','String','Image plane (F11)',...
          'Position',[15,ypos,140,25],...
          'Callback',{@Plane3dCallback},...
          'Value', state.plot3d_plane, ...
          'BackgroundColor', background_color);

    
% -------- 3d plot ----------
if small_screen
    fig_3d_width = screen_width - fig_text_width - 10; 
    fig_3d_height = screen_height - curb_height; 
    fig_3d_left = 0;
    fig_3d_margin = 20;
else
    fig_3d_width = screen_width/2 - fig_text_width - 40; 
    fig_3d_height = screen_height - curb_height; 
    fig_3d_left = screen_width/2 + fig_text_width + 20;
    fig_3d_margin = 80;
end

if ispc
    % Allow for the menu bar on Windows
    fig_3d_height = fig_3d_height - 30;
end

h_fig_3d = figure('Visible', 'off', ...
    'Position', [fig_3d_left, curb_height, fig_3d_width, fig_3d_height], ...
    'KeyPressFcn', {@KeyPressCallback}, ...
    'CloseRequestFcn', {@CloseFigCallback}, ...
    'Interruptible', 'off');

% For normal viewing 
h_plot5 = axes('Units', 'Pixels', 'Position', ...
    [ fig_3d_margin, fig_3d_margin, fig_3d_width - 2*fig_3d_margin, fig_3d_height - 2*fig_3d_margin] );


% Patches for the current 2d viewing plane, sliced through the 3d model
h_plane_z = 0;
h_plane_x = 0;
h_plane_y = 0;

% lighting handles
h_light_r = 0;
h_light_h = 0;

% For saving 3d plots
%h_plot3 = axes('Units', 'Pixels', 'Position', [ 0, 0, fig_3d_width, fig_3d_height] );
set(h_plot5, 'DataAspectRatio', [1 1 zratio]);
bounding_box_3d =  [ 0 sx 0 sy 0 sz ];
%bounding_box_3d = [ 20 120 20 120 8 92 ]; % X Y Z coordinates !
axis(bounding_box_3d);

set(gca,'XGrid','on');
set(gca,'YGrid','on');
set(gca,'ZGrid','on');
%set(gcf,'Color',[1 1 1]);   % Uncomment this for printing figures (make 3d
        % figure background white)

% Keeps the axis limits the same for all 3 axes.
%set(h_plot3,'PlotBoxAspectRatio',[1.0 1.0 .75]);

% Keeps the aspect ratio from being fit to the window while rotating
axis vis3d

% Turns off the visible axis lines
%axis off;
%keyboard

% --- Settings for all the windows

% Keep the axes properties from being recalculated
set(h_plot1, 'xlimmode','manual','ylimmode','manual','zlimmode','manual','climmode','manual','alimmode','manual');
set(h_plot2, 'xlimmode','manual','ylimmode','manual','zlimmode','manual','climmode','manual','alimmode','manual');
set(h_plot3, 'xlimmode','manual','ylimmode','manual','zlimmode','manual','climmode','manual','alimmode','manual');
set(h_plot4, 'xlimmode','manual','ylimmode','manual','zlimmode','manual','climmode','manual','alimmode','manual');
%set(h_plot3, 'xlimmode','manual','ylimmode','manual','zlimmode','manual','climmode','manual','alimmode','manual');

% Set the GUI window title
set(h_fig,'Name','Validate EM Components');
set(h_fig_text,'Name','Validate Info');
set(h_fig_3d,'Name','Validate 3d View');

% Move the GUI to the top screen (Centers)
% movegui(h_fig,'north');
% movegui(h_fig_text,'north');
% movegui(h_fig_3d,'north');

% Make the GUI visible.
set(h_fig,'Visible','on');
set(h_fig_3d,'Visible','on');
set(h_fig_text,'Visible','on');

% Keeps the Matlab command window from resuming focus
% when a key is hold down (to rapidly flip through the
% sections.)   The modal style removes the toolbars
% and menus, which may not be desired.  

% !! Unfortunately in WinXP, this seems to prevent
% any keyboard input from being received if more than
% one figure is modal, only the last one created 
% actually gets that property.  This seems to work ok
% if we only let the 2d window by modal.

%set(h_fig, 'WindowStyle', 'modal');

%if strcmp(computer,'PCWIN') == 0
%    set(h_fig_3d, 'WindowStyle', 'modal');
%    set(h_fig_text, 'WindowStyle', 'modal');
%end

% Load color_map (made with rand(50000,3) and saved)
try
    cc = load('component_colormap');
    color_map = cc.color_map;
    clear cc;
catch
    % File isn't there, so create it
    fprintf('Warning:  Color map not found, creating new color_map');
    color_map = rand(50000,3);
    save component_colormap color_map
end
color_map(1,:) = [0 0 0];


% ----- Initial display -----

RedrawAll;
%feature('memstats')

% ----- Main program loop -----
% No need for main loop anymore, make everything a callback.

% Make the GUI blocking
uiwait(h_fig);

return;



% ---- CloseUp -----
function CloseUp()

SaveCallback([],[]);

% ---- Clean up
delete(h_fig);
delete(h_fig_3d);
delete(h_fig_text);

return;

end

% --------------------------------------------------------------------------
% --------------------------- Callback functions ---------------------------
% --------------------------------------------------------------------------

%  See "Kinds of Callbacks" in Matlab help (Creating GUI->Programming GUI->Callbacks)

% These are all nested functions, so the nested functions have access to 
% all the local variables of their parents.

% ----- Save ----
function SaveCallback(h_pressed, event)
    
% Call the file requester
[new_filename, pathname] = uiputfile('*.mat', 'Validate:  Save file', valid_filename);

if isequal(new_filename, 0) || isequal(pathname,0)
    fprintf('Warning: Save canceled\n');
    
elseif isempty(new_filename)
    fprintf('Warning: filename is empty, not saving\n');
    
else
    valid_filename = new_filename;
    set(h_text_savename, 'String', sprintf('%s\n', valid_filename) );

    % ---- Save
    fprintf('Saving %s\n', valid_filename);
    save(valid_filename, 'valid_comp', 'valid_info', 'state', 'problem_area');
end

end


% ----- Add mode -----
function AddCallback(h_pressed, event)

%set(h_button_add)
%get(h_button_add)

if strcmp(state.mode,'add') 
    % Already in add mode, turn off
    state.mode = '';
    % The Value property of togglebuttons is automatically changed by
    % clicking on them
    %    set(h_button_add,'Value','off');
else
    % In some other mode, turn that off
    TurnOffMode();
    state.mode = 'add';
end

end

% ----- Delete mode -----
function DeleteCallback(h_pressed, event, handles)

if strcmp(state.mode,'delete') 
    % Already in delete mode, turn off
    state.mode = '';
else
    % In some other mode, turn that off
    TurnOffMode();    
    state.mode = 'delete';
end

end

% ----- Delete all current comps -----
function DeleteAllCallback(h_pressed, event, handles)

state.n_cur_comp = [];
state.n_cur_thresh = [];
cur_comp = SelectCurrentComponents;
RedrawAll();

end


% ----- Problem area mode -----
function ProblemCallback(h_pressed, event, handles)

if strcmp(state.mode,'problem') 
    % Already in problem mode, turn off
    state.mode = '';
else
    % In some other mode, turn that off
    TurnOffMode();    
    state.mode = 'problem';
    state.plot2_show_problem = true;
    set(h_button_show_problem,'Value', state.plot2_show_problem);
end

end


% ----- Suggest splits based on the currently displayed section -----
function SplitSectionCallback(h_pressed, event)

%    state.n_cur_comp = unique((cur_comp(:,:,state.z) > 0).* all_comps(:,:,state.z));
%    if(state.n_cur_comp(1) == 0) state.n_cur_comp(1) = []; end
%    cur_comp = SelectCurrentComponents;

split_found = false;

for i = 1:length(state.n_cur_comp)
    % Don't try to split a valid_comp
    c = state.n_cur_comp(i);
    th = state.n_cur_thresh(i);
    th_ind = find(state.thresholds == th);
    if th ~= 999
        % The section with the current component selected
        comp_sec = eval(  sprintf('all_comp_thresh.comp%d(:,:,state.z) == %d', th, c) ); 
        for j = th_ind+1:length(state.thresholds)
            % Section at next higher threshold
            th_higher = state.thresholds(j);
            higher_sec = eval(  sprintf('all_comp_thresh.comp%d(:,:,state.z) ', th_higher) ); 
            
            % Check for overlap
            new_c = unique(comp_sec .* higher_sec);
            if new_c(1) == 0
                new_c(1) = [];
            end
            if length(new_c) > 1
                % Ok we found more comps that match, add them 
                split_found = true;
                
                fprintf('SplitSectionCallback: Split %d (th %d) into', c, th);
                fprintf(' %d', new_c);
                fprintf(' (th %d)\n', th_higher);
                
                size(new_c)
                size(state.n_cur_comp)
                state.n_cur_comp = [state.n_cur_comp  new_c'];
                state.n_cur_thresh = [state.n_cur_thresh  th_higher.*ones(size(new_c'))];
                state.n_cur_comp(i) = [];
                state.n_cur_thresh(i) = [];
                state.thresh = th_higher;
                state.thresh_ind = j;
                break;
            end
            

        end

    end
        
    if split_found
        break;
    end
end
       
if split_found
    cur_comp = SelectCurrentComponents;
    all_comps = eval(sprintf('all_comp_thresh.comp%d', state.thresh));
    RedrawAll;
else
    warndlg('No splits found in the current section', 'Split Section:  Warning',  'replace');
end
    
end


% ----- Suggest splits based on the whole components -----
function SplitAllCallback(h_pressed, event)

split_found = false;

for i = 1:length(state.n_cur_comp)
    % Don't try to split a valid_comp
    c = state.n_cur_comp(i);
    th = state.n_cur_thresh(i);
    th_ind = find(state.thresholds == th);
    if th ~= 999 & th_ind <= length(state.thresholds)
        % Find the components in the next highest threshold
        th_next = state.thresholds(th_ind+1);
        comp_next = eval(sprintf('all_comp_thresh.comp%d', th_next));

        % Find the components in the next highest threshold level
        % that overlap with the current threshold.
        comp_split = (cur_comp & comp_next) .* comp_next;
        uni_split = unique(comp_split);

        if uni_split(1) == 0
            uni_split(1) = [];
        end

        if isempty(uni_split)
            fprintf('SplitAll:  Warning: No matching components in compB\n');
        elseif length(uni_split) == length(state.n_cur_comp)
            fprintf('SplitAll:  Warning: comp_big is not split\n');
        else
            fprintf('SplitAll:  comps can be split into %d\n', uni_split);
            split_found = true;
            state.n_cur_comp = uni_split;
            state.n_cur_thresh = th_next .* ones(size(state.n_cur_comp));
            state.thresh = th_next;
            state.thresh_ind = th_ind+1;
        end
        
    end
    
    if split_found
        break;
    end
end

if split_found
    cur_comp = SelectCurrentComponents;
    all_comps = eval(sprintf('all_comp_thresh.comp%d', state.thresh));
    RedrawAll;
else
    warndlg('No splits found for current components', 'SplitAll Section:  Warning',  'replace');
end

end


% ----- Finds possible mergers of the current object with the valid set -----
function MergeFastCallback(h_pressed, event)

% Tolerance on the bounding box, add extra voxels to bounding box
bb_tol = 5;  

merge_found = false;

[min_yxz, max_yxz] = FindBoundingBoxComp(cur_comp);
min_yxz = min_yxz - bb_tol;
min_yxz = max(min_yxz,1);

max_yxz = max_yxz + bb_tol;
max_yxz = min(max_yxz, [sy sx sz]);

valid_sub = valid_comp( min_yxz(1):max_yxz(1),  min_yxz(2):max_yxz(2),  min_yxz(3):max_yxz(3) );
uni_valid = unique(valid_sub);
if uni_valid(1) == 0
    uni_valid(1) = [];
end

if length(uni_valid) > 1
    % Add these components to the current set
    merge_found = true;
    state.n_cur_comp = cat(2,state.n_cur_comp, uni_valid');
    state.n_cur_thresh = cat(2,state.n_cur_thresh, 999*ones(size(uni_valid')) );
end

if merge_found
    cur_comp = SelectCurrentComponents;
    RedrawAll;
else
    warndlg('No mergers found for current components', 'Merge Fast:  Warning',  'replace');
end

end

% ----- Finds possible mergers of the current components using diffusion -----
function MergeCallback(h_pressed, event)

    
if strcmp(state.mode_alt,'merge') 
    % Already in merge mode, turn off
    state.mode_alt = '';
    
else
    % In some other alt mode, turn that off
    TurnOffModeAlt();    
    state.mode_alt = 'merge';

    % Get the range of objects to consider for mergers
    prompt = {'Min object number:','Max object number:'};
    dlg_title = 'Merge: Range of object numbers to examine';
    num_lines = 1;
    text_answer = inputdlg(prompt,dlg_title,num_lines);
    
    % Answer is returned as text string
    state.merge.range = str2num(text_answer{1}):str2num(text_answer{2});
    
    % Select the components used as merge targets
    % (Vector fields are not calculated for these, only for
    % the range entered in the dialog box).
    
    % Components are already sorted, and we have sizes so
    % only need to select the components
    %[sizes, list] = ComponentSizes(comps);
    %[tmp,idx]=sort(abs(sizes-thresh),'ascend');
    %comps = SelectComponents(comps, list(3:idx));

    merge_thresh = 20;
    sizes = eval(sprintf('all_comp_thresh.sizes%d', state.thresh ));
    ind = find(sizes < merge_thresh);
    if isempty(ind)
        sz_ind = length(sizes);
    else
        sz_ind = ind(1);
    end
    state.merge.comps = SelectComps( all_comps, 3:sz_ind );
    state.merge.list = 1:length(sizes);  % Components already in size order
    state.merge.merge_list = [];
    state.merge.current =  state.merge.range(end);
    
    for mc_i=1:length(state.merge.range)
        [n_comp, n_thresh, state] = FindMerges(state, valid_comp);
        if ~isempty(n_comp)
            state.n_cur_comp = n_comp;
            state.n_cur_thresh = n_thresh;
            cur_comp = SelectCurrentComponents;
            RedrawAll;
            break;
        end
    end
    
    if isempty(n_comp)
        % Didn't find any merges this iteration
        warndlg('Did not find any merges this iteration', 'FindMerges');
    end
    
end

end


% ----- Accept current set of components -----
function AcceptCallback(h_pressed, event, handles)

%!! Need to change to do checking for multiple threshold components

if isempty(state.n_cur_comp)
    warndlg('No components in list, nothing to do', 'Validate:  Warning',  'replace');

%elseif length(find(state.n_cur_thresh==999)) > 1
%    % Check for multiple valid components    
%    warndlg('Merging multiple valid components is not supported', 'Validate:  Warning',  'replace');

else
    h_waitbar = waitbar(0,'Accepting...');
    
    undo.n_cur_comp = state.n_cur_comp;
    undo.n_cur_thresh = state.n_cur_thresh;
    
    v_ind = find(state.n_cur_thresh==999);
    if ~isempty(v_ind)
 %       % Add the additional components to the existing valid component
 %       n = state.n_cur_comp(v_ind);
 %       start_ind = length(valid_info(n).constituent) 
 %       state.n_cur_thresh(v_ind) = [];
 %       state.n_cur_comp(v_ind) = [];
 
 		% V. JAIN 6/7: delete existing valid components 
 		for ii=1:length(state.n_cur_thresh)
 			if(state.n_cur_thresh(ii)==999)
 				valid_info(state.n_cur_comp(ii)).deleted=true;
 				valid_comp=DeleteComponents(valid_comp, state.n_cur_comp(ii));
 			end
 		end
 		
 	end
   
    n = state.n_valid + 1;
    state.n_valid = n;
    start_ind = 0;
    
    % Add currently select components as a new valid comp to the valid stack
    add_comp = n * (cur_comp ~= 0);
    
    waitbar(1/3);
    
    % Check overlap, find the valid comps
    overlap = (cur_comp .* valid_comp > 0) .* valid_comp;
    unique_overlap = unique(overlap);
    if unique_overlap(1) == 0
        unique_overlap(1) = [];
    end
    
    % If there is any overlap, except with the valid comp that is in cur_comp
    % then this is an error.  
    if ~isempty(unique_overlap) & any(unique_overlap ~= n)
        % Proposed component overlaps with other valid comps
        close(h_waitbar);
        unique_overlap
        errordlg(['Component overlaps with other valid comps ' num2str(unique_overlap)], ...
            'Validate:  Error',  'on');
        state.n_cur_comp= undo.n_cur_comp;
        state.n_cur_thresh = undo.n_cur_thresh;
    else
    
        valid_comp = add_comp .* (valid_comp == 0) + valid_comp;

        valid_info(n).comp_num = n;    
        valid_info(n).cell_type = state.cell_type{get(h_cell_type,'Value')};   
        [min_yxz, max_yxz] = FindBoundingBoxComp(add_comp);
        valid_info(n).min_yxz = min_yxz;
        valid_info(n).max_yxz = max_yxz;

        for i = 1:length(state.n_cur_comp)
            valid_info(n).constituent(start_ind+i).comp_num = state.n_cur_comp(i);
            valid_info(n).constituent(start_ind+i).thresh = state.n_cur_thresh(i); 
            valid_info(n).constituent(start_ind+i).filename = state.cur_comp_thresh_filename;  
        end

        % Delete current set of components and redraw
        state.n_cur_comp = [];
        state.n_cur_thresh = [];

        waitbar(2/3);
        cur_comp = SelectCurrentComponents;        

        close(h_waitbar);
        RedrawAll;
    end
end
   
% If we are in the merge mode, than after we accept this component
% we want to have another potential merge suggested to us.

if strcmp(state.mode_alt,'merge')
    
    for ac_i=1:length(state.merge.range)
        [n_comp, n_thresh, state] = FindMerges(state, valid_comp);
        if ~isempty(n_comp)
            state.n_cur_comp = n_comp;
            state.n_cur_thresh = n_thresh;
            cur_comp = SelectCurrentComponents;
            RedrawAll;
            break;
        end
    end
    
    if isempty(n_comp)
        % Didn't find any merges this iteration
        warndlg('Did not find any merges this iteration', 'FindMerges');
    end
    
end

end
    
% ----- Reject current set of components -----
function RejectCallback(h_pressed, event, handles)
% Reject the currently selected set of components

ind = find(state.n_cur_thresh == 999);

% V. JAIN 6/7, instead of refusing to reject a valid component, 
% we now add a "deleted==true" flag to its info, and remove 
% it from the valid_comps.
if ~isempty(ind)
	for ii=1:length(state.n_cur_thresh)
		if(state.n_cur_thresh(ii)==999)
			valid_info(state.n_cur_comp(ii)).deleted=true;
			valid_comp=DeleteComponents(valid_comp, state.n_cur_comp(ii));
		end
	end
end


% Add the components to the reject_info
r_ind = length(state.reject) + 1;

state.reject{r_ind}.n_comp = state.n_cur_comp;
state.reject{r_ind}.n_thresh = state.n_cur_thresh;

state.n_cur_comp = [];
state.n_cur_thresh = [];
cur_comp = SelectCurrentComponents;
RedrawAll();
    

% If we are in the merge mode, than after we reject this component
% we want to have another potential merge suggested to us.

if strcmp(state.mode_alt,'merge')
    
    for rc_i=1:length(state.merge.range)
        [n_comp, n_thresh, state] = FindMerges(state, valid_comp);
        if ~isempty(n_comp)
            state.n_cur_comp = n_comp;
            state.n_cur_thresh = n_thresh;
            cur_comp = SelectCurrentComponents;
            RedrawAll;
            break;
        end
    end
    
    if isempty(n_comp)
        % Didn't find any merges this iteration
        warndlg('Did not find any merges this iteration', 'FindMerges');
    end
    
end

end

    
% ----- Click in text window on a component button -----
function CompListCallback(h_pressed, event, n_list)
% n_list - Number in comp list

if n_list <= length(state.n_cur_comp)
    % If there was actually a comp at this button location
    
    if strcmp(state.mode, 'delete')
        state.n_cur_comp(n_list) = []; 
        state.n_cur_thresh(n_list) = [];
        cur_comp = SelectCurrentComponents;
        RedrawAll;
    
    else
        % Put the z slice in the middle of this component
        state.thresh = state.n_cur_thresh(n_list);  
        [zmin, zmax, zmid] = GetCompZRange(state.n_cur_comp(n_list), state.thresh);
        state.z = zmid;
        %!! ok now?
        RedrawText;
        Redraw2dPlots;
    end

end


end

% ----- Find the given component number -----
function FindCallback(h_pressed, event)

n_str = get(h_find_num, 'String');
state_change = false;

if any(isletter(n_str))
    warndlg('Characters not allowed in Find', 'Find:  Warning',  'replace');
    return;
end

try
    n = eval(strcat('[',n_str,']'));
catch
    warndlg('Could not parse Find', 'Find:  Warning',  'replace');
    return;
end

if isempty(n)
    warndlg('Unrecognized string in Find', 'Find:  Warning',  'replace');
else
    for i = 1:length(n)
        % Add each component to the current comp list
        nc = min( n(i), GetNumCompsAtThresh(state.thresh) );
				
		% V. JAIN 6/7: don't add a validated component that was deleted        
        if((state.thresh==999) && isfield(valid_info(n(i)),'deleted') && isequal(valid_info(n(i)).deleted,true))
        	fprintf('Valid component %d has been deleted.\n', nc );

        elseif state.thresh == 999 && isempty(valid_info(nc).comp_num)
            % This shouldn't happen, but it seems to exist in certain
            % validated files (JFM 8/7/2007)
            fprintf('Valid component %d does not exist.\n', nc );
        
        elseif ~isempty( FindCurrentComponent( nc, state.thresh) )
            % Found this comp already
            fprintf('FindCallback:  Already selected comp %d (thresh %d)\n', nc, state.thresh);
          
        elseif nc > 0 
            % Add this comp
            state.n_cur_comp(end+1) = nc;
            state.n_cur_thresh(end+1) = state.thresh;
            state_change = true;
        end
    end
    
end

if state_change
    cur_comp = SelectCurrentComponents;
    RedrawAll;
end

end


% ----- Toggle state of component display in 2d plots -----
function CompCallback(h_pressed, event, n_plot)
% n_plot - Number of 2d plot (1 or 2)

if n_plot == 1
    state.plot1_comp = ~state.plot1_comp;
else
    state.plot2_comp = ~state.plot2_comp;
end

Redraw2dPlots;
RedrawText;

end

% ----- Toggle state of image display in 2d plots -----
function ImageCallback(h_pressed, event, n_plot)
% n_plot - Number of 2d plot (1 or 2)

if n_plot == 1
    state.plot1_image = ~state.plot1_image;
else
    state.plot2_image = ~state.plot2_image;
end

Redraw2dPlots;
RedrawText;

end


% ----- Toggle display valid or currently selected components in 2d plot -----
function ValidCallback(h_pressed, event)

state.plot2_show_valid = ~state.plot2_show_valid;

if state.plot2_show_valid
    state.thresh = 999;
else
    state.thresh = state.thresholds(state.thresh_ind);
end
%!! Set state.thresh = 999

Redraw2dPlots;
RedrawText;

end


% ----- Toggle display of problem areas in 2d plot -----
function ShowProblemCallback(h_pressed, event)

state.plot2_show_problem = ~state.plot2_show_problem;
Redraw2dPlots;
RedrawText;

end

% ----- Toggle 3d plot display -----
function Enable3dCallback(h_pressed, event)

state.plot3d_enable = ~state.plot3d_enable;
Redraw3dPlot;
RedrawText;

end


% ----- Toggle display of image plane 3d plot -----
function Plane3dCallback(h_pressed, event)

state.plot3d_plane = ~state.plot3d_plane;
Redraw3dPlot;
RedrawText;

end

% ----- Export the 3d figure to other file formats -----
function Export3dCallback(h_pressed, event)

% User selected 3d output type
[sel, ok] = listdlg('PromptString','Select 3d output format',...
                'SelectionMode','single',...
                'ListString',{'vrml', 'stl (ASCII)'});
            
if ok
    % Get filename to save
    [new_filename, pathname] = uiputfile({'*.wrl','*.stl'}, 'Validate:  Export 3d file');

    if isequal(new_filename, 0) | isequal(pathname,0)
        fprintf('Warning: Export 3d canceled\n');
    elseif sel == 1
        % Save as VRML
        vrml(h_fig_3d, new_filename);
    elseif sel == 2
        % Save as stl (ASCII)
        % Need to get face/vertex structure
        stl_write(h_fig_3d, new_filename);
    end

end

end

% ----- Mouse click in text window callback -----
function ButtonDownTextCallback(h_pressed, event, handles)

%disp('ButtonDownTextCallback');

%eventdata

%h_pressed
%keyboard

end


% ----- Mouse click in 2d plot window callback -----
function ButtonDown2dPlotCallback(h_pressed, event, handles)

%disp('ButtonDown2dPlotCallback');

h_hit_plot = get(h_pressed, 'CurrentAxes');
pt = get(h_hit_plot, 'currentpoint');
x = ceil(pt(1,1));
y = ceil(pt(1,2));

if x >= 1 && x <= size(cur_comp,2) && y >= 1 && y <= size(cur_comp,1)
    % We've clicked inside the plot axes
    %fprintf('Clicked in plot1 or 2 (%d %d)\n', x, y);
    
    if state.thresh == 999
        nc = valid_comp(y, x, state.z);
    else
        nc = all_comps(y, x, state.z);
    end
    
    if nc ~= 0 && strcmp(state.mode, 'add')        
        
        % !! Need better checking
       
        % Do want to allow adding valid_comps to the list, just want
        % to checking at Accept
      %  if FindCurrentComponent(nc, state.thresh)   % !! Looks ok for state.thresh = 999
      %      fprintf('Component %d (thresh %d) is already added\n', nc, state.thresh);
      %  else
            % Ok, passed the checks, can add this comp
            state.n_cur_comp(end+1) = nc;
            state.n_cur_thresh(end+1) = state.thresh;
            cur_comp = SelectCurrentComponents;

            RedrawAll;
      %  end
    
    elseif nc ~= 0 && strcmp(state.mode, 'delete')
        ind = FindCurrentComponent(nc, state.thresh);
                
        if ~isempty(ind)
            state.n_cur_comp(ind) = [];
            state.n_cur_thresh(ind) = [];
            cur_comp = SelectCurrentComponents;

            RedrawAll;        
        end
        
    elseif strcmp(state.mode, 'problem')
        % Add this location to the list of problem areas
        if isempty( problem_area(state.z).loc )
            fprintf('ButtonDown2dPlot/Problem:  1st problem in slice (%d %d %d)\n', y, x, state.z);
            problem_area(state.z).loc{1} = [y x state.z];
        elseif isempty( problem_area(state.z).loc{end} ) 
            fprintf('ButtonDown2dPlot/Problem:  Problem in slice/end (%d %d %d)\n', y, x, state.z);
            problem_area(state.z).loc{end} = [y x state.z];
        else
            fprintf('ButtonDown2dPlot/Problem:  Problem in slice/end+1 (%d %d %d)\n', y, x, state.z);
            problem_area(state.z).loc{end+1} = [y x state.z];
        end

        Redraw2dPlots;
    end
    
end

% This doesn't really help determine which axes we're in
%h_hit2 = ancestor(hittest(h_pressed),'axes')

% This also doesn't give the right axes
%if h_hit_plot == h_plot1
%    fprintf('Clicked in plot1 (%d %d)\n', x, y);
%elseif h_hit_plot == h_plot2
%    fprintf('Clicked in plot2 (%d %d)\n', x, y);
%else
%    fprintf('Clicked somewhere else (%d %d)\n', x, y);
%end
%eventdata
%get(h_pressed,'CurrentPosition');
%keyboard    

end


% ----- Keypress -----
function KeyPressCallback(h_source, event)

persistent saved

key = event.Key;
char = event.Character;
%fprintf('KeyPressCallback:  %s  %s...', key, char);

% Up 1 section
if strcmp(key,'uparrow')  
	if state.z ~= min(sz,state.z+1),
		state.z = min(sz,state.z+1);
		Redraw3dPlane();
        RedrawText();
        Redraw2dPlots();
    end
    
elseif strcmp(key,'downarrow') 
    % Down 1 section
	if state.z ~= max(1,state.z-1),
		state.z = max(1,state.z-1);
		Redraw3dPlane();
        RedrawText();
        Redraw2dPlots();
    end

elseif strcmp(char,'5')
	% decrease x plane
	if state.x ~= max(1,state.x-1),
		state.x = max(1,state.x-1);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end
    
elseif strcmp(char,'6')
	% increase x plane
	if state.x ~= min(sx,state.x+1),
		state.x = min(sx,state.x+1);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end
    
elseif strcmp(char,'7')
	% decrease y plane
	if state.y ~= max(1,state.y-1),
		state.y = max(1,state.y-1);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end
    
elseif strcmp(char,'8')
	% increase y plane
	if state.y ~= min(sy,state.y+1),
		state.y = min(sy,state.y+1);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end

elseif strcmp(char,'%')
	% decrease x plane
	if state.x ~= max(1,state.x-10),
		state.x = max(1,state.x-10);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end
    
elseif strcmp(char,'^')
	% increase x plane
	if state.x ~= min(sx,state.x+10),
		state.x = min(sx,state.x+10);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end
    
elseif strcmp(char,'&')
	% decrease y plane
	if state.y ~= max(1,state.y-10),
		state.y = max(1,state.y-10);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end
    
elseif strcmp(char,'*')
	% increase y plane
	if state.y ~= min(sy,state.y+10),
		state.y = min(sy,state.y+10);
		Redraw3dPlane();
		RedrawText();
		Redraw2dPlots();
	end
    
elseif strcmp(key,'leftarrow')
    % Down threshold
    %!! If valid is selected, then return to regular thresh comps
    if state.thresh == 999
        state.thresh = state.thresholds(state.thresh_ind);
        set(h_button_valid,'Value',false);
        state.plot2_show_valid = false;
    else
        state.thresh_ind = max(1,state.thresh_ind-1);
        state.thresh = state.thresholds(state.thresh_ind);
        all_comps = eval(sprintf('all_comp_thresh.comp%d', state.thresh));
    end
    
    RedrawText();
    Redraw2dPlots();

elseif strcmp(key,'rightarrow')
    % Up threshold
    %!! If valid is selected, then return to regular thresh comps
    if state.thresh == 999
        state.thresh = state.thresholds(state.thresh_ind);
        set(h_button_valid,'Value',false);
        state.plot2_show_valid = false;
    else
        state.thresh_ind = min(state.thresh_ind+1, length(state.thresholds));
        state.thresh = state.thresholds(state.thresh_ind);
        all_comps = eval(sprintf('all_comp_thresh.comp%d', state.thresh));
    end
    
    RedrawText();
    Redraw2dPlots();
    

elseif(strcmp(key,'pageup') | key == 'q') % Need to keep the single |, ignore Matlab's lint
    % Up 10 sections
    if state.z < sz
        state.z = state.z + 10;
        state.z = min(state.z,sz);
        
        % Move the display of the current slice
        %vertex = [ 0 0 state.z ; sy 0 state.z ; 0 sx state.z ; sy sx state.z ];
        %set(h_plane,'Vertices', vertex);

		Redraw3dPlane();
        RedrawText();
        Redraw2dPlots();
    end

elseif(strcmp(key,'pagedown') | key == 'a')
    % Down 10 sections
    if state.z > 1
        state.z = state.z - 10;
        state.z = max(state.z,1);
        
        % Move the display of the current slice
        %vertex = [ 0 0 state.z ; sy 0 state.z ; 0 sx state.z ; sy sx state.z ];
        %set(h_plane,'Vertices', vertex);

		Redraw3dPlane();
        RedrawText();
        Redraw2dPlots();
    end

elseif(char == ']') 
    % Next component up
    if length(state.n_cur_comp) > 0
        if state.n_cur_comp(end) < GetNumCompsAtThresh(state.n_cur_thresh(end)) 
            state.n_cur_comp(end) = state.n_cur_comp(end) + 1; 
            %if state.thresh > 0 %!! Should be able to find zmid of valid_comps
                state.thresh = state.n_cur_thresh(end);
                [zmin, zmax, zmid] = GetCompZRange(state.n_cur_comp(end), state.thresh);
                state.z = zmid;
            %end
            cur_comp = SelectCurrentComponents;
            RedrawAll;
        end
    end
    
elseif(char == '[') 
    % Next component down
    if length(state.n_cur_comp) > 0
        if state.n_cur_comp(end) > 1;
            state.n_cur_comp(end) = state.n_cur_comp(end) - 1; 
            %if state.thresh > 0  %!! Should be able to find zmid of valid_comps
                state.thresh = state.n_cur_thresh(end);
                [zmin, zmax, zmid] = GetCompZRange(state.n_cur_comp(end), state.thresh);
                state.z = zmid;
            %end
            cur_comp = SelectCurrentComponents;
            RedrawAll;
        end
    end

    % Right stick controls
elseif(key == 'j')
    % Rotate 3d plot around horizontal axis
    axes(h_plot5); camorbit(6, 0); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

%    frame = frame + 1
%    print(gcf, '-dtiff', '-r75', sprintf('frame%03d.tiff', frame) );

elseif(key == 'k')
    % Rotate 3d plot around horizontal axis
    axes(h_plot5); camorbit(-6, 0); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

elseif(key == 'i')
    % Rotate 3d plot around vertical axis
    axes(h_plot5); camorbit(0, 5); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

elseif(key == 'm')
    % Rotate 3d plot around vertical axis
    axes(h_plot5); camorbit(0, -5); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

    % Left stick controls
elseif(key == 'd')
    % Move 3d plot on horizontal axis
    axes(h_plot5); camdolly(-.2,0,0); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

elseif(key == 'f')
    % Move 3d plot on horizontal axis
    axes(h_plot5); camdolly(.2,0,0); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

elseif(key == 'r')
    % Move 3d plot on vertical axis
    axes(h_plot5); camdolly(0,.2,0); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

elseif(key == 'c')
    % Move 3d plot on vertical axis
    axes(h_plot5); camdolly(0,-.2,0); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;
    
    % Forward back 3d controls
elseif(key == 'w')
    % Move 3d plot forward
    axes(h_plot5); camzoom(1.1); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;

elseif(key == 's')
    % Move 3d plot backwards
    axes(h_plot5); camzoom(0.9); camlight(h_light_r,'right'); camlight(h_light_h,'headlight'); drawnow;
    
elseif(char == '!')
    % Save the current plot view
    axes(h_plot5);
    saved.CameraViewAngle = get(gca,'CameraViewAngle');
    saved.CameraUpVector = get(gca,'CameraUpVector');
    saved.OuterPosition = get(gca,'OuterPosition');
    saved.CameraPosition = get(gca,'CameraPosition')
    
elseif(key == '1')
    % Restore the saved plot view
    axes(h_plot5);
    if exist('saved','var')
        fprintf('Restoring view.\n');
        set(gca,'CameraViewAngle',saved.CameraViewAngle)
        set(gca,'CameraUpVector',saved.CameraUpVector);
        set(gca,'OuterPosition',saved.OuterPosition);
        set(gca,'CameraPosition',saved.CameraPosition);
        drawnow;
    end
    
        
elseif strcmp(key,'f4')
    % Toggle comp view in plot 1
    val = ~get(h_button_comp1,'Value');
    state.plot1_comp = val;
    set(h_button_comp1,'Value',val);
    Redraw2dPlots;
    RedrawText;
    
elseif strcmp(key,'f5')
    % Toggle image view in plot 1
    val = ~get(h_button_image1,'Value');
    state.plot1_image = val;
    set(h_button_image1,'Value',val);
    Redraw2dPlots;
    RedrawText;
    
elseif strcmp(key,'f6')
    % Toggle comp view in plot 2
    val = ~get(h_button_comp2,'Value');
    state.plot2_comp = val;
    set(h_button_comp2,'Value',val);
    Redraw2dPlots;
    RedrawText;

elseif strcmp(key,'f7')
    % Toggle image view in plot 2
    val = ~get(h_button_image2,'Value');
    state.plot2_image = val;
    set(h_button_image2,'Value',val);
    Redraw2dPlots;
    RedrawText;

elseif strcmp(key,'f8')
    % Toggle valid or selected comps in plot 2
    val = ~get(h_button_valid,'Value');
    state.plot2_show_valid = val;
    if state.plot2_show_valid  % !! ok?
        state.thresh = 999;
    else
        % Return to the previous threshold level
        state.thresh = state.thresholds(state.thresh_ind);
    end
    set(h_button_valid,'Value',val);
    Redraw2dPlots;
    RedrawText;

elseif strcmp(key,'f9')
    % Toggle problem areas in plot 2
    val = ~get(h_button_show_problem,'Value');
    state.plot2_show_problem = val;
    set(h_button_show_problem,'Value',val);
    Redraw2dPlots;
    RedrawText;

elseif strcmp(key,'f10')
    % Toggle enable 3d plot
    val = ~get(h_button_enable_3d,'Value');
    state.plot3d_enable = val;
    set(h_button_enable_3d,'Value',val);
    RedrawText;
    Redraw3dPlot;

elseif strcmp(key,'f11')
    % Toggle enable image plane in 3d plot
    val = ~get(h_button_plane_3d,'Value');
    state.plot3d_plane = val;
    set(h_button_plane_3d,'Value',val);
    RedrawText;
    Redraw3dPlot;

elseif(strcmp(key,'escape'))
    CloseUp;
end

%fprintf('done\n', key, char);

end



% ----- Turns off the current mode -----
function TurnOffMode()
    
if strcmp(state.mode,'')
    % No mode, return
elseif strcmp(state.mode,'add')
    state.mode = '';
    set(h_button_add,'Value',0);
elseif strcmp(state.mode,'delete')
    state.mode = '';
    set(h_button_delete,'Value',0);
elseif strcmp(state.mode,'problem');
    state.mode = '';
    set(h_button_problem,'Value',0);
end
    
    
end

% ----- Turns off the current alt mode -----
function TurnOffModeAlt()

if strcmp(state.mode_alt,'')
    % No mode, return
elseif strcmp(state.mode_alt,'merge')
    state.mode = '';
    set(h_button_merge,'Value',0);
end
    
    
end


% ----- Resize 2d window figures callback -----
function Resize2dCallback(h_pressed, event)

% Find the new window size
fpos2d = get(h_fig,'Position');
fig_width = fpos2d(3);
fig_height = fpos2d(4);

plot_width = round(fig_width / 2) - 30;
plot_height = round(fig_height / 2) - 60;

set(h_plot1, 'Position', [ 20, 30, plot_width, plot_height] );
set(h_plot2, 'Position', [ plot_width + 40, 30, plot_width, plot_height] );
set(h_plot3, 'Position', [ 20, plot_height + 80, plot_width, plot_height] );
set(h_plot4, 'Position', [ plot_width + 40, plot_height + 80, plot_width, plot_height] );

% Get the exact size in pixels of these windows
pos = get(h_plot1, 'Position');
plot_width = pos(3);
plot_height = pos(4);

    
end



% ----- Close figure callback -----
function CloseFigCallback(h_pressed, event, handles)

CloseUp();


end

% --------------------------------------------------------------------------
% ------------------ Graphics functions (nested functions) -----------------
% --------------------------------------------------------------------------

% ----- RedrawAll 3 figures ------
function RedrawAll()

Redraw3dPlot;
RedrawText;
Redraw2dPlots;

end

% ----- Redraw2dPlotsCompute ------
function Redraw2dPlotsCompute()
% Redraw the 2 component plots (usually after changing the section
% or the components.
%
% Assumes the original images (sem_image) are scaled to [0,1],
% causes errors if not.


if state.plot1_image == true || state.plot2_image == true
    over_im_z = squeeze(sem_image(:,:,state.z,:));
    over_im_x = permute(squeeze(sem_image(:,state.x,:,:)),[2 1 3]);
    over_im_y = permute(squeeze(sem_image(state.y,:,:,:)),[2 1 3]);
	if size(sem_image,4) == 1,	% if not color image
		over_im_z = repmat(over_im_z,[1 1 3]);
		over_im_x = repmat(over_im_x,[1 1 3]);
		over_im_y = repmat(over_im_y,[1 1 3]);
	end
end

% -- Plot 1
axes(h_plot1);

if state.plot1_comp == true
    img = cur_comp(:,:,state.z);
    img = ind2rgb(int32(img(:,:))+int32(img(:,:)~=0), color_map);
else
    img = zeros(sy,sx,3);
end

if state.plot1_image == true
    % Overlay components on sem_image
    im_mask = (img == 0);

    img = over_im_z .* img;
    img = img + over_im_z .* im_mask;  

else
    % Draw components on black background
end

image(img);  %,'EraseMode','none');     % Causes flicker
hold on
plot([1 sx],[state.y state.y],'y-',[state.x state.x],[1 sy],'y-')
hold off
axis xy, axis equal, axis tight

% -- Plot 3
axes(h_plot3);

if state.plot1_comp == true
    img = squeeze(cur_comp(:,state.x,:))';
    img = ind2rgb(int32(img(:,:))+int32(img(:,:)~=0), color_map);
else
    img = zeros(sy,sx,3);
end

if state.plot1_image == true
    % Overlay components on sem_image
    im_mask = (img == 0);

    img = over_im_x .* img;
    img = img + over_im_x .* im_mask;

else
    % Draw components on black background
end

image(img);  %,'EraseMode','none');     % Causes flicker
hold on
plot([1 sy],[state.z state.z],'y-',[state.y state.y],[1 sz],'y-')
hold off
axis xy, axis equal, axis tight

% -- Plot 4
axes(h_plot4);

if state.plot1_comp == true
    img = squeeze(cur_comp(state.y,:,:))';
    img = ind2rgb(int32(img(:,:))+int32(img(:,:)~=0), color_map);
else
    img = zeros(sy,sx,3);
end

if state.plot1_image == true
    % Overlay components on sem_image
    im_mask = (img == 0);

    img = over_im_y .* img;
    img = img + over_im_y .* im_mask;

else
    % Draw components on black background
end

image(img);  %,'EraseMode','none');     % Causes flicker
hold on
plot([1 sx],[state.z state.z],'y-',[state.x state.x],[1 sz],'y-')
hold off
axis xy, axis equal, axis tight

% -- Plot 2
axes(h_plot2);

if state.plot2_comp == true
    if state.plot2_show_valid
        img = valid_comp(:,:,state.z);
    else
        img = all_comps(:,:,state.z);
    end
    img = ind2rgb(int32(img(:,:))+int32(img(:,:)~=0), color_map);
else
    img = zeros(sy,sx,3);
end

if state.plot2_image == true
    % Overlay components on sem_image
    im_mask = (img == 0);

    img = over_im_z .* img;
    img = img + over_im_z .* im_mask;

else
    % Draw components on black background
end

if state.plot2_show_problem && ~isempty(problem_area(state.z).loc)
    % Display all the problem areas as +'s over the plot
    pa = problem_area(state.z).loc;
    for r2_i = 1:length(pa)
        loc = pa{r2_i};
        if numel(loc) ~= 0
            % Coordinates of + to draw
            y1 = max(1, loc(1)-5);
            y2 = min(sy, loc(1)+5);
            x1 = max(1, loc(2)-5);
            x2 = min(sx, loc(2)+5);

            img(y1:y2, loc(2), 1) = 1;
            img(loc(1), x1:x2, 1) = 1;
        end
    end
end

image(img); %,'EraseMode','none');     
axis xy, axis equal, axis tight


end % Redraw2dPlotsCompute

% ----- Redraw2dPlots ------
function Redraw2dPlots()
% Redraw the 2 component plots (usually after changing the section
% or the components.
focus_fig = gcf;
Redraw2dPlotsCompute();
figure(focus_fig);
return; 
% 
% % -- Plot 1
% axes(h_plot1);
% image(state.plot1_img(:,:,:,state.z));
% 
% % -- Plot 2
% axes(h_plot2);
% image(state.plot2_img(:,:,:,state.z));

end % Redraw2dPlots

% 23 sec on winfried with 3d window, 9 sec without using Plot2dCompute
% Using new Plot2d(precomputed) about the same :(


% % ----- Compute2dPlot ------
% function img_out = Compute2dPlot(img_in, width, height, overlay)
% % Precompute the 2d images for each section
% 
% if ~exist('overlay','var')
%     overlay = false;
% end
% 
% fprintf('Compute2dPlots...');
% 
% img_out = zeros([height, width, 3, size(img_in,3)], 'uint8');
% 
% for i = 1:size(img_in,3)
%     img1 = img_in(:,:,i);
%     img = ind2rgb(int32(img1(:,:))+int32(img1(:,:)~=0), color_map);
% 
%     % Overlay components on sem_image
%     if overlay == true
%         over_im = sem_image(:,:,i);
%         
%         im_mask = (img == 0);
% 
%         img(:,:,1) = over_im .* img(:,:,1);
%         img(:,:,2) = over_im .* img(:,:,2);
%         img(:,:,3) = over_im .* img(:,:,3);
% 
%         img(:,:,1) = img(:,:,1) + over_im .* im_mask(:,:,1);
%         img(:,:,2) = img(:,:,2) + over_im .* im_mask(:,:,2);
%         img(:,:,3) = img(:,:,3) + over_im .* im_mask(:,:,3);  
%     end
%     
%     % Rescale the image to the size of the plot windows
%     %img_out(:,:,:,i) = uint8(imresize(img, [height width]));    
%     img_out(:,:,:,i) = imresize(256*img,[height width]);
% end
% 
% fprintf('finished\n');
%     
% end % Compute2dPlot
% 

% ----- Redraw3dPlot ------
function Redraw3dPlot() 
% Redraw the 3d component plot

persistent surf_cache cap_cache

surf_cache{999,FindMaxCompNum+1} = [];
cap_cache{999,FindMaxCompNum+1} = [];

if state.plot3d_enable == false
    axes(h_plot5);
    cla;
    return;
end
    

%return;
%fprintf('Redraw3dPlot...');

h_waitbar = waitbar(0,'Redrawing 3d plot...');

isoval = .5;

axes(h_plot5);
cla;
set(h_fig_3d, 'Visible', 'off');

for r3_i = 1:length(state.n_cur_comp)
    waitbar( (r3_i-1)/length(state.n_cur_comp) );
    
    % Check to see if we have cached this
    csurf = surf_cache{state.n_cur_thresh(r3_i), state.n_cur_comp(r3_i)};
    ccap = cap_cache{state.n_cur_thresh(r3_i), state.n_cur_comp(r3_i)};
    
    if isempty(csurf) || isempty(ccap)
        % Generate the surface & isocap
        comp = ( cur_comp == state.n_cur_comp(r3_i) );
        
        [min_yxz, max_yxz] = FindBoundingBoxComp(comp, state.n_cur_comp(r3_i), state.n_cur_thresh(r3_i));
        
        % Limit by the 3d bounding box we're displaying
        min_yxz = max(min_yxz, bounding_box_3d([3,1,5]));  %bounding_box is xyz
        max_yxz = min(max_yxz, bounding_box_3d([4,2,6]));
        
        % Only look at the region where the component is non-zero
        comp = comp(min_yxz(1):max_yxz(1), min_yxz(2):max_yxz(2), min_yxz(3):max_yxz(3));
        % comp = smooth3(comp,'box',5);
    
        % Make sure to have 3d volume (for plotting)
        if any(max_yxz - min_yxz <= 1)
            comp(max_yxz(1)+1,max_yxz(2)+1,max_yxz(3)+1) = 0;
        end
        
        csurf = isosurface(comp,isoval);  %'noshare' didn't really speed things up
        min_xyz = [min_yxz(2) min_yxz(1) min_yxz(3)];
        csurf.vertices = csurf.vertices + repmat(min_xyz,[length(csurf.vertices) 1]);
        surf_cache{state.n_cur_thresh(r3_i), state.n_cur_comp(r3_i)} = csurf;
        
        % The isocaps gives a segmentation fault (WinXP), but works ok on the
        % smoothed data.  Haven't gotten this in a while even in WinXP
        ccap = isocaps(comp,isoval);
        ccap.vertices = ccap.vertices + repmat(min_xyz,[length(ccap.vertices) 1]);
        cap_cache{state.n_cur_thresh(r3_i), state.n_cur_comp(r3_i)} = ccap;
    end
        
    col = color_map(state.n_cur_comp(r3_i)+2,:);
    ps(r3_i) = patch(csurf,'FaceColor',col,...
        'EdgeColor','none'); %,'AmbientStrength',.6,'SpecularStrength',.4,'DiffuseStrength',5);
    pc(r3_i) = patch(ccap,'FaceColor',col,'EdgeColor','none');

end


% Z buffer slows things down, and no visible difference
%set(gcf,'Renderer','zbuffer');

% Use better lighting
%lighting phong
lighting gouraud

%camlight left;
h_light_r = camlight('right');
h_light_h = camlight('headlight');

% set(gca,'CameraPosition', state.CameraPosition);
% set(gca,'CameraUpVector', state.CameraUpVector);


%fprintf('finished\n');
set(h_fig_3d, 'Visible', 'on');


% ---- Draw image plane of the current section ----
% 8/8/2007 JFM

if state.plot3d_plane
	% plot z slice
    surx = [1 sx];
    sury = [1 sy];
    surz = [state.z state.z ; state.z state.z ];
    h_plane_z = surface(surx, sury, surz, 'backfacelighting','reverselit', 'facelighting', 'flat', 'FaceColor', 'texturemap',  'CData', double(squeeze(sem_image(:,:,state.z,:))));%, 'FaceAlpha', 0.99); 
    colormap(gray(256));

	% plot x slice
    surx = [state.x state.x];
    sury = [1 sy];
    surz = [1 sz ; 1 sz ];
    h_plane_x = surface(surx, sury, surz, 'backfacelighting','reverselit', 'facelighting', 'flat', 'FaceColor', 'texturemap',  'CData', double(squeeze(sem_image(:,state.x,:,:))));%, 'FaceAlpha', 0.99); 
    colormap(gray(256));

	% plot y slice
    surx = [1 sx];
    sury = [state.y state.y];
    surz = [1 1 ; sz sz ];
    h_plane_y = surface(surx, sury, surz, 'backfacelighting','reverselit', 'facelighting', 'flat', 'FaceColor', 'texturemap',  'CData', double(permute(squeeze(sem_image(state.y,:,:,:)),[2 1 3])));%, 'FaceAlpha', 0.99); 
    colormap(gray(256));
end
% ---- End plane ----


close(h_waitbar);


end % Redraw3dPlot

% ----- Redraw3dPlane -----
function Redraw3dPlane()
if state.plot3d_plane
	surz = [state.z state.z ; state.z state.z ];
	set(h_plane_z,'ZData', surz, 'CData', double(squeeze(sem_image(:,:,state.z,:))));
	surx = [state.x state.x];
	set(h_plane_x,'XData', surx, 'CData', double(squeeze(sem_image(:,state.x,:,:))));
	sury = [state.y state.y];
	set(h_plane_y,'YData', sury, 'CData', double(permute(squeeze(sem_image(state.y,:,:,:)),[2 1 3])));
end
end % Redraw3dPlane


% ----- RedrawText ------
function RedrawText()
% Redraw the text window info.

%figure(h_fig_text);

% Display info in title and output
if state.thresh == 999
    str = sprintf('[%d %d %d]     Valid components', state.x, state.y, state.z);
else
    str = sprintf('[%d %d %d]     Threshold: %d', state.x, state.y, state.z, state.thresh);
end
set(h_text1, 'String', str);


% --- List the components, their sizes, etc.
% Should we use a list box?  Can we change the colors in it?
% Asked at Mathwork usenet, but no luck yet.

for rt_i = 1:n_comp_list 
    if rt_i <= length(state.n_cur_comp)
        c = state.n_cur_comp(rt_i);
        th = state.n_cur_thresh(rt_i);
        
        if th == 999 % !! doesn't display size or z range for valid_comps
            % This is a component from the valid set
            str = sprintf('Valid component %5d  (%s)', c, valid_info(c).cell_type );
            
        else
            ind = find(state.thresholds == th);

            sizes = eval(sprintf('all_comp_thresh.sizes%d', state.thresholds(ind) ));
            maxs = eval(sprintf('all_comp_thresh.maxs%d', state.thresholds(ind) ));
            mins = eval(sprintf('all_comp_thresh.mins%d', state.thresholds(ind) ));

            str = sprintf('Th %3d C %5d  Voxels: %6d   Z %d-%d', ...
                th, c, sizes(c), mins(c,3), maxs(c,3)  );
        end
        
        col = color_map(c+2, :);
    else
        str = '';
        col = [0 0 0];

    end

    set(h_comp_list(rt_i), 'String', str, 'ForegroundColor', col );
end


end % RedrawText





% --------------------------------------------------------------------------
% ------------------- Helper functions (nested functions) ------------------
% --------------------------------------------------------------------------

% Have to be very careful here because if these functions use variables
% that are defined in other parts of the main code, they can be overwritten
% by functions here.  See scope rules for nested functions.

% ----- SelectCurrentComponents ------
% Find all the components currently selected in the 2d list box, 
% which may be from any of the threshold levels, and/or from the
% valid set.  
function cur_comp = SelectCurrentComponents()

cur_comp = zeros([sy sx sz], 'single');
next_comp = zeros([sy sx sz], 'single');

% Select from thresholds
for scc_i = 1:length(state.thresholds)
    th = state.thresholds(scc_i);
    ind = find(state.n_cur_thresh == th);
    if ~isempty(ind)
        comps_th = eval(sprintf('all_comp_thresh.comp%d', th));
        next_comp = SelectComps(comps_th, state.n_cur_comp(ind));
        cur_comp = cur_comp .* (next_comp == 0) + next_comp;
    end
end
    
% Select from valid comp
ind = find(state.n_cur_thresh == 999);
if ~isempty(ind)
    next_comp = SelectComps(valid_comp, state.n_cur_comp(ind));
    cur_comp = cur_comp .* (next_comp == 0) + next_comp;
end
 
end


function [comp_out] = SelectComps(comp_in, list)
% SelectComps - Creates a stack with only those objects in
%   the list.  Object numbering is preserved.
%
%   comp_in  - Dense component image 
%   list - List of objects to include in new stack.
%
% Returns:
%   comp_out - Stack (dense) containing selected objects (from list)
%

comp_out = zeros(size(comp_in),'single');
idx = ismember(comp_in,list); 
comp_out(idx) = comp_in(idx);

end


% ----- GetCompZRange -----
function [zmin, zmax, zmid] = GetCompZRange(comp, thresh)
% Finds the z range of the component number 'comp' at threshhold 'thresh'

% Default/error condition
zmin = -1;
zmax = -1;
zmid = -1;

if thresh ~= 999 && comp > 0
    maxs = eval(sprintf('all_comp_thresh.maxs%d', thresh ));
    mins = eval(sprintf('all_comp_thresh.mins%d', thresh ));
   
    if comp <= length(maxs)
        zmin = mins(comp,3);
        zmax = maxs(comp,3);
        zmid = int32(floor( (zmin + zmax) /2 ) );
    end
    
elseif thresh == 999 
    if comp > 0 && comp <= state.n_valid
        zmin = valid_info(comp).min_yxz(3);
        zmax = valid_info(comp).max_yxz(3);
        zmid = int32(floor( (zmin + zmax) /2 ) );
    end
        
end


end % GetCompZRange


% ----- FindCurrentComponent -----
% Returns the index in state.n_cur_comp of the given comp
% at threshold thresh, if it is not found, then ind = []
function ind = FindCurrentComponent(comp, thresh)
  
ind_c = find(state.n_cur_comp==comp);
ind_th = find(state.n_cur_thresh==thresh);
ind = intersect(ind_c, ind_th);

end

% ----- GetNumCompsAtThresh -----
function num = GetNumCompsAtThresh(thresh) 

if thresh ~= 999
    maxs = eval(sprintf('all_comp_thresh.maxs%d', thresh ));
    num = length(maxs);
else
    % In valid_comps
    num = state.n_valid;
end

end

% ----- FindMaxCompNum -----
% Finds the highest component number over all the thresholds
function mx = FindMaxCompNum() 
   
mx = 0;

for fmc_i = 1:length(state.thresholds)
    nc = GetNumCompsAtThresh(state.thresholds(fmc_i));
    
    mx = max(nc,mx);
end

end
    

% ----- FindBoundingBoxComp -----
function [min_yxz, max_yxz] = FindBoundingBoxComp(comp, n_comp, n_thresh)
% From FindBoundingBoxComp.m standalone
%
% comp - Component image
% n_comp - Component number (optional)
% n_thresh - Component threshold (optional)
%
% If n_comp and n_thresh are present, then the bounding box will be
% found from the precomputed lookup table, which is much faster.

if exist('n_comp','var') && exist('n_thresh', 'var')
    % See if we can find this component in the precomputed 
    % bounding boxes first. 
    if n_thresh ~= 999 && n_comp > 0
        mins = eval(sprintf('all_comp_thresh.mins%d', n_thresh ));
        maxs = eval(sprintf('all_comp_thresh.maxs%d', n_thresh ));
        min_yxz = mins(n_comp,:);
        max_yxz = maxs(n_comp,:);
        
        % Make sure to have 3d volume (for plotting)
        %if any(max_yxz - min_yxz <= 1)
        %    max_yxz = max_yxz + 1;
        %end
        return;
    end
    
end

ind = find(comp);

% Should check for empty ind here

[y, x, z] = ind2sub(size(comp),ind(1));
min_yxz = [y, x, z];
max_yxz = [y, x, z];

for fbb_i = 2:length(ind)
    [y, x, z] = ind2sub(size(comp),ind(fbb_i));

    min_yxz(1) = min(y,min_yxz(1));
    min_yxz(2) = min(x,min_yxz(2));
    min_yxz(3) = min(z,min_yxz(3));
    
    max_yxz(1) = max(y,max_yxz(1));
    max_yxz(2) = max(x,max_yxz(2));
    max_yxz(3) = max(z,max_yxz(3));

end

% Make sure to have 3d volume (for plotting)
%if any(max_yxz - min_yxz <= 1)
%    max_yxz = max_yxz + 1;
%end

end





% ----------------
end % Validate


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% ---------------------------- End of nested functions --------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Functions here have separate namespaces for variables than the
% main Validate function, so things like state must be passed to
% these functions.

% ------ FindMerges -------

function [n_comp, n_thresh, state] = FindMerges(state, valid_comp)
% From Valentin's find_splits.m (1/31/2007)
%
% For each component in the range (c_ind <= state.merge.current),
% this routines finds a list of components that may merge with
% c_ind.  One element is returned from this list (along with c_ind)
% and if the list is empty the next element in the range is 
% examined (vector fields calculated) and a new list is created.
% List is stored as state.merge.merge_list.
%
% Inputs:
% comps - components
% state.merge.range - components will be sorted by size and checked for splits, 
%   starting with max(range) down to min(range)
%
% Returns:
%   n_comp - Components in suggested merge
%   n_thresh - Thresholds of components in suggested merge
%
% VZ, Jan 2007

sx=3; sy=3; sz=3; % size of the box for orientation calculation 
Niter=5; % number of vector field aligning iterations

list = state.merge.list;    % Component numbers (these are consecutive in Validate)
comps = state.merge.comps;  % Potential components to merge with (vector fields not created for all these)

% Now done in MergeCallback
% thresh=20; %components smaller than thresh will not be considered as merger candidates
% [sizes, list] = ComponentSizes(comps);
% [tmp,idx]=sort(abs(sizes-thresh),'ascend');
% comps = SelectComponents(comps, list(3:idx));

[Ny Nx Nz]=size(comps);


% Index of currently examined components, count down
c_ind = state.merge.current;

if ~isempty(state.merge.merge_list)
    % We've already found some components that could merge with c_ind, 
    % now let's suggest them to the user (ie, return the comp and thresh
    % numbers).
    
    n_comp = [c_ind state.merge.merge_list(1)]
    n_thresh = state.thresh * ones(size(n_comp));
    
    state.merge.merge_list(1) = [];  % Delete suggested comp
    
    if ~isempty(state.merge.merge_list)
        % Move on to a different component in range
        c_ind = c_ind - 1;
        if c_ind < min(state.merge.range)
            c_ind = max(state.merge.range);
        end
    end

else
    
%  for c_ind=max(range):-1:min(range)  
    disp(['Index=',num2str(c_ind)]);
    h_waitbar = waitbar(0,sprintf('Looking for merges for object %d', c_ind ) );
    
    img=single(comps==list(c_ind)); 
 
    [bmin,bmax]=FindBoundingBoxComp(img);
    bmin(1)=max(bmin(1),sy+1); bmin(2)=max(bmin(2),sx+1); bmin(3)=max(bmin(3),sz+1);
    bmax(1)=min(bmax(1),Ny-sy); bmax(2)=min(bmax(2),Nx-sx); bmax(3)=min(bmax(3),Nz-sz);
    img_bsd=single(img(bmin(1)-sy:bmax(1)+sy,bmin(2)-sx:bmax(2)+sx,bmin(3)-sz:bmax(3)+sz));

    %calculate the vector field
    disp('Calculating vector field...');
    waitbar(1/5);
    
    s=single(zeros([size(img_bsd) 3])); 
    for yc=sy+1:sy+(bmax(1)-bmin(1))
        for xc=sx+1:sx+(bmax(2)-bmin(2))
            for zc=sz+1:sz+(bmax(3)-bmin(3))
                if img_bsd(yc,xc,zc)~=0
                    box=img_bsd(yc-sy:yc+sy,xc-sx:xc+sx,zc-sz:zc+sz);
                    a=moments_3D(box);
                    s(yc,xc,zc,:)=a;
                end
            end
        end
    end

    %locally align the field by Ising-like interactions
    disp('Aligning...');
    waitbar(2/5);
    mask = repmat(sum(s.^2,4)>0,[1 1 1 3]);
    conn=ones(3,3,3); conn(2,2,2)=0;
    for iter=1:Niter
        outer=vec2ten(s);
        outer = convn_fast(outer,conn,'same');
        s_old = s;
        for ii = 1:3
            s(:,:,:,ii) = sum(outer(:,:,:,:,ii).*s_old,4);
        end
        s_mag = repmat(sqrt(sum(s.^2,4)),[1 1 1 3]);
        s(mask) = s(mask)./s_mag(mask);
        s(~mask)=0;
    end
    u=s(:,:,:,1); v=s(:,:,:,2); w=s(:,:,:,3);

    %smooth the object and calculate surface normals
    disp('Smoothing...');
    waitbar(3/5);
    img_sm=smooth3(img_bsd,'gaussian',5);
    [fc,vert]=isosurface(img_sm);
    n = isonormals(img_sm,vert);

    %find vectors on the surface of the smoothed object
    us=interp3(u,vert(:,1),vert(:,2),vert(:,3),'cubic');
    vs=interp3(v,vert(:,1),vert(:,2),vert(:,3),'cubic');
    ws=interp3(w,vert(:,1),vert(:,2),vert(:,3),'cubic');

    %scale each surface vector by cosine of the angle with corresponding normal  
    nxs=n(:,1); nys=n(:,2); nzs=n(:,3); 
    scale=2*(us.*nxs+vs.*nys+ws.*nzs)./((us.*us+vs.*vs+ws.*ws==0)+sqrt(us.*us+vs.*vs+ws.*ws))./((nxs.*nxs+nys.*nys+nzs.*nzs==0)+sqrt(nxs.*nxs+nys.*nys+nzs.*nzs));

    norms=abs(sqrt(us.*us+vs.*vs+ws.*ws));
    mx = max(norms);

    %find coordinates of vector tips
    xv=min(round(vert(:,1)+us.*scale/mx),Nx); yv=min(round(vert(:,2)+vs.*scale/mx),Ny); zv=min(round(vert(:,3)+ws.*scale/mx),Nz);
    xv=xv+bmin(2)-sx-1; yv=yv+bmin(1)-sy-1; zv=zv+bmin(3)-sz-1; 
    xl=nonzeros(xv); yl=nonzeros(yv); zl=nonzeros(zv);

    %vector tips define coordinates of a 1-voxel thin shell 
    ind=sub2ind(size(img),yl,xl,zl);
    shell=zeros(size(img));
    shell(ind)=1;

    %find increment of the component 
    incr=max(shell-img,0);

    %find overlaps of the increment with other components
    incr_i=find(incr);
    ovlp=sort(comps(incr_i),'descend');

    %loop through overlaping components, starting with largest overlap
    ovlp_s=histc(ovlp,0:max(ovlp(:)));
    [nbs,idx]=sort(ovlp_s,'descend');
    
    % Create the new list of potential merges for c_ind
    state.merge.merge_list = idx(2:sum(nbs>0)) - 1;
    
    % Check against the valid components
    waitbar(4/5);
    state.merge.merge_list
    for ml_ind = length(state.merge.merge_list):-1:1
        % See if there is any overlap between this potential merge and valid_comp
        ml_comp = (comps == state.merge.merge_list(ml_ind));
        overlap = ml_comp & valid_comp ;
        
        if length(unique(overlap)) > 1
            state.merge.merge_list(ml_ind) = [];
            fprintf('FindMerges: Warning:  Suggested merge overlapped with valid_comp, skipping\n');
        end
    end

    % Check against the reject list
    for ml_ind = length(state.merge.merge_list):-1:1
        % See if this pair of objects is on the reject list
        if IsRejected([c_ind state.merge.merge_list(ml_ind)], ...
                [ state.thresh, state.thresh], state.reject )
            state.merge.merge_list(ml_ind) = [];
            fprintf('FindMerges: Warning:  Suggested merge previously rejected, skipping\n');
        end
    end

    % I still technically should do this, but the checking in the
    % valid_comp should avoid any problems.
    % comps=comps+(comps==cand)*(list(c_ind)-cand);

%     for i=2:sum(nbs>0)
%         cand=idx(i)-1; 
%         clf
%         title(['comp1=',num2str(list(c_ind)),', comp2=',num2str(cand),', overlap=',num2str(nbs(i))]);%,', merge (y/n)?']);
%         p=patch(isosurface(img,.5)); set(p,'FaceColor','green','EdgeColor','none');
%         img2=(comps==cand);
%         p2=patch(isosurface(img2,.5)); set(p2,'FaceColor','red','EdgeColor','none');
%         daspect([1 1 1]); view(3); camlight headlight; lighting gouraud
%         %key=1;
%         %while(key~='y' && key~='n' && key ~= 27)
%             %[x,y,key] = ginput(1);
%             key=menu('Merge ?','yes','no');
%             if(key==1) 
%                 %merge components
%                 comps=comps+(comps==cand)*(list(c_ind)-cand);
%                 clf
%                 title(['comp1=',num2str(list(c_ind)),' and comp2=',num2str(cand),' merged']);
%                 p=patch(isosurface(comps==list(c_ind),.5)); set(p,'FaceColor','green','EdgeColor','none');
%                 daspect([1 1 1]); view(3); camlight headlight; lighting gouraud
%                 drawnow
%             end
%         %end
%     end
    % grow component by its increment, does this increase the size of comps?
    comps=comps +  incr*list(c_ind) .* (comps == 0);
    state.merge.comps = comps;
    
    %end % Old end of cycle through the components in range.

    % If we found a merge, suggest it, if not look at another component
    if ~isempty(state.merge.merge_list)
        % Suggest the merge
        n_comp = [c_ind state.merge.merge_list(1)]
        n_thresh = state.thresh * ones(size(n_comp));

        state.merge.merge_list(1) = [];  % Delete suggested comp

        % If there's only one entry in merge list, should move to 
        % next component
        
        if length(state.merge.merge_list) <= 1
            % Move on to a different component in range
            c_ind = c_ind - 1;
            if c_ind < min(state.merge.range)
                c_ind = max(state.merge.range);
            end
        end
        
    else
        % Move on to a different component in range
        c_ind = c_ind - 1;
        if c_ind < min(state.merge.range)
            c_ind = max(state.merge.range);
        end

        n_comp = [];
        n_thresh = [];
    end

    close(h_waitbar);
end

state.merge.current = c_ind;


end



% ----- IsRejected -----
% Checks the input comps/thresh set against the reject list.
% If any subset of in_comp/in_thresh is in the reject list,
% then return true.
function [is_reject] = IsRejected(in_comp, in_thresh, reject_list)

is_reject = false;
r_ind = length(reject_list);


for i = 1:r_ind
    lr = length(reject_list{i}.n_comp);
    n_match = 0;
    for j = 1:lr
        co = reject_list{i}.n_comp(j);
        th = reject_list{i}.n_thresh(j);
        ind = find(in_comp == co);
        if in_thresh(ind) == th
            n_match = n_match + 1;
        end
    end
    
    if lr > 0 && n_match == lr
        % All the components in this entry in the reject list are
        % matched in the in_comp/in_thresh
        is_reject = true;
        break;
    end
end

end

% ----- DeleteComponents ----
% Delete list of components delete_list from a component file comp
% arguments: comp, delete_list
% returns: comp
%
% From: Viren's delete_components.m

function [comp]=DeleteComponents(comp, delete_list)

for i=1:length(delete_list)
    delete_list(i)
    ind = find(comp == delete_list(i));
    comp(ind) = 0;
end

end
