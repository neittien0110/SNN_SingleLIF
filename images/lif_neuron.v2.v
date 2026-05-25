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
    input  wire                 rst,          // Reset đồng bộ, mức cao
    input  wire [3:0]           input_spikes, // 4 kênh xung vào
    output reg                  spike_out     // Xung phát ra
);

    // Tín hiệu nội bộ
    wire [VMEM_WIDTH-1:0] incoming_energy;
    wire [VMEM_WIDTH-1:0] v_mem_incoming;
    wire [VMEM_WIDTH-1:0] v_mem_incoming_leak;
    reg  [VMEM_WIDTH-1:0] v_mem;
    /* ĐIện thế màng đã vượt ngưỡng*/
    wire IsOverThreshold;
    /* ĐIện thế màng vẫn lớn hơn rò rỉ*/
    wire IsEnough;
    wire Vmem_Reset;

    // --- INSTANTIATION: Kết nối khối tính năng lượng ---
    synapse_unit #(
        .VMEM_WIDTH(VMEM_WIDTH),
        .WEIGHT_0(W0), .WEIGHT_1(W1), .WEIGHT_2(W2), .WEIGHT_3(W3)
    ) synapse_inst (
        .input_spikes(input_spikes),
        .total_energy(incoming_energy)
    );

    // ----- Tính toán tổ hơp
    /// Điện thế màng mới đã tính  xung năng lượng vào
    assign  v_mem_incoming = v_mem + incoming_energy;

    ///< Điện thế màng đã năng lượng vào và tính rò rì
    assign  v_mem_incoming_leak = v_mem_incoming - LEAK;

    ///< Điện thế màng có vượt ngưỡng không
    assign  IsOverThreshold = v_mem_incoming_leak >= THRESHOLD;
    ///< Điện thế màng có bị chảy hết ra ngoài không
    assign  IsEnough = v_mem_incoming > LEAK;

    ///< Gán lại điện thế màng về 0 khi Vượt ngượng, hoặc Rò rỉ toàn bộ, hoặc có Tín hiệu reset
    assign Vmem_Reset = (rst) || (IsOverThreshold) || (!IsEnough);
    
    // --- SEQUENTIAL LOGIC: Cập nhật Vmem (Reset Đồng Bộ) ---
    always @(posedge clk) begin
        if (Vmem_Reset) begin
            v_mem     <= {VMEM_WIDTH{1'b0}};
        end else begin
            v_mem <= v_mem_incoming_leak;
        end
    end

    /// ---- FlipFlop D chốt giá trị của xung Spike đầu ra. Nhưng rõ ràng sẽ bị chậm 1 chu kì
    always @(posedge clk) begin
        if (rst) begin
                spike_out <= 1'b0;
        end else begin    
            spike_out <= IsOverThreshold;
        end
    end

endmodule