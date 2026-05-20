`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2026 12:27:31 AM
// Design Name: 
// Module Name: button_cached
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


module button_cached(
    input wire clk,
    input wire rst,
    input wire d,
    output reg q
    );
    
    wire d2;
    
    assign d2 = d | q ; 
 
    always @(posedge clk) begin
        if (rst) begin
            q <= 0;
        end else begin
            q <= d2;
        end;
    end   
endmodule
