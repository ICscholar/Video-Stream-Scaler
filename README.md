视频与流媒体作为最直观的信息传输形式，一直是信息技术发展的前沿，随着VR 等技术的发展，视频类文件如何高效高清的传递成为了亟待解决的问题
基于易灵思提供的平台，Vedio-Stream-Scaler 及配套的 GUI 界面，提供高性能优体验的技术实现。
在本工程中，若用户需要进行视频流媒体放大，则根据用户选择区域放大至全屏（1920*1080）；若用户需要将视频流媒体缩小，则根据用户选择的大小将全屏（1920*1080）缩小到指定分辨率

(Video and streaming media, as the most intuitive forms of information transmission, have always been at the forefront of information technology development. With the development of VR and other technologies, how to efficiently and high-definition transmit video files has become an urgent problem to be solved
Based on the platform provided by Yilingsi, Vedio Stream Scaler and its accompanying GUI interface, a technology implementation that provides high-performance and excellent experience.
In this project, if the user needs to zoom in on video streaming, they will zoom in to full screen (1920 * 1080) according to the user's selected area; If the user needs to reduce the video streaming size, the full screen (1920 * 1080) will be reduced to the specified resolution based on the size selected by the user)

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/RTL_overview.png)

The contents in this picture show the key module folders in the whole project. Following explanations mainly focus on the algorithm module.

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/algorithm_overview.png)

The overview of the scaler algorithm module.

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/asynchronous%20FIFO.png)\n
双线性插值和最近邻插值都是需要读两行才能进行计算，比如，第一行输入到缩放模块，然后缓存，等第二行输入后就可以计算了。但第三行输入进来，就使用第二行和第三行。也就是说，实际只用了一行数据输出两行数据。放大需要读一行写两行，所以放大模块需要2倍时钟。缩小可以用1倍甚至0.5倍时钟。\n
Bilinear interpolation and nearest neighbor interpolation both require reading two rows to perform calculations. For example, the first row is input to the scaling module, then cached, and after the second row is input, the calculation can be performed. But when the third line is inputted, use the second and third lines. That is to say, only one row of data was actually used to output two rows of data. Amplification requires reading one line and writing two lines, so the amplification module requires twice the clock. Shrinking can be done with a clock that is 1 or even 0.5 times smaller



