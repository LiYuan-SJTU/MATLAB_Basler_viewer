function BaslerApp_code()
clear;
warning off;
close all;
imaqreset;
conf_pre = readlines('preference.conf');
fps = 10;
vid = videoinput('gentl',1,'Mono8');
src = getselectedsource(vid);
vid.FramesPerTrigger = 1;
src.AcquisitionFrameRate = fps;
src.AcquisitionFrameRateEnable = 'True';
vid.TriggerRepeat = Inf;
triggerconfig(vid,'manual');

vidRes = vid.VideoResolution;
nBands = vid.NumberOfBands;
point = GUIRecord;
point.log_file = -1;
point.ffmpeg_cmd = conf_pre{1};
switch size(conf_pre,1)
    case 2
        point.bitrate = str2double(conf_pre{3});
    case 3
        point.cmd = conf_pre{4};
end
[f_preview,hImage] = CreateGUIfigure(vidRes,nBands,point,src,vid);
while 1
    if ~isvalid(f_preview)
        imaqreset;
        break;
    end
    pause(1);
end
end