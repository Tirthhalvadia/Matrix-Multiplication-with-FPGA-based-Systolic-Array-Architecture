`timescale 1 ps / 1 ps
`default_nettype none

module systolic
#
(
    parameter   D_W  = 8, //operand data width
    parameter   D_W_ACC = 16, //accumulator data width
    parameter   N1   = 4,
    parameter   N2   = 4,
    parameter   M    = 8
)
(
    input   wire                                        clk,
    input   wire                                        rst,
    input   wire                                        enable_row_count_A,
    output  wire    [$clog2(M)-1:0]                     pixel_cntr_A,
    output  wire    [($clog2(M/N1)?$clog2(M/N1):1)-1:0] slice_cntr_A,
    output  wire    [($clog2(M/N2)?$clog2(M/N2):1)-1:0] pixel_cntr_B,
    output  wire    [$clog2(M)-1:0]                     slice_cntr_B,
    output  wire    [$clog2((M*M)/N1)-1:0]              rd_addr_A,
    output  wire    [$clog2((M*M)/N2)-1:0]              rd_addr_B,
    input   wire    [D_W-1:0]                           A [N1-1:0], //m0
    input   wire    [D_W-1:0]                           B [N2-1:0], //m1
    output  wire    [D_W_ACC-1:0]                       D [N1-1:0], //m2
    output  wire    [N1-1:0]                             valid_D
);


wire    [D_W-1:0]       a_wire          [N1-1:0][N2-1:0];
wire    [D_W-1:0]       b_wire          [N1-1:0][N2-1:0];
wire    [N2-1:0]          valid_wire      [N1-1:0];
wire    [(D_W_ACC)-1:0] data_wire       [N1-1:0][N2-1:0];

control #
(
  .N1       (N1),
  .N2       (N2),
  .M        (M)
)
control_inst
(

  .clk                  (clk),
  .rst                  (rst),
  .enable_row_count     (enable_row_count_A),

  .pixel_cntr_B         (pixel_cntr_B),
  .slice_cntr_B         (slice_cntr_B),

  .pixel_cntr_A         (pixel_cntr_A),
  .slice_cntr_A         (slice_cntr_A),

  .rd_addr_A            (rd_addr_A),
  .rd_addr_B            (rd_addr_B)
);

//RTL below

wire    [D_W-1:0]       out_a[N1-1:0][N2-1:0];
wire    [D_W-1:0]       out_b[N1-1:0][N2-1:0];
wire    [(D_W_ACC)-1:0] out_data        [N1-1:0][N2-1:0];
wire    [N2-1:0]          out_valid       [N1-1:0];
reg     init_pe  [N1-1:0][N2-1:0];
reg x; //reg for init[0][0]
reg [D_W-1:0]  A_reg [N1-1:0];
reg [D_W-1:0]  B_reg [N2-1:0];
assign A_reg=A;
assign B_reg=B;
genvar i,j;
  generate
   for (i = 0; i < N1; i = i + 1) begin: genblk1 
    for (j = 0; j < N2; j = j + 1) begin: genblk1

      pe # (
        .D_W_ACC(D_W_ACC),
        .D_W(D_W)
      ) 
      pe_inst (
            .clk(clk),
            .rst(rst),
            .init(init_pe[i][j]),
            .in_a(a_wire[i][j]),
            .in_b(b_wire[i][j]),
            .out_b(out_b[i][j]),
            .out_a(out_a[i][j]),
            .in_data(data_wire[i][j]),
            .in_valid(valid_wire[i][j]),
            .out_data(out_data[i][j]),
            .out_valid(out_valid[i][j])
    );
    assign valid_wire[i][1]= out_valid[i][0];
    assign data_wire[i][1]= out_data[i][0];
      if (j==0) begin
	      assign data_wire[i][j]=0;
	      assign valid_wire[i][j]=0;
      end 
      if (j>0) begin
	     assign valid_wire[i][j]=out_valid[i][j-1];
	     assign data_wire[i][j]=out_data[i][j-1];
      end
     //generating init_pe[*][*] from init_pe[0][0]
     always @(posedge clk) begin
      if (rst) begin
        init_pe[i][j]<=0;
      end else begin
	      if (i == 0 && j == 0) begin
		      if (pixel_cntr_A == M-1) begin
			      if (slice_cntr_A == 0) begin
				      x <= 1;
			      end else begin
				      x <= 1;
			      end
		      end else begin
			      x <= 0;
		      end
		      init_pe[i][j] <= x ? 1 : 0;
	      end else if(i == 0 && j > 0) begin
		      init_pe[i][j] <= init_pe[i][j-1];
	      end else if(i > 0 && j==0) begin
		      init_pe[i][j] <= init_pe[i-1][j];
	    end else if (i>0 && j>0) begin
		    init_pe[i][j] <=(init_pe[i][j-1] & init_pe[i-1][j]) ;
        end
    end
    end
    //for PE[*][3] column
      if (j == N2-1) begin
        assign valid_D[i] = out_valid[i][j];
        assign D[i] = out_data[i][j];
      end
    assign a_wire[i][j] =j?out_a[i][j-1]:A_reg[i];
    assign b_wire[i][j] =i?out_b[i-1][j]:B_reg[j];

end
end
endgenerate
endmodule


