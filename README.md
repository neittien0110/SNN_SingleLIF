# Single Neuron LIF

<!-- TOC -->

- [Mục tiêu](#mục-tiêu)
- [Biên dịch chương trình System Test và triển khai lên Dev-Kit TUL PYNQ-Z2](#biên-dịch-chương-trình-system-test-và-triển-khai-lên-dev-kit-tul-pynq-z2)
    - [Biên dịch](#biên-dịch)
    - [Triển khai trên Dev-Kit TUL PYNQ-Z2](#triển-khai-trên-dev-kit-tul-pynq-z2)
    - [Chạy chương trình](#chạy-chương-trình)
- [Thiết kế 1 neuron bằng code Verilog trực tiếp](#thiết-kế-1-neuron-bằng-code-verilog-trực-tiếp)
- [Thiết kế trực quan LIF bằng Block Diagram](#thiết-kế-trực-quan-lif-bằng-block-diagram)
    - [Toàn bộ LIF bằng Block Diagram](#toàn-bộ-lif-bằng-block-diagram)
    - [Module synapse_unit](#module-synapse_unit)
    - [Module V_mem](#module-v_mem)
    - [Module FlipFlop D](#module-flipflop-d)
    - [Module Controller](#module-controller)
- [Thiết kế System Test / Giao tiếp FPGA vs ARM core](#thiết-kế-system-test--giao-tiếp-fpga-vs-arm-core)
    - [Thiết kế khối System Test](#thiết-kế-khối-system-test)
    - [Triển khai trên board](#triển-khai-trên-board)
- [Simulation và Testbench](#simulation-và-testbench)
    - [Cách tạo một Testbench mới](#cách-tạo-một-testbench-mới)
    - [Chạy Testbench/Giả lập](#chạy-testbenchgiả-lập)

<!-- /TOC -->

## Mục tiêu

- Thiết kế 1 neuron SNN duy nhất và minh họa cách hoạt động
- Thiết kế bằng **Leaky Integrate-and-Fire** bằng 2 cách
  - Viết [code Verilog trực tiếp](#thiết-kế-1-neuron-bằng-code-verilog-trực-tiếp)
  - Thiết kế [trực quan bằng Block Diagram](#thiết-kế-trực-quan-lif-bằng-block-diagram)
- Tạo system test để kiểm thử bằng các phím bấm và xem số liệu trên UART.  

## Biên dịch chương trình System Test và triển khai lên Dev-Kit TUL PYNQ-Z2

### Biên dịch

1. **Mở project**:\
  Sử dụng phần mềm **Vivado** mở file dự án **SNN_SingleLIF.xpr**. \
  ![alt text](images/snn_singlelif.xpr.png)

2. **Top Level**\
   Hãy chắc chắn rằng thiết kế Top Level đã là **system_intergration_wrapper** (được in đậm) như trong ảnh.
    ![system_intergration_wrapper as Top Level](./images/system_intergration_wrapper.png)

3. **Biên dịch**:\
  Trong thanh **Flow Navigator**, ở mục cuối **Program and Debug**, bấm **Generate Bitstream**.\
  ![Generate Bitstream](images/GenerateBitstream.png)\
   Hoặc cách khác là trên thanh **Top Menu**, chọn **Flow**, bấm **Generate Bitstream**.\
  ![Generate Bitstream](images/GenerateBitstream2.png)

| Video |
| :------------: |
| [![Video](https://i3.ytimg.com/vi/2UxAF0Qpq-Y/default.jpg)](https://youtu.be/2UxAF0Qpq-Y) |

### Triển khai trên Dev-Kit TUL PYNQ-Z2

Video cấp nguồn và khởi động kit:
  [![Video](https://i3.ytimg.com/vi/3wKUKkg7544/default.jpg)](https://youtu.be/3wKUKkg7544) |

1. Copy các file cấu hình FPGA lên kit **TUL PYNQ-Z2**.\
   Chạy script **.\CollectBitStream.py** trong thư mục dự án, để đẩy các file [**.bit** và **.hwh**](https://neittien0110.github.io/FPGA-DevKits/Vivado.html#m%E1%BB%91i-quan-h%E1%BB%87-gi%E1%BB%AFa-file-bit-v%C3%A0-hwh) lên dev-kit.

   ```shell
    python .\CollectBitStream.py
    🚀 Dự án: SNN_SingleLIF
    ---------------------------------------------
    📝 BIT found: 2026-05-22 13:52:23 (7 phút trước)
    📝 HWH found: 2026-05-21 21:23:19 (996 phút trước)
    ---------------------------------------------
    📡 Đang kết nối tới PYNQ (192.168.2.99)...
    📤 Uploading BIT... OK
    📤 Uploading HWH... OK
    ---------------------------------------------
    ✅ THÀNH CÔNG! File đã nằm tại: /home/xilinx/SNN_SingleLIF
    💡 Trong Jupyter, bạn gọi: Overlay('SNN_SingleLIF.bit')
   ```

2. Copy các file chương trình chạy trên **ARM core** lên kit PYNQ-Z2, để trong cùng thư mục dự án.
    - **systemtest.py**
    - **runme.sh**
  
    Kết quả thư mục dự án trên **PYNQ-Z2** như sau (ảnh từ [WinSCP](https://winscp.net/eng/download.php)):\
  ![runtime files](images/RuntimeFolder.png)

3. Truy cập vào kit **PYNQ-Z2** qua **ssh**. Tải khoản xilinx, mật khẩu xilinx.

    ```console
    ssh xilinx@192.168.2.99
    ```

4. Vào thư mục dự án hiện thời.\
  Cấp quyền thực thi **x** cho file **./runme.sh**

    ```shell
    xilinx@pynq:~$ cd SNN_SingleLIF/
    xilinx@pynq:~/SNN_SingleLIF$ chmod +x ./runme.sh
    ```

| Video |
| :------------: |
| [![Video](https://i3.ytimg.com/vi/mC-djHauMh8/default.jpg)](https://youtu.be/mC-djHauMh8) |

### Chạy chương trình

1. Truy cập vào kit **PYNQ-Z2** qua **ssh**. Tải khoản xilinx, mật khẩu xilinx.

    ```console
    ssh xilinx@192.168.2.99
    ```

2. Thực thi file chạy dự án.

    ```shell
    xilinx@pynq:~$ cd SNN_SingleLIF/
    xilinx@pynq:~/SNN_SingleLIF$ ./runme.sh
    [sudo] password for xilinx:
    Nạp cấu hình FPGA SNN_SingleLIF.bit..
    --- Đang theo dõi Neuron LIF (Clock 1Hz) ---
    Hãy nhấn các nút trên board để tạo Spike đầu vào...
    Vmem:     0 | Spike Out: 0
    Vmem:    27 | Spike Out: 0
    Vmem:    34 | Spike Out: 0
    Vmem:    62 | Spike Out: 0
    Vmem:    76 | Spike Out: 0
    Vmem:    80 | Spike Out: 0
    Vmem:    70 | Spike Out: 0
    Vmem:    60 | Spike Out: 0
    Vmem:    64 | Spike Out: 0
    Vmem:     0 | Spike Out: 1 BẮN XUNG!
    Vmem:    45 | Spike Out: 0
    Vmem:    35 | Spike Out: 0
    ```

   ![CLick and see](images/runtime.png)

| Video |
| :------------: |
| [![Video](https://i3.ytimg.com/vi/3wKUKkg7544/default.jpg)](https://youtu.be/3wKUKkg7544) |

## Thiết kế 1 neuron bằng code Verilog trực tiếp

Viết [code Verilog trực tiếp](./SNN_SingleLIF.srcs/sources_1/new/lif_neuron.v)

## Thiết kế trực quan LIF bằng Block Diagram

**Lưu ý**: sau khi sửa file Block Diagram, bắt buộc phải chạy lại **Generate Output Products**. Còn chức năng **Create HDL Wrapper** thì chỉ cần chạy lần đầu tiên sau khi thiết kế xong Block Diagram
![Generate Output Products](images/Generate_Output_Products.png)

### Toàn bộ LIF bằng Block Diagram

![Single Neuron LIF in Block Diagram](images/lif_neuron_bd.png)

- Module [**synapse_unit**](#module-synapse_unit) thể hiện việc tính tổng tích lũy các spike đầu vào và trọng số tương ứng
- Module [**V_mem**](#module-v_mem) chỉ là một thành ghi vào/ra song song, với tham số độ rộng bus **Width=16**.
- Module [**dff_0**](#module-flipflop-d) chỉ là một Flip Flop D để chốt xung **Spike** đầu ra, triệt tiêu hazard.
- Module [**controller**](#module-controller) là thuật toán quan trọng để xử lý 3 thao tác: tăng, giảm, so sánh điện thế màng Vmem.

Khi sử dụng công cụ **RTL Analysis** trong thanh **Flow Navigation**,
![Single Neuron LIF in RTL Analysis](./images/lif_neuron_rtl.png)

### Module synapse_unit

Các khớp thần kinh nối. [**Mã nguồn Verilog**](./SNN_SingleLIF.srcs/sources_1/new/register.v).

![synapse in RTL Analysis](./synapse_unit_arch_fast.png)
[Back to parent design](#thiết-kế-trực-quan-lif-bằng-block-diagram)

### Module V_mem

- Là thanh ghi [**Mã nguồn Verilog**](./SNN_SingleLIF.srcs/sources_1/new/synapse_unit.v).
- vào song song, ra song song
- Tùy biến được độ rộng bus với tham số **Width=16**.

![Vmem](images/vmem.png)
[Back to parent design](#thiết-kế-trực-quan-lif-bằng-block-diagram)

### Module FlipFlop D

- Là thanh ghi 1 bit [**Mã nguồn Verilog**](./SNN_SingleLIF.srcs/sources_1/new/dff.v).
- Là một Flip Flop D để chốt xung **Spike** đầu ra, có tác dụng triệt tiêu hazard.

![FlipFlop D](images/dff.png)
[Back to parent design](#thiết-kế-trực-quan-lif-bằng-block-diagram)

### Module Controller

- Là mạch tổ hợp [**Mã nguồn Verilog**](./SNN_SingleLIF.srcs/sources_1/new/lif_controller.v).
- Kiếm soát việc tăng Vmem theo spike đâu vào
- Kiểm soát việc trừ Vmem định kì (rò rỉ)
- Kiểm soát so sánh ngưỡng để tạo xung Spike đầu ra.
- Khi phát sinh Spike đầu ra thì đồng thời xóa Vmem về 0.

![lif controller](./images/lif_controller.png)

## Thiết kế System Test / Giao tiếp FPGA vs ARM core

### Thiết kế khối System Test

- Thiết kế chính bằng Block Diagram.
- Bổ sung thêm các khối để tương tác với **ARM Core**.\
  Trong **Block Design**, kéo thả các khối
  - **ZYNQ7 Processing System**,
  - **AXI GPIO**,\
     và cho hệ thống tự bổ sung các khối còn lại là
    - **AXI Smart Connect**,
    - **Processor System Reset**
- Do mục tiêu *dùng 4 nút Button để tạo xung Spike đầu vào, và Led để báo hiệu trạng thái bấm đã được ghi nhận* nên sẽ nối **AXI GPIO** với 4 led ngoài nên sẽ
  - dùng tính năng **Make External** để nối với chân pin cứng trên FPGA
  - Tìm thông tin về **Base Address** của khối này trong tab **Address Editor** của toàn bộ **Block Design**
- Tạo thiết kế SoftIP mới để điều khiển led đơn. **Project Manager / Add Sources**. \
   Đặt tên SoftIP là **decoder_2to4.v**
- Tích hợp **decoder_2to4.v** vào design chung trong **Block Design** bằng tính năng **Add Module**.
- Gán **chân pin mềm của SoftIP top design** với **chân pin cứng cùa FPGA** bằng cách chạy **Run Systhesis** và mở cửa sổ **Top menu / Layout / IO Planning**.

### Triển khai trên board

- Trong thanh **Flow Navigator**, thực hiện **Implementation**. ![Click Implementation](./images/ClickImplementation.png)
- Ánh xạ chân pin của FPGA và chân pin của IP core mới thiết kế

  Board Parts | FPGA Pin | My Design
  --: | :--: | :--
  SW0, với 2 giá trị 3v3 và 0v | M20 | srst_0
  BTN0, tích cực mức cao | D19 | buttons(0)
  BTN1, tích cực mức cao | D20 | buttons(1)
  BTN2, tích cực mức cao | L20 | buttons(2)
  BTN3, tích cực mức cao | L19 | buttons(3)
  LED0, tích cực mức cao | R14 | led0
  LED1, tích cực mức cao | P14 | led1
  LED2, tích cực mức cao | N16 | led2
  LED3, tích cực mức cao | M14 | led3
  rgb_leds[0], R | N15 | clk1hz

  Đồng thời đặt mức điện áp I/O std của tất cả các chân pin là LVCMOS33
  
## Simulation và Testbench

### Cách tạo một Testbench mới

1. Trong **Flow Navigation** bar, trong mục **Project Manager** chọn **Add Source**.\
    ![Add Source](images/AddSource.png)
2. Ở cửa sổ **Add Source**, chọn **Add or create simulation sources**.\
  ![Add Simulation Source](images/AddSimulationSource.png)
3. Click **Create File**.\
   ![Create New Simulation](images/CreateNewSimulation.png)
4. Ví dụ về testbench, file [tb_lif_neuron.v](./SNN_SingleLIF.srcs/sim_1/new/tb_lif_neuron.v), file [tb_lif_neuron2.v](./SNN_SingleLIF.srcs/sim_1/new/tb_lif_neuron2.v)

### Chạy Testbench/Giả lập

1. **Top Level** của Simulation là riêng, không trùng với Top Level của việc biên dịch:\
   Hãy chắc chắn rằng thiết kế Top Level đã file mong muốn (được in đậm). Ví dụ như trong ảnh\
    ![Top Level f Simulation](images/TopLevelOfSimulation.png)
2. Trong **Flow Navigation** bar, trong mục **Simulation** chọn **Run Simulation**.\
   ![Run Simulation](images/RunSimulation.png)
3. Ví dụ về một Waveform kết quả.\
    ![waveform lif neuroun2](images/waveform_lif_neuroun2.png)
