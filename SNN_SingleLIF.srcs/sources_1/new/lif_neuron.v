`timescale 1ns / 1ps

/**
 * @brief Module Neuron LIF chính (Top Module).
 * @details Sử dụng Reset đồng bộ để tối ưu hóa cho IP Core và FPGA Timing.
 */
module lif_neuron #(
    parameter VMEM_WIDTH = 16,     // Độ rộng bus VMEM (VMEM_WITCH)
    parameter THRESHOLD  = 16'd100,
    parameter LEAK       = 16'd10,
    parameter W0 = 8'd24, 
    parameter W1 = 8'd20, 
    parameter W2 = 8'd14, 
    parameter W3 = 8'd17
)(
    input  wire                 clk,          // Clock hệ thống
    input  wire                 rst_n,        // Reset đồng bộ, mức thấp
    input  wire [3:0]           input_spikes, // 4 kênh xung vào
    output reg                  spike_out     // Xung phát ra
);

    // Tín hiệu nội bộ
    wire [VMEM_WIDTH-1:0] incoming_energy;
    reg  [VMEM_WIDTH-1:0] v_mem;

    // --- INSTANTIATION: Kết nối khối tính năng lượng ---
    synapse_unit #(
        .VMEM_WIDTH(VMEM_WIDTH),
        .WEIGHT_0(W0), .WEIGHT_1(W1), .WEIGHT_2(W2), .WEIGHT_3(W3)
    ) synapse_inst (
        .input_spikes(input_spikes),
        .total_energy(incoming_energy)
    );

    // --- SEQUENTIAL LOGIC: Cập nhật Vmem (Reset Đồng Bộ) ---
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset hệ thống đồng bộ
            v_mem     <= {VMEM_WIDTH{1'b0}};
            spike_out <= 1'b0;
        end else begin
            // 1. Kiểm tra điều kiện phát xung (Thresholding)
            // Nếu V_next >= Threshold + Leak (Cơ chế đổ gàu nước)
            if (v_mem + incoming_energy >= THRESHOLD + LEAK) begin
                v_mem     <= {VMEM_WIDTH{1'b0}}; // Reset Vmem về 0 ngay lập tức
                spike_out <= 1'b1;               // Phát xung đầu ra
            end 
            else begin
                // 2. Nếu không phát xung, thực hiện tích lũy và rò rỉ
                spike_out <= 1'b0;
                
                // Vmem = Vmem + In - Leak (Đảm bảo không bị tràn dưới 0)
                if (v_mem + incoming_energy > LEAK) begin
                    v_mem <= v_mem + incoming_energy - LEAK;
                end else begin
                    v_mem <= {VMEM_WIDTH{1'b0}};
                end
            end
        end
    end

endmodule