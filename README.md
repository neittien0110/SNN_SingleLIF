# Single Neuron LIF

[[TOC]]

## Mục tiêu

- Thiết kế 1 neuron SNN duy nhất và minh họa cách hoạt động
- Thiết kế bằng **Leaky Integrate-and-Fire** bằng 2 cách
  - Viết [code Verilog trực tiếp](#thiết-kế-1-neuron-bằng-code-verilog-trực-tiếp)
  - Thiết kế [trực quan bằng Block Diagram](#thiết-kế-trực-quan-bằng-block-diagram)
- Tạo system test để kiểm thử bằng các phím bấm và xem số liệu trên UART.  

## Thiết kế 1 neuron bằng code Verilog trực tiếp

Viết [code Verilog trực tiếp](./SNN_SingleLIF.srcs/sources_1/new/lif_neuron.v)

## Thiết kế trực quan bằng Block Diagram

- Thiết kế chính bằng Block Diagram.
![Single Neuron LIF in Block Diagram](images/lif_neuron_bd.png)
- Module [**synapse_unit**](./SNN_SingleLIF.srcs/sources_1/new/synapse_unit.v) thể hiện việc tính tổng tích lũy các spike đầu vào và trọng số tương ứng
- Module [**V_mem**](./SNN_SingleLIF.srcs/sources_1/new/register.v) chỉ là một thành ghi vào/ra song song, với tham số độ rộng bus **Width=16**.
- Module [**dff_0**](./SNN_SingleLIF.srcs/sources_1/new/dff.v) chỉ là một Flip Flop D để chốt xung **Spike** đầu ra, triệt tiêu hazard.

## Thiết kế System Test

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
  
## Chạy chương trình trên TUL PYNQ-Z2

- Chạy trực tiếp python trên shell

    ```shell
     source /etc/profile.d/pynq_venv.sh
     sudo -E python3 ./LedSwitch.py
    ```

- Chạy qua shell script (đã bao gồm 2 lệnh trên)

    ```shell
     ./runme.sh
    ```

- Chạy qua Jupiter Notebook

- Để chương trình tự chạy khi khởi động cùng với Dev-Kit
  - Mở bảng lập lịch Cron: ```shell crontab -e```
  - Bổ sung lệnh khởi động: ```@reboot /home/xilinx/runboot.sh```
  - và thực hiện gọi file python trong đó.
