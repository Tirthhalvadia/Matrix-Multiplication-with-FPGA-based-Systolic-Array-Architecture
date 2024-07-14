`timescale 1 ps / 1 ps

module pe
#(
    parameter   D_W_ACC  = 64, //accumulator data width
    parameter   D_W      = 32  //operand data width
)
(
    input   wire                    clk,
    input   wire                    rst,
    input   wire                    init,
    input   wire    [D_W-1:0]       in_a,
    input   wire    [D_W-1:0]       in_b,
    output  reg     [D_W-1:0]       out_b,
    output  reg     [D_W-1:0]       out_a,

    input   wire    [(D_W_ACC)-1:0] in_data,
    input   wire                    in_valid,
    output  reg     [(D_W_ACC)-1:0] out_data,
    output  reg                     out_valid
);

// Insert your RTL here
reg [D_W_ACC-1:0] accumulator = 0;
reg [(D_W_ACC)-1:0] in_data_piped;
reg in_valid_piped;
always @(posedge clk) begin
    if (rst) begin
        out_a <= 0;
        out_b <= 0;
	in_data_piped<=0;
	in_valid_piped<=0;
	accumulator<=0;
    end else begin
	in_data_piped <= in_data;
        in_valid_piped <=in_valid;
        if (init) begin
            out_a <= in_a;
            out_b <= in_b;
            accumulator <= in_a * in_b;
        end else begin
            out_a <= in_a;
            out_b <= in_b;
            accumulator <= accumulator + in_a * in_b;
        end
    end
end

always @(posedge clk) begin
	if (init) begin
		out_data<=accumulator;
		out_valid <= 1;
        end else if (in_valid_piped) begin
            out_valid <= 1;
	    out_data <= in_data_piped;
    end else begin
	    out_valid<=0;

	end
	
end
endmodule

