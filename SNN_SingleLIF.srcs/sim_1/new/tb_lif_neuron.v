`timescale 1ns / 1ps

module tb_lif_neuron();

    // 1. Khai báo các tham số mô phỏng (tùy chọn, giống như module gốc)
    parameter VMEM_WIDTH = 16;
    parameter THRESHOLD  = 16'd100;
    parameter LEAK       = 16'd10;

    // 2. Khai báo các tín hiệu kết nối với Module cần test (DUT)
    // Cổng INPUT của DUT -> Khai báo dạng 'reg' trong testbench để chủ động cấp giá trị
    reg                     clk;
    reg                     rst;
    reg  [3:0]              input_spikes;
    
    // Cổng OUTPUT của DUT -> Khai báo dạng 'wire' để hứng giá trị chạy ra
    wire                    spike_out;
    wire [VMEM_WIDTH-1:0]   vmem_out;

    // 3. Khởi tạo Module cần test (UUT - Unit Under Test hoặc DUT - Device Under Test)
    lif_neuron_bd_wrapper #(
        .VMEM_WIDTH(VMEM_WIDTH),
        .THRESHOLD(THRESHOLD),
        .LEAK(LEAK)
    ) dut (
        .clk(clk),
        .rst(rst),
        .input_spikes(input_spikes),
        .spike_out(spike_out),
        .vmem_out(vmem_out) // Cổng vmem_out bạn vừa thêm ở bước trước
    );

    // 4. Tạo xung Clock (Chu kỳ T = 10ns -> Tần số 100MHz)
    always begin
        #5 clk = ~clk; // Cứ sau 5ns thì đảo trạng thái clk một lần
    end

    // 5. Khối tạo kịch bản test (Stimulus Process)
    initial begin
        // --- Bước 5a: Khởi tạo giá trị ban đầu ---
        clk = 0;
        rst = 0;
        input_spikes = 4'b0000;
        #10; // Chờ 10ns

        // --- Bước 5b: Kích hoạt Reset hệ thống ---
        rst = 1;
        #20; // Giữ reset trong 2 chu kỳ clock (20ns)
        rst = 0; // Tắt reset
        #10;

        // --- Bước 5c: Cấp các xung đầu vào (Bơm năng lượng cho Neuron) ---
        // Giả sử bấm nút số 0 (W0 = 24)
        input_spikes = 4'b0001; 
        #10; // Giữ trong 1 chu kỳ clock. Lúc này vmem tăng lên khoảng 24 - 10 (leak) = 14
        
        input_spikes = 4'b0000; // Thả tay ra
        #20; // Chờ 2 chu kỳ clock để xem vmem tụt do LEAK hoặc giữ nguyên (tùy logic mạch)

        // Bơm mạnh liên tục để vượt ngưỡng THRESHOLD (100)
        // Bật cả nút 0 và nút 1 (W0 + W1 = 24 + 20 = 44)
        input_spikes = 4'b0011; 
        #30; // Giữ trong 3 chu kỳ clock để tích lũy điện thế màng
        
        input_spikes = 4'b0000;
        #50; // Chờ xem mạch có tự reset vmem và phát xung spike_out không

        // --- Bước 5d: Kết thúc mô phỏng ---
        $display("Mo phong hoan thanh!");
        $finish; // Dừng mô phỏng
    end

endmodule