module lif_controller #(
    parameter VMEM_WIDTH = 16,
    parameter THRESHOLD  = 16'd100,
    parameter LEAK       = 16'd10
)(
    input  wire [VMEM_WIDTH-1:0] v_mem_current,   
    input  wire [VMEM_WIDTH-1:0] incoming_energy, 
    input  wire                  rst,            // Đổi sang đồng bộ mức cao

    output wire [VMEM_WIDTH-1:0] v_mem_next,      
    output wire                  v_mem_reset,     
    output wire                  reach_threshold        
);
    wire [VMEM_WIDTH-1:0] v_mem_incoming = v_mem_current + incoming_energy;
    wire [VMEM_WIDTH-1:0] v_mem_leaked   = v_mem_incoming - LEAK;
    /* ĐIện thế màng vẫn lớn hơn rò rỉ*/
    wire IsEnough = v_mem_incoming > LEAK;

    // Logic tính toán trạng thái
    assign reach_threshold    = (v_mem_leaked >= THRESHOLD);
        
    // Tổng hợp điều kiện Reset: 
    // Reset hệ thống HOẶC Đã bắn xung HOẶC Không đủ năng lượng bù Leak
    assign v_mem_reset  = rst || reach_threshold || (!IsEnough);
    
    assign v_mem_next   = v_mem_leaked;
endmodule