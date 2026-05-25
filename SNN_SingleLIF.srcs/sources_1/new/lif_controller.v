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
    
    wire [VMEM_WIDTH-1:0] v_mem_incoming;
    wire [VMEM_WIDTH-1:0] v_mem_incoming_leak;
    
    /// Điện thế màng mới đã tính  xung năng lượng vào    
    assign v_mem_incoming = v_mem_current + incoming_energy;
            
    ///< Điện thế màng đã năng lượng vào và tính rò rì
    assign  v_mem_incoming_leak = (v_mem_incoming > LEAK) ?
                                  (v_mem_incoming - LEAK): {VMEM_WIDTH{1'b0}}  ;
    ///< Điện thế màng có vượt ngưỡng không
    ///< Fixed-bug: nếu viét code v_mem_incoming - LEAK >= THRESHOLD thì sai,
    ///             vì v_mem_incoming - LEAK có thể tràn số nên kết quả là số rất lớn nên sẽ hơn THRESHOLD
    ///             Cẩn bảo đảm bộ so sánh sẽ được dùng, chứ không phải bộ trừ.
    assign  reach_threshold = (v_mem_incoming_leak >= THRESHOLD);
        
    // Tổng hợp điều kiện Reset: 
    // Reset hệ thống HOẶC Đã bắn xung HOẶC Không đủ năng lượng bù Leak
    assign v_mem_reset  = rst || reach_threshold;
    
    assign v_mem_next   = v_mem_incoming_leak;
endmodule