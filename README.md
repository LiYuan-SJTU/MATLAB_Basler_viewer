# MATLAB_Basler_viewer

Use ffmpeg to package the video recorded from the Basler camera.

This app need ffmpeg.exe to compress the video. It use the ffmpeg to record the image.
To run this app, a .conf preference is a must. It tells the app the user's setup such as the ffmpeg.exe folder and ffmpeg command.
The first line in .conf file tells the app the actual ffmpeg.exe folder, such as C:\FFmpeg\bin\ffmpeg.exe. Note that there's no quotation markers.
The second line gives the bitrate for video compression whose default value is 20.
The third line is optional. Users can modify the command by themselves. Details can be found on the help site of ffmpeg itself.
