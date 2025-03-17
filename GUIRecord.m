classdef GUIRecord < handle
    properties
        value = [];
        videofilename = [];
        videofolder = [];
        log_file = 1;
        framerate = [];
        crf = -1;
        ffmpeg_cmd = [];
        bitrate = 20;
        cmd = '';
    end
    properties (Access = protected)
        isstop = 0;
        preview_status = 1;
    end
    methods
        %% function definition
        function [f_preview,hImage] = CreateGUIfigure(vidRes,nBands,point,src,vid)
            f_preview = figure('Toolbar','none','Menubar','none',...
                'Name','Basler GUI','NumberTitle','Off',...
                'Position',[10 50,800,800*(vidRes(2)/vidRes(1)+0.15)]);
            ratio = vidRes(2)/(vidRes(1)*(vidRes(2)/vidRes(1)+0.15));

            % String parts
            uicontrol('String','Exposure(us)','Style','text',...
                'Units','normalized','FontSize',14,'Position',...
                [0.01,(ratio+1)/2-0.06,.15,.04]);
            uicontrol('String','FPS','Style','text',...
                'Units','normalized','FontSize',14,'Position',...
                [0.01,(ratio+1)/2-0.006,.05,.04]);
            uicontrol('String','Duration(s)','Style','text',...
                'Units','normalized','FontSize',14,'Position',...
                [0.135,(ratio+1)/2-0.006,.15,.04]);
            uicontrol('String',['Focus Measure ',...
                num2str(0,'%4.2f')],'Style','text',...
                'Units','normalized','FontSize',14,'Position',...
                [0.425,(ratio+1)/2-0.062,0.25,0.04],'Tag','Focus');
            uicontrol('String','Save to: ','Style','text', ...
                'Units','normalized','FontSize',14,'Position', ...
                [0.5,(ratio+1)/2-0.006,.09,.04]);

            % Edit parts
            uicontrol('Style','edit',...
                'FontSize',14,'Units','normalized','Tag','Exposure',...
                'Position',[0.17,(ratio+1)/2-0.055,.1,.04]);
            uicontrol('Style','edit',...
                'FontSize',14,'Units','normalized','Tag','FPS',...
                'Position',[0.07,(ratio+1)/2,.06,.04]);
            uicontrol('Style','edit',...
                'FontSize',14,'Units','normalized','Tag','Duration',...
                'Position',[0.29,(ratio+1)/2,.1,.04])
            uicontrol('Style','edit','FontSize',14,...
                'Units','normalized','Tag','SaveTo',...
                'Position',[.6,(ratio+1)/2,.38,.04]);

            % Buttons and checkbox
            g = uicontrol('String','Grid','Units',...
                'normalized','Style','checkbox',...
                'Position',[0.41,(ratio+1)/2+0.002,.07,.04],...
                'FontSize',14,'Tag','Grid');

            uicontrol('String','Preview',...
                'Callback',@(obj,event) preview_fun(obj,event,vid,point),...
                'FontSize',14,'Units','normalized','Position',...
                [0.3,(ratio+1)/2-0.055,.12,.04],'Tag','Preview',...
                'ForegroundColor',[204 22 58]/255);
            record = uicontrol('String','Record',...
                'FontSize',14,'Units','normalized','Position',...
                [.68,(ratio+1)/2-0.055,.1,.04],'ForegroundColor',[204 22 58]/255);
            uicontrol('String','Stop','Callback',...
                @(obj,event)videoStop(obj,event,point),'Tag','Stop',...
                'FontSize',14,'Units','normalized','Position',...
                [.785,(ratio+1)/2-0.055,.1,.04],'Enable','off');
            capture = uicontrol('String','Capture','FontSize',14,'Units','normalized',...
                'Tag','Capture','Position',[0.89,(ratio+1)/2-0.055,.1,.04]);

            axes('Position',[0 0 1 ratio],'Tag','camera');
            hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
            axis equal;
            hold on;
            ax2 = axes('Position',[0 0 1 ratio],'Color','none');
            p = plot([vidRes(2)/2 0 0.6*vidRes(2) 0.4*vidRes(2) 0 0;...
                vidRes(2)/2 vidRes(2) 0.6*vidRes(2) 0.4*vidRes(2) vidRes(2) vidRes(2)],...
                [0 vidRes(1)/2 0 0 0.4*vidRes(1) 0.6*vidRes(1);...
                vidRes(1) vidRes(1)/2 vidRes(1) vidRes(1) 0.4*vidRes(1) 0.6*vidRes(1)]);
            for ii = 1:length(p)
                p(ii).Color = 'red';
                p(ii).LineStyle = '--';
                p(ii).Visible = 'off';
            end
            axis equal;
            set(ax2,'Color','none');

            g.Callback = @(src,event)preview_grid(src,event,p);
            record.Callback = @(obj,event)recordvideo(obj,event,...
                point,vid,src.AcquisitionFrameRate);
            capture.Callback = @(obj,event)captureimage(obj,event,...
                point,vid);
            setappdata(hImage,'UpdatePreviewWindowFcn',...
                @(obj,event,himage)mypreview(obj,event,...
                himage,point,src,vidRes,f_preview));

            preview(vid,hImage);
        end


    end
end

function videoStop(obj,event,point)
point.isstop = 1;
end

function preview_fun(obj,event,vid,point)
preview_button = findobj('Tag','Preview');
if point.preview_status == 1
    stoppreview(vid);
    point.preview_status = 0;
    preview_button.ForegroundColor = [0.1 0.1 0.1];
elseif point.preview_status == 0
    preview(vid);
    point.preview_status = 1;
    preview_button.ForegroundColor = [204 22 58]/255;
end
end

function captureimage(obj,event,point,vid)
obj.Enable = 'off';
if ~exist(point.videofolder,'dir')
    mkdir(point.videofolder);
end
start(vid);
img = getsnapshot(vid);
stop(vid);
imwrite(img,fullfile(point.videofolder,...
    [char(datetime('now','Format','yyyyMMdd_HHmmss')),'.bmp']));
obj.Enable = 'on';
end

function recordvideo(obj,event,point,vid,fps)
start(vid);
obj.Enable = 'off';
stop_button = findobj('Tag','Stop');
stop_button.Enable = 'on';
preview_button = findobj('Tag','Preview');
preview_button.Enable = 'off';
grid_button = findobj('Tag','Grid');
grid_button.Enable = 'off';
exposure_button = findobj('Tag','Exposure');
exposure_button.Enable = 'off';
capture_button = findobj('Tag','Capture');
capture_button.Enable = 'off';
fps_button = findobj('Tag','FPS');
fps_button.Enable = 'off';
duration_button = findobj('Tag','Duration');
duration_button.Enable = 'off';
Total_time = str2double(duration_button.String);
saveto_button = findobj('Tag','SaveTo');
saveto_button.Enable = 'off';

if ~exist(point.videofolder,'dir')
    mkdir(point.videofolder);
end
point.videofilename = ['Balser',...
    char(datetime('now','Format','yyyyMMdd_HHmmss')),'.mp4'];
if isempty(point.ffmpeg_cmd)
    v = FfmpegVideoWriter(fullfile(point.videofolder,...
        point.videofilename));
else
    v = FfmpegVideoWriter(fullfile(point.videofolder,...
        point.videofilename),point.ffmpeg_cmd);
end
v.log_file = point.log_file;
v.framerate = point.framerate;
v.crf = point.crf;
v.bitrate = point.bitrate;
v.cmd = point.cmd;
open(v);
stoppreview(vid);
tic;
frame_counter = 0;
if ~isempty(Total_time)
    time_count = Total_time;
end
while 1
    frame_counter = frame_counter+1;
    writeFrame(v,getsnapshot(vid));
    if point.isstop == 1
        break;
    end
    if ~isempty(Total_time)
        time_count = time_count-1/fps;
        if abs(time_count-round(time_count))<5e-4
            duration_button.String = num2str(round(time_count));
        end
        if frame_counter>Total_time*fps
            break;
        end
    end
end
elapsedTime = toc;
stop(vid);
close(v);
preview(vid);
duration_button.String = num2str(round(Total_time));
timePerFrame = elapsedTime/frame_counter;
effectiveFrameRate = 1/timePerFrame;
fprintf('fps: %4.2f\n',effectiveFrameRate);
obj.Enable = 'on';
stop_button.Enable = 'off';
preview_button.Enable = 'on';
grid_button.Enable = 'on';
exposure_button.Enable = 'on';
capture_button.Enable = 'on';
fps_button.Enable = 'on';
duration_button.Enable = 'on';
saveto_button.Enable = 'on';
point.isstop = 0;
end

function preview_grid(src,event,p)
val = event.Source.Value;
if val
    for ii = 1:length(p)
        p(ii).Visible = 'on';
    end
else
    for ii = 1:length(p)
        p(ii).Visible = 'off';
    end
end
end

function mypreview(obj,event,himage,point,src,vidRes,f_preview)
hfig = f_preview;
set(hfig,'WindowScrollWheelFcn',@(src,event)wheel(src,event,point));
h = [1 1 1;1 -8 1;1 1 1];
my_focus = findobj(gcf,'Tag','Focus');
focus = sum(imfilter(event.Data-min(event.Data,[],...
    'all'),h),'all')/numel(event.Data);
my_focus.String = ['Focus Measure ',num2str(focus,'%4.2f')];
if isempty(point.value)
    himage.CData = event.Data;
elseif size(point.value,1)==1 && point.value(1,3)>=1
    point.value = [];
else
    [height,width] = size(event.Data);
    img = event.Data;
    for ii = 1:size(point.value,1)
        mouse_x = point.value(ii,1);
        mouse_y = point.value(ii,2);
        if mouse_x<1
            mouse_x = mouse_x*vidRes(2);
        end
        if mouse_y<1
            mouse_y = mouse_y*vidRes(1);
        end
        mouse_scroll = 1.25.^(-point.value(ii,3));
        new_height = round(min(height,max(512,height/mouse_scroll)));
        new_width = round(min(width,max(512,width/mouse_scroll)));
        [left,right] = deal(round(mouse_x-new_width/2),round(mouse_x+new_width/2));
        [bottom,top] = deal(round(mouse_y-new_height/2),round(mouse_x+new_height/2));
        if left<1
            [left,right] = deal(1,new_width);
        elseif right>width
            [left,right] = deal(width-new_width+1,width);
        end
        if bottom<1
            [bottom,top] = deal(1,new_height);
        elseif top>height
            [bottom,top] = deal(height-new_height+1,height);
        end
        img = imresize(img(bottom:top,left:right),[height,width],'bicubic');
    end
    himage.CData = img;
end
my_exp = findobj(gcf,'Tag','Exposure');
if isprop(src,'ExposureTime')
    if isempty(my_exp.String)
        my_exp.String = num2str(src.ExposureTime);
    else
        src.ExposureTime = str2double(my_exp.String);
    end
else
    my_exp.String = NaN;
end
my_fps = findobj(gcf,'Tag','FPS');
if isprop(src,'AcquisitionFrameRate')
    if isempty(my_fps.String)
        my_fps.String = num2str(src.AcquisitionFrameRate);
    else
        src.AcquisitionFrameRate = str2double(my_fps.String);
        point.framerate = str2double(my_fps.String);
    end
else
    my_fps.String = NaN;
end
my_saveto = findobj(gcf,'Tag','SaveTo');
if isempty(my_saveto.String)
    point.videofolder = pwd;
else
    point.videofolder = my_saveto.String;
end
end

function wheel(src,event,point)
pt = get(gca,'CurrentPoint');
x = pt(1,1);
y = pt(1,2);
Scroll = sign(event.VerticalScrollCount);
fprintf('Move x=%f,y=%f\n',x,y);
fprintf('VerticalScrollCount=%d\n',Scroll);
if isempty(point.value)
    point.value = [x,y,Scroll];
elseif Scroll+point.value(3) == 0
    point.value = [];
else
    point.value = [(x+point.value(1))/2,(y+point.value(2))/2,...
        Scroll+point.value(3)];
end
end

