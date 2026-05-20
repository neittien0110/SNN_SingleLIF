`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 09:29:28 PM
// Design Name: 
// Module Name: dff
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

/** D Flip flop */
module dff(
    input wire d,            
    output reg q,
    input wire srst,    ///< Tin hiệu Reset đồng bộ mức cao
    input wire clk    
    );
    always @(posedge clk) begin
        if (srst) q <= 1'b0;
            else q <= d;
    end
endmodule
