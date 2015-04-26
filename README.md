

# Overview
----------

This repository contains iOS demo applications developed during Google Summer of Code 2012 with opencv.org.
Note, the demos require the opencv ios framework. See "Getting Started" section.

* HelloIosVideo: Beginners tutorial on using opencv's ios camera interface.
![Screenshot-Intro](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-intro.png)
* FullscaleDemoApp: Meta project containing all other demos.

* FaceDetectVideo: Face detection on still images and iphone video camera.
![Screenshot-Facedetect](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-video-facedetect.png)
* FindHomography: Planar object recognition on video input.
![Screenshot-Homography1](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-homography-1.png)
![Screenshot-Homography2](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-homography-2.png)
* GrabCut: Grabcut segmentation algorithm. Paint foreground/background seeds with touch gestures.
![Screenshot-Grabcut](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-grabcut.png)
* VideoConvolution: Process video frames with basic convolution kernels: Gaussian blur, median blur, bilateral blur, laplacian, sobel, canny.
![Screenshot-Convolution1](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-video-convolution-1.png)
![Screenshot-Convolution2](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-video-convolution-2.png)
* VideoFilter: Advanced video filters: pixelation, color inversion, retro filter, soft focus, cartoon, pinhole.
![Screenshot-Video-Pixelation](https://github.com/Duffycola/opencv-ios-demos/blob/master/screenshots/screenshot-video-pixelation.png)




# Getting Started
-----------------


1) You need opencv.framework (statically compiled opencv framework for iOS).
* Download [pre-compiled framework](http://sourceforge.net/projects/opencvlibrary/files/opencv-ios/).
* Alternatively, follow manual [build instructions](http://docs.opencv.org/doc/tutorials/introduction/ios_install/ios_install.html#ios-installation).

Note, the XCode projects are configured to look for opencv2.framework at /build/opencv2.framework.

2) [Include opencv.framework in your Xcode project](http://docs.opencv.org/doc/tutorials/ios/hello/hello.html#opencvioshelloworld).

3) OpenCV provides a wrapper to use Apple's native camera interface to obtain image/video frames. Each frame is converted automatically to cv::Mat and delivered to a C callback via delegation. [Learn more](http://docs.opencv.org/doc/tutorials/ios/image_manipulation/image_manipulation.html#opencviosimagemanipulation).

4) Continue writing your first [video processing project](http://docs.opencv.org/doc/tutorials/ios/video_processing/video_processing.html#opencviosvideoprocessing).

5) Once you have understood how to obtain a cv::Mat in your iOS project, feel free to re-use the modular demo controllers in [shared](https://github.com/Duffycola/opencv-ios-demos/blob/master/shared) and please feel free to contribute.

- [ ] Note, the XCode projects are currently outdated. Last time they have been updated in 2012.

6) Advanced: Dig deep into how OpenCV obtains image/video frames from the native interface, wraps them into C datastructures, calls the C callback to let you process each frame (hence .mm files), and then updates the output target:

[opencv/modules/videoio/include/opencv2/videoio/cap_ios.h](https://github.com/Itseez/opencv/blob/master/modules/videoio/include/opencv2/videoio/cap_ios.h)
[opencv/modules/videoio/src/cap_ios_abstract_camera.mm](https://github.com/Itseez/opencv/blob/master/modules/videoio/src/cap_ios_abstract_camera.mm)
[opencv/modules/videoio/src/cap_ios_photo_camera.mm](https://github.com/Itseez/opencv/blob/master/modules/videoio/src/cap_ios_photo_camera.mm)
[opencv/modules/videoio/src/cap_ios_video_camera.mm](https://github.com/Itseez/opencv/blob/master/modules/videoio/src/cap_ios_video_camera.mm)

7) Contribute to the iOS project, for example by adding to the very [sparse documentation](http://docs.opencv.org/doc/tutorials/ios/table_of_content_ios/table_of_content_ios.html#table-of-content-ios).
