# MATLAB_Basler_Viewer

A MATLAB-based application for viewing and recording video from a Basler camera, using `ffmpeg` for video compression.

## Features

- **Real-time video preview** with zoom functionality (mouse scroll).
- **Recording and compression** using `ffmpeg`.
- **Adjustable camera settings** (frame rate, exposure time).
- **Reference lines** for better alignment.

## Dependencies

This application relies on:
- **MATLAB Image Acquisition Toolbox**
- **[FfmpegVideoWriter](https://github.com/cohenrotem/FfmpegVideoWriter)** by Rotem (2021)
- **ffmpeg.exe** for video compression

## Configuration (`.conf` File)

Before running the application, you must provide a `.conf` file specifying user settings. The file should contain:

1. **Path to `ffmpeg.exe`** (e.g., `C:\FFmpeg\bin\ffmpeg.exe`) – *No quotation marks required.*
2. **Bitrate for video compression** (default: `20`).
3. *(Optional)* Custom ffmpeg command – Refer to [ffmpeg documentation](https://ffmpeg.org/documentation.html) for details.

## Files in This Project

### 1. `.conf` (Configuration File)
Defines the paths and compression settings required for the application.

### 2. `GUIRecord.m` (Main Recording GUI)
- Implements the core functionality of video acquisition.
- Supports zooming (mouse scroll), reference lines, and camera adjustments (frame rate, exposure time).

### 3. `BaslerApp_code.m` (Example Usage)
- Demonstrates how to use `GUIRecord` with a Basler camera.

## Usage

1. Install `ffmpeg` and ensure `ffmpeg.exe` is accessible.
2. Create a `.conf` file with the required settings.
3. Run `BaslerApp_code.m` in MATLAB.

## License

This project is licensed under the MIT License. 
