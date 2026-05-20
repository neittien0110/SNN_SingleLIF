`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2026 01:48:31 PM
// Design Name: 
// Module Name: clock_div_1m
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


module clock_div_1m  #(
       parameter PERIOD = 50_000_000
    ) (
    input  wire clk_in,   // 50MHz
    input  wire reset,    // Reset hệ thống
    output reg  clk_out   // Xung ra 1Hz, duty cycle 50%
    );

    // 25,000,000 cần 25 bit để lưu trữ (2^25 = 33,554,432)
    reg [24:0] counter;
     always @(posedge clk_in) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == ((PERIOD >> 1) - 1)) begin // Đếm đủ 0.5 giây
                counter <= 0;
                clk_out <= ~clk_out;        // Đảo trạng thái xung
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
