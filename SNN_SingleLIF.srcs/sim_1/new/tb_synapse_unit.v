`timescale 1ns / 1ps

module tb_synapse_unit();

    // 1. Khai báo các tham số mô phỏng (Khớp với cấu hình hệ thống của bạn)
    parameter VMEM_WIDTH = 16;
    parameter W0 = 8'd24;
    parameter W1 = 8'd20;
    parameter W2 = 8'd14;
    parameter W3 = 8'd17;

    // 2. Khai báo các tín hiệu kết nối với Module cần test (DUT)
    reg  [3:0]              input_spikes; // Ngõ vào điều khiển bằng reg
    wire [VMEM_WIDTH-1:0]   total_energy; // Ngõ ra hứng bằng wire

    // 3. Khởi tạo Module Synapse Unit (DUT)
    synapse_unit #(
        .VMEM_WIDTH(VMEM_WIDTH),
        .WEIGHT_0(W0),
        .WEIGHT_1(W1),
        .WEIGHT_2(W2),
        .WEIGHT_3(W3)
    ) dut (
        .input_spikes(input_spikes),
        .total_energy(total_energy)
    );

    // 4. Kịch bản kiểm tra (Vì synapse_unit là mạch tổ hợp thuần túy, không cần clock)
    initial begin
        // --- Trường hợp 0: Không có xung nào kích hoạt ---
        input_spikes = 4'b0000;
        #10; // Chờ 10ns để mạch cập nhật và quan sát
        
        // --- Trường hợp 1: Chỉ kênh 0 có xung (Kỳ vọng: total_energy = W0 = 24) ---
        input_spikes = 4'b0001;
        #10;

        // --- Trường hợp 2: Chỉ kênh 1 có xung (Kỳ vọng: total_energy = W1 = 20) ---
        input_spikes = 4'b0010;
        #10;

        // --- Trường hợp 3: Kênh 2 và kênh 3 cùng có xung cùng lúc (Kỳ vọng: W2 + W3 = 14 + 17 = 31) ---
        input_spikes = 4'b1100;
        #10;

        // --- Trường hợp 4: Cả 4 kênh cùng nổ xung một lúc (Kỳ vọng: W0+W1+W2+W3 = 24+20+14+17 = 75) ---
        input_spikes = 4'b1111;
        #10;

        // --- Quay về trạng thái nghỉ ---
        input_spikes = 4'b0000;
        #10;
        
        // --- Tác động tối đa ---
        input_spikes = 4'b1111;
        #20;

        // Kết thúc mô phỏng
        $display("Mo phong phep cong trong Synapse Unit hoan thanh!");
        $finish;
    end

endmodule