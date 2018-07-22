/*
*
*/
`define SPI
`define ONEWIRE
`define INDICATION

module onewire_top(
  input CLK_50,
                    //GND       CON26A 3    GND         blue    25
  input clk,        //HSYNC     CON26A 8    SCK   PA14  orange  23
  input cs,         //VSYNC     CON26A 7    CS    PA13  red     24
  input mosi,       //PS2_DAT   CON26A 5    MOSI  PA15  green   19
  output miso,      //PS2_CLK   CON26A 6    MISO  PA16  yellow  21

  output wire_out,  //VB0       CON26A 10
  input  wire_in    //VB2       CON26A 9 (connected to wire_out VB0)
/*       -+-
          |
         4.7k 
          |
  VB0 ----+----->DQ DS18B20
          |
  VB2 ----+
*/

`ifdef INDICATION
  ,

  output DS_A,DS_B,DS_E,DS_F,
  output DS_C,DS_D,DS_G,DS_DP,
  output DS_EN1,DS_EN2,DS_EN3,DS_EN4
`endif
);

wire clk0;
wire n_rst;
pll pll_inst(
//   .areset(SW),
   .inclk0(CLK_50),
   .c0(clk0),
//,
//   .c1(clk1),
//   .c2(clk2),
   .locked (n_rst)
);

wire [7:0]buf_byte_1w_rd;
wire [15:0]buf_byte_spi_rd;
wire [2:0]state;
reg resense;
wire busy;
wire spi_done;


`ifdef SPI
SPI_slave spi(
  .nRST(n_rst),
  .CLK(clk0),
  .SCK(clk),
  .MOSI(mosi),
  .SPI_WR_BUF(buf_byte_1w_rd), /* data read from 1wire */
  .MISO(miso),
  .CS(cs),
  .SPI_RD_BUF(buf_byte_spi_rd), /* data read from SPI */
  .SPI_DONE(spi_done),
  .STATE(state)
);
`else
assign miso = mosi;
`endif

reg  reset = 0;
reg  read_byte = 0;
reg  write_byte = 0;

`ifdef ONEWIRE
reg [15:0] buf_byte_1w_wr;  /* write to 1w */
reg       spi_data_rdy = 0;


one_wire onewire(
  .reset(reset),
  .read_byte(read_byte),
  .write_byte(write_byte),
  .wire_out(wire_out),
  .wire_in(wire_in),
  .presense(presense),
  .busy(busy),
  .in_byte(buf_byte_1w_wr[7:0]),
  .out_byte(buf_byte_1w_rd),
  .clk(clk0)
);
`endif

reg onewire_dev_present = 0;

`ifdef ONEWIRE
always @(posedge clk0, posedge spi_done)begin
  if (spi_done == 1)begin
    buf_byte_1w_wr <= buf_byte_spi_rd;
    spi_data_rdy <= 1;
  end
  else
    spi_data_rdy <= 0;
end

always @(posedge clk0, posedge spi_data_rdy)begin
/*
  if (n_rst == 0)begin
    reset <= 0;
    read_byte = 0;
    write_byte = 0;
    onewire_dev_present <= 0;
  end
  else begin
*/  
    case (buf_byte_1w_wr[15:8]) 
      8'h01:begin /* 1wire reset */
        if (spi_data_rdy) begin
          onewire_dev_present <= 0;
          reset <= 1;
          read_byte = 1'b0;
          write_byte = 1'b0;
        end
        else begin
          if (presense)
            onewire_dev_present <= 1;
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
        end
      end
      8'h02:begin /* 1wire write */
        if (spi_data_rdy) begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b1;
        end
        else begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
        end
      end
      8'h03:begin /* 1wire read */
        if (spi_data_rdy) begin
          reset = 1'b0;
          read_byte = 1'b1;
          write_byte = 1'b0;
        end
        else begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
        end
      end

      8'h04:begin /* buffer read w/o 1wire read */
        reset = 1'b0;
        read_byte = 1'b0;
        write_byte = 1'b0;
      end

      default:begin
        reset = 1'b0;
        read_byte = 1'b0;
        write_byte = 1'b0;
      end
    endcase
/*    
  end
*/  
end 
`else
reg wire_out_reg = 0;
assign wire_out = wire_out_reg;
always @(posedge clk0, posedge spi_data_rdy)begin
    case (buf_byte_1w_wr) 
      8'h01:begin /* 1wire 0 */
        if (spi_data_rdy) begin
          wire_out_reg <= 0;
        end
      end
      8'h02:begin /* 1wire 1 */
        if (spi_data_rdy) begin
          wire_out_reg <= 1;
        end
      end
      default:begin
        if (spi_data_rdy)
          onewire_dev_present <= 0;
      end
    endcase
end
`endif

/* indication ->> */
`ifdef INDICATION
wire [6:0]ds_reg;
wire [3:0]ds_en;
assign {DS_G,DS_F,DS_E,DS_D,DS_C,DS_B,DS_A} = ds_reg ;
assign {DS_EN1,DS_EN2,DS_EN3,DS_EN4} = ds_en;

reg [31:0]count;
assign DS_DP = onewire_dev_present;

reg  [3:0]num_dt[3:0];
dt_module dt_ct(
  .clk(clk0),
  .num1(num_dt[0]),
  .num2(num_dt[1]),
  .num3(num_dt[2]),
  .num4(num_dt[3]),
  .ds_en(ds_en),
  .ds_reg(ds_reg)
);

always @(posedge clk0)
begin
  if (count < 12000000)
    count = count + 1;
  else
  begin
    count  = 0;
  end
  num_dt[0] = buf_byte_1w_wr[11:8];
  num_dt[1] = buf_byte_1w_wr[15:12];
//  num_dt[2] = state;
  num_dt[2] = buf_byte_1w_rd[3:0];
  num_dt[3] = buf_byte_1w_rd[7:4];
end

`endif
/* <<- indication */

endmodule
