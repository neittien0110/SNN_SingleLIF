module bus_splitter_4 (
    input  wire [3:0] bus_in,   // Bus đầu vào 4-bit (ví dụ từ nút bấm)
    output wire       out0,      // Sợi bit 0
    output wire       out1,      // Sợi bit 1
    output wire       out2,      // Sợi bit 2
    output wire       out3       // Sợi bit 3
);

    // Gán trực tiếp từng bit của bus vào từng ngõ ra
    assign out0 = bus_in[0];
    assign out1 = bus_in[1];
    assign out2 = bus_in[2];
    assign out3 = bus_in[3];

endmodule