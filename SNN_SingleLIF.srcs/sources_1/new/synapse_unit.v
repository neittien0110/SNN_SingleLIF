`timescale 1ns / 1ps

/**
 * @brief Module tính toán tổng năng lượng tích lũy từ các xung đầu vào.
 * @param VMEM_WIDTH Độ rộng bus dữ liệu của hệ thống.
 */
module synapse_unit #(
    parameter ARCH = "FAST",
    parameter VMEM_WIDTH = 16,
    parameter WEIGHT_0   = 8'd24,
    parameter WEIGHT_1   = 8'd20,
    parameter WEIGHT_2   = 8'd14,
    parameter WEIGHT_3   = 8'd17
)(
    input  wire [3:0]           input_spikes,
    output wire [VMEM_WIDTH-1:0] total_energy
);
    generate
        if (ARCH == "ORI") begin : arch_original
            // Sử dụng logic chọn (Mux) để lấy Weight nếu có Spike, ngược lại lấy 0
            assign total_energy = (input_spikes[0] ? WEIGHT_0 : {VMEM_WIDTH{1'b0}}) +
                                  (input_spikes[1] ? WEIGHT_1 : {VMEM_WIDTH{1'b0}}) +
                                  (input_spikes[2] ? WEIGHT_2 : {VMEM_WIDTH{1'b0}}) +
                                  (input_spikes[3] ? WEIGHT_3 : {VMEM_WIDTH{1'b0}});
        end else begin : arch_fast
            // Bảo đảm cấu trúc bộ Adder Tree (Cây bộ cộng) được tạo ra.
            wire [VMEM_WIDTH-1:0] total_01, total_23;
            assign total_01 = (input_spikes[0] ? WEIGHT_0 : {VMEM_WIDTH{1'b0}}) +
                            (input_spikes[1] ? WEIGHT_1 : {VMEM_WIDTH{1'b0}});
            assign total_23 = (input_spikes[2] ? WEIGHT_2 : {VMEM_WIDTH{1'b0}}) +
                            (input_spikes[3] ? WEIGHT_3 : {VMEM_WIDTH{1'b0}});
            assign total_energy = total_01 + total_23;
        end 
    endgenerate
endmodule