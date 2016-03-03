## 视频监控系统 -- 服务器端（Server）

### Overview

#### Capture
文件capture.cpp和capture.hpp是类Capture的源文件，采集是视频监控系统的第一步，所以在主函数中
调用创建的第一个类就是Capture，具体的函数及实现都已在代码中注明，可以查看。

#### Encoder
文件encoder.cpp和encoder.hpp是类Encoder的源文件，编码压缩是视频监控系统的第二部，所以在主
函数中调用创建的第二类就是Encoder，该类中调用了x264开源编码的库的代码，所以在自动编译时要
加上<u>-lx264</u>

#### Sender
文件sender.cpp和sender.hpp是类Sender的源文件，码流发送时视频监控系统的第三部分，所以在主函数中调用第三个类是Sender，该类中使用了开源的Jrtp库，用以实现通过RTP和RTCP协议的码流传输，从而在自动编译时需要加入-ljrtp和-lpthread两个动态链接库。

### 测试用例
测试用例queue_test.cpp并没有直接加到Makefile当中，而是需要自己手动编译的。所幸，多线程测试用例并没有使用第三方库，只调用了一个pthread库，所以下面的一条命令就可以搞定了
``` Sh
clang++ queue_test.cpp -o queue_test -lpthread
```
对了，还需要提醒一下的是，多线程测试用例使用的缓存文件可能没有创建，所以需要测试用户自己来创建。

### Worklog
1.起初为了能够实现实时的视频流，洒家想了两种方案：
- 方案 1：在服务器端以二百帧为单位，每采集二百帧调用发送函数，向外发送数据形成视频流；
- 方案 2：以每帧为单位，来实现边采集边推流的方式。

从现在的代码来看，洒家使用的是第二种，因为其相较于第一种方案，省去了文件分割的烦恼。而在第一种方案中，每当采集完200帧数据后，需要按照H.264的定义来将文件分解为一个个的NALU单元来向外发送，但是这个过程非常难做，通过我的实验，始终没能做到分割之后成功发送，所以，洒家使用了第二种的方案。

2.起始帧（或截止帧）数据为空问题的修正，是利用的RTCP控制协议里面的APP包实现的，通过将起始帧的标志加在APP数据中在接收端，通过判断控制包数据内容，来禁用一次文件的关闭（close()）或者是禁用一次文件的打开（open()）。

#### Some notices：
由于现在的所有试验都是基于PC端的，所以还没有将代码向嵌入式开发板上移植，因此在自动化编译时，使用的编译器都是clang++。如果在后期需要向开发板上移植时，可以修改编译器为arm-linux-g++。服务器端使用的第三方库如下所示：
- x264
- jrtplib
- FFmpeg(用于客户端的解码实验)

### jrtplib向Android的移植
- 1.由于Android实现的bionic libc不同于glibc，所以pthread_cancel函数在blibc当中并没有实现。因此在移植的过程中，需要修改**jthread**中的src/pthread/jthread.cpp第125行代码，注释pthread_cancel函数，改为pthread_kill(threadid, SIGUSR1).
- 2.由于已经修改了pthread_cancel函数，所以**jrtplib**中的example文件夹中的所有示例代码都不要再编译了，否则会出现无法移植的情况。具体的只需修改CMakeLists.txt中的add_subdirectory(examples)即可.
