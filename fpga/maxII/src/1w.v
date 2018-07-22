/*
*
*/
`define SPI
`define ONEWIRE
`define INDICATION_MAXII

module onewire_top(
  input  CLK_50,  //12 50MHz crystal
  input  clk,     //55
  input  cs,      //56
  output miso,    //57
  input  mosi,    //58
  output wire_out,//54
  input  wire_in, //61
  output led      //77
/*       -+-
          |
         4.7k 
          |
   54 ----+----->DQ DS18B20
          |
   61 ----+
*/
);

reg [2:0]divider = 3'h0;
reg clk0 = 0;
always @(posedge CLK_50) //25MHz
begin
  if (divider < 1)
  begin
    divider  = divider + 1;
  end
  else
  begin
    clk0 = ~clk0;
    divider = 0; 
  end 
end

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

// indication ->>
`ifdef INDICATION_MAXII
reg [31:0]count = 32'h0;
reg led_reg = 0;
assign led = led_reg;
always @(posedge CLK_50)
begin
  if (count < 10000000)
  begin
    count  = count + 1;
  end
  else
  begin
    led_reg = ~led_reg;
    count = 0; 
  end 
end
`endif
// <<- indication

endmodule
