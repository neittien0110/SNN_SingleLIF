`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 09:29:28 PM
// Design Name: 
// Module Name: register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module register #(
    parameter WIDTH = 16
)(
        input  wire [WIDTH-1:0] d,   
        output reg  [WIDTH-1:0] q,
        input  wire                  srst, // Reset đồng bộ, mức cao        
        input  wire                  clk
    );
    always @(posedge clk) begin
        if (srst) begin
            q <= {WIDTH{1'b0}}; // Xóa màng về 0
        end else begin
            q <= d; // Nạp giá trị mới sau khi tính toán
        end
    end
endmodule
