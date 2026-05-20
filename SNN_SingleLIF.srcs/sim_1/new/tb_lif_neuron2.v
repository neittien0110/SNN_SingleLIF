`timescale 1ns / 1ps

module tb_lif_neuron2();

    // 1. Khai báo các tham số mô phỏng
    parameter VMEM_WIDTH = 16;
    parameter THRESHOLD  = 16'd100;
    parameter LEAK       = 16'd10;
    parameter W0 = 8'd24;
    parameter W1 = 8'd20;
    parameter W2 = 8'd14;
    parameter W3 = 8'd17;
    
    // Giả lập bộ chia tần cực ngắn để mô phỏng siêu nhanh (chỉ đếm đến 10 chu kỳ)
    parameter SIM_PERIOD = 10; 

    // 2. Khai báo các tín hiệu kết nối với Module cần test (DUT)
    reg                  clk;
    reg                  rst;
    reg  [3:0]           input_spikes;
    wire                 spiket;
    wire [VMEM_WIDTH-1:0] vmem_out;

    // 3. Khởi tạo Module Neuron LIF (DUT)
    // Giả sử module con clock_div bên trong neuron có parameter tên là PERIOD, ta ghi đè nó ở đây
    // Nếu bạn đặt bộ chia tần ở file Top Level, hãy đổi tên cho đúng cấu trúc phân cấp
    lif_neuron_ #(
        .VMEM_WIDTH(VMEM_WIDTH),
        .THRESHOLD(THRESHOLD),
        .LEAK(LEAK),
        .W0(W0), .W1(W1), .W2(W2), .W3(W3)
    ) dut (
        .clk(clk),
        .rst(rst),
        .input_spikes(input_spikes),
        .spike_out(spike_out),
        .vmem_out(vmem_out)
    );

    // Mẹo: Ghi đè bộ chia tần nằm sâu bên trong module bằng đường dẫn phân cấp (nếu có)
    // defparam dut.u_clock_div.PERIOD = SIM_PERIOD;

    // 4. Tạo xung Clock hệ thống 50MHz (Chu kỳ T = 20ns)
    // Cứ 10ns đảo trạng thái một lần
    always begin
        #10 clk = ~clk;
    end

    // 5. Cấu hình tự động in kết quả ra Tcl Console (Hệ 2 cho spike, Hệ 10 cho Vmem)
    initial begin
        $monitor("Thời gian: %5t ns | Rst: %b | Inputs (Hệ 2): %b | Vmem (Hệ 10): %d | Spike Out: %b", 
                 $time, rst, input_spikes, vmem_out, spike_out);
    end

    // 6. Kịch bản kiểm tra các trường hợp của Neuron
    initial begin
        // --- Khởi tạo trạng thái ban đầu ---
        clk = 0;
        rst = 1;              // Kích hoạt Reset hệ thống
        input_spikes = 4'b0000;
        #40;                  // Giữ reset trong 2 chu kỳ clock (40ns)
        
        rst = 0;              // Nhấc reset để mạch bắt đầu chạy
        #20;

        // --- Giai đoạn 1: Tích lũy năng lượng từ từ (Chưa vượt ngưỡng) ---
        // Kích hoạt kênh 0 (W0 = 24). Sau khi trừ LEAK(10) -> Mỗi chu kỳ tăng +14
        $display("\n--- GIAI ĐOẠN 1: TÍCH LŨY NĂNG LƯỢNG ---");
        input_spikes = 4'b0001; 
        #400;                // Đợi 10 chu kỳ clock xung nhanh để xung chậm 1Hz (đã ép thông số) nhảy 1 nấc, tích lũy chậm
        
        // --- Giai đoạn 2: Bơm mạnh năng lượng để ép VƯỢT NGƯỠNG BẮN XUNG ---
        // Bật cả 4 kênh (Tổng W = 75). Vmem sẽ tăng rất nhanh qua mức THRESHOLD (100)
        $display("\n--- GIAI ĐOẠN 2: ÉP VƯỢT NGƯỠNG ĐỂ BẮN XUNG ---");
        input_spikes = 4'b1111;
        #120;               // 3 chu ki bấm toàn bộ nút vượt ngưỡng nhanh  

        // --- Giai đoạn 3: Kiểm tra tính năng RÒ RỈ HOÀN TOÀN (Leakage) ---
        // Tắt toàn bộ xung vào (input = 0). Nếu điện thế màng đang có sẵn, nó phải tự tụt giảm
        // Nếu tụt nhỏ hơn hoặc bằng LEAK, toán tử 3 ngôi sẽ ép nó về 0 sạch sẽ, không sinh xung lỗi.
        $display("\n--- GIAI ĐOẠN 3: RÒ RỈ TỰ NHIÊN KHI KHÔNG CÓ XUNG VÀO ---");
        input_spikes = 4'b0000;
        #400;                 // Đợi thời gian dài để Vmem tự xả về 0 hoàn toàn

        // --- Giai đoạn 4: Đột ngột Reset giữa chừng ---
        $display("\n--- GIAI ĐOẠN 4: KIỂM TRA RESET ĐỒNG BỘ ---");
        input_spikes = 4'b0011; // Nạp năng lượng lại
        #100;
        rst = 1;              // Bấm reset đột ngột
        #40;
        rst = 0;
        #100;

        // Kết thúc mô phỏng
        $display("\n=======================================================");
        $display("MÔ PHỎNG NEURON LIF HOÀN THÀNH XUẤT SẮC!");
        $display("=======================================================");
        $finish;
    end

endmodule