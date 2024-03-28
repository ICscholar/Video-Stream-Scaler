(Chinese version)视频与流媒体作为最直观的信息传输形式，一直是信息技术发展的前沿，随着VR 等技术的发展，视频类文件如何高效高清的传递成为了亟待解决的问题
基于易灵思提供的平台，Vedio-Stream-Scaler 及配套的 GUI 界面，提供高性能优体验的技术实现。
在本工程中，若用户需要进行视频流媒体放大，则根据用户选择区域放大至全屏（1920*1080）；若用户需要将视频流媒体缩小，则根据用户选择的大小将全屏（1920*1080）缩小到指定分辨率

(English Version)Video and streaming media, as the most intuitive forms of information transmission, have always been at the forefront of information technology development. With the development of VR and other technologies, how to efficiently and high-definition transmit video files has become an urgent problem to be solved.
Based on the platform provided by Yilingsi, Vedio Stream Scaler and its accompanying GUI interface, a technology implementation that provides high-performance and excellent experience.
In this project, if the user needs to zoom in on video streaming, they will zoom in to full screen (1920 * 1080) according to the user's selected area; If the user needs to reduce the video streaming size, the full screen (1920 * 1080) will be reduced to the specified resolution based on the size selected by the user.

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/RTL_overview.png)

The contents in this picture show the key module folders in the whole project. Following explanations mainly focus on the algorithm module.

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/algorithm_overview.png)
(Chinese version)按照设计目的，我们的视频流媒体缩放系统需要做到低延迟，高画质和任意比例缩放效果三个基本需求。对于一个完整帧传输过程，首先是通过 IIC 配置模块，由 PC 端作为输入源向 FPGA 发送的初始图像分辨率信息为 1920*1080，60Hz。在建立通信后，通过 HDMI 输入输出将像素信息分为三个 10 位的颜色通道，这样的输入输出要求则要求我们在输入与输出之间增加十位颜色通道与三个八位 RGB 通道的编解码转换模块。通过译码得到的八位 RGB 数据输入包含预处理与插值的算法模块补全图像完成缩放功能的实现，并最终通过 HDMI将本帧图像显示在显示器上。本系统的数据暂存部分需要缓存三帧缩放后的图像数据，而我们采用的 DDR3 模块选择了 16 位输入，因此在输入缓存模块之前需要将三通道共 24 位的颜色数据转换成 16 位的 yCbCr 格式并进行 yuv444到 yuv422 的转换用以减小在保留良好视频像素点质量的情况下减小存储需要的空间。在实现了缩放的基础工程的基础上，我们使用易灵思 RISC-V 软核 Sapphire SoC来接取来自电脑上位机传来的用户控制信息。我们将 IP Sapphire SoC 软核的主频配置为 50MHz，并使能其 UART 以及对应的中断功能，而其他部件保持默认。更具体的使用过程中，由上位机向 Ti60F225 发送一串数据，RISC-V 软核接收到数据后解码出相应的视频参数，并将得到的参数写入 DDR 的相应位置（0x200）。每当帧同步信号传来，算法部分将读取存入 DDR 的视频参数，相应的调整算法的输入输出。将 UART 解码得到的参数，转换为具体算法与模式的控制信号，指导系统的视频流媒体输出.

(English Version)The overview of the scaler algorithm module. According to the design purpose, our video streaming scaling system needs to achieve three basic requirements: low latency, high image quality, and arbitrary scaling effects. For a complete frame transmission process, the initial image resolution information sent from the PC as the input source to the FPGA is 1920 * 1080, 60Hz, first through the IIC configuration module. After establishing communication, the pixel information is divided into three 10 bit color channels through HDMI input and output. This input and output requirement requires us to add a 10 bit color channel and three 8-bit RGB channel encoding and decoding conversion modules between the input and output. The eight bit RGB data obtained through decoding is inputted into an algorithm module that includes preprocessing and interpolation to complete the image scaling function. Finally, the frame image is displayed on the display through HDMI. The data temporary storage part of this system needs to cache three frames of scaled image data, and the DDR3 module we use selects 16 bit input. Therefore, before inputting the cache module, we need to convert the 24 bit color data of the three channels into 16 bit yCbCr format and perform yuv444 to yuv422 conversion to reduce the storage space required while maintaining good video pixel quality. On the basis of implementing the basic engineering of scaling, we use the Sapphire SoC with the RISC-V soft core of Yilingsi to receive user control information from the upper computer. We will configure the main frequency of the IP Sapphire SoC soft core to 50MHz and enable its UART and corresponding interrupt function, while keeping other components default. In a more specific usage process, the upper computer sends a string of data to Ti60F225. After receiving the data, the RISC-V soft core decodes the corresponding video parameters and writes the obtained parameters to the corresponding position (0x200) of the DDR. Whenever a frame synchronization signal is transmitted, the algorithm part will read the video parameters stored in DDR and adjust the algorithm's input and output accordingly. Convert the parameters obtained from UART decoding into control signals for specific algorithms and modes, guiding the system's video streaming output.

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/asynchronous%20FIFO.png)

(Chinese version)双线性插值和最近邻插值都是需要读两行才能进行计算，比如，第一行输入到缩放模块，然后缓存，等第二行输入后就可以计算了。但第三行输入进来，就使用第二行和第三行。也就是说，实际只用了一行数据输出两行数据。放大需要读一行写两行，所以放大模块需要2倍时钟。缩小可以用1倍甚至0.5倍时钟。因此，在image_cut选定放大区域（缩小后区域）后，将指定区域内数据传到缩放具体实现模块streamScaler的过程中的异步FIFO使用一倍时钟写入，两倍时钟读取。

(English Version)Bilinear interpolation and nearest neighbor interpolation both require reading two rows to perform calculations. For example, the first row is input to the scaling module, then cached, and after the second row is input, the calculation can be performed. But when the third line is inputted, use the second and third lines. That is to say, only one row of data was actually used to output two rows of data. Amplification requires reading one line and writing two lines, so the amplification module requires twice the clock. Shrinking can be done with a clock that is 1 or even 0.5 times smaller.Therefore, after selecting the enlarged area (reduced area) in image_cut, the asynchronous FIFO in the process of transferring data within the specified area to the specific implementation module streamScaler for scaling uses double clock writing and double clock reading.

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/Interpolation%20coefficient%20calculation.png)

interpolation coefficient calculation

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/fill_blank.png)

When users choose 'scaling down' mode, the empty area in the screen would be filled with 'black'

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/RAM_FIFO.png)

(Chinese version)为了后续计算插值运算所需要的系数和存储插值点周围的四个像素值，通常所采取的方法为使用两个行缓冲器来存储插值所需要的两行数据，但此方法不适用于对于实时性要求很高的视频图像的处理。另一种方法为采用帧存储器，通过“Ping-Pong”轮换的机制来实现对两行数据缓冲的方法，但这又需要设计帧存储器的控制逻辑，增加了所需的硬件成本，同时也会降低缩放模块的运行速度.最终采用一个包含多个 RAM 存储器的图像数据缓存阵列，这多个 RAM 的数据缓存顺序是通过一个 FIFO 来推进，称为 RAM_FIFO.

(English version)In order to calculate the coefficients required for subsequent interpolation operations and store the four pixel values around the interpolation point, the usual method is to use two row buffers to store the two rows of data required for interpolation. However, this method is not suitable for processing video images that require high real-time performance. Another method is to use frame memory, which uses a "Ping Pong" rotation mechanism to buffer two rows of data. However, this requires designing the control logic of the frame memory, which increases the required hardware cost and also reduces the running speed of the scaling module. Finally, an image data caching array containing multiple RAM memories is used, and the data caching order of these multiple RAM memories is promoted through a FIFO, called RAM-FIFO.

![image](https://github.com/ICscholar/Video-Stream-Scaler/blob/main/image/frame_buffer.png)

调用易灵思提供的钛金系列 DDR3 IP 核，可以通过软核实现 AXI4 全速模式并实现自动校准

Calling the titanium series DDR3 IP core provided by Efinity, AXI4 full speed mode and automatic calibration can be achieved through the soft core



