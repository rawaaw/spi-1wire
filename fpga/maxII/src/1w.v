/*
*
*/
`define SPI
`define WIRE
`define ONEWIRE
//`define SINGLEWIRE
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

wire [63:0]buf_byte_1w_rd;
wire [63:0]buf_byte_spi_rd;
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
wire presence;
reg  read_byte = 0;
reg  write_byte = 0;
reg  read_swire_data = 0;

`ifdef WIRE
reg [63:0] buf_byte_1w_wr;  /* write to 1w */
reg       spi_data_rdy = 0;
reg [5:0] start_bit;
reg [5:0] end_bit;
`endif

`ifdef ONEWIRE
one_wire onewire(
  .reset(reset),
  .read_byte(read_byte),
  .write_byte(write_byte),
  .wire_out(wire_out),
  .wire_in(wire_in),
  .presence(presence),
  .busy(busy),
  .in_byte(buf_byte_1w_wr[15:8]),  /* 1wire command */
  .out_byte(buf_byte_1w_rd),
  .start_bit(start_bit),
  .end_bit(end_bit),
  .clk(clk0)
);
`endif

`ifdef SINGLEWIRE
single_wire singlewire(
  .read_wire(read_swire_data),
  .wire_out(wire_out),
  .wire_in(wire_in),
  .busy(busy),
  .out_data(buf_byte_1w_rd[63:24]),
  .clk(clk0)
);
`endif

reg onewire_dev_present = 0;

`ifdef WIRE
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
    /*
       [7:4] - cmd (0 - rst ,1 - wr ,2 - rd 1w, 3 - rd buf)
       [3:0] - 0 means 1 bit, 1-8 means 1-8 bytes per cycle)
    */
    case (buf_byte_1w_wr[7:4]) 
      4'h0:begin /* 1wire reset */
        if (spi_data_rdy) begin
          onewire_dev_present <= 0;
          reset <= 1;
          read_byte = 1'b0;
          write_byte = 1'b0;
          read_swire_data = 1'b0;
        end
        else begin
          if (presence)
            onewire_dev_present <= 1;
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
          read_swire_data = 1'b0;
        end
      end
      4'h1:begin /* 1wire write */
        if (spi_data_rdy) begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b1;
          read_swire_data = 1'b0;
          start_bit = 0;
          end_bit = 7;
        end
        else begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
          read_swire_data = 1'b0;
        end
      end
      4'h2:begin /* 1wire read 1,2,4,8 byte */
        if (spi_data_rdy) begin
          reset = 1'b0;
          read_byte = 1'b1;
          write_byte = 1'b0;
          read_swire_data = 1'b0;
          case (buf_byte_1w_wr[3:0]) /* read bytes 1-8 (0 means 1 bit) */
            4'h00:begin       /* 1 bit */
              start_bit = 63;
              end_bit = 63;
            end
            4'h01:begin       /* 1 byte */
              start_bit = 56;
              end_bit = 63;
            end
            4'h02:begin       /* 2 bytes */
              start_bit = 48;
              end_bit = 63;
            end
            4'h03:begin       /* 3 bytes */
              start_bit = 40;
              end_bit = 63;
            end
            4'h04:begin       /* 4 bytes */
              start_bit = 32;
              end_bit = 63;
            end
            4'h05:begin       /* 5 bytes */
              start_bit = 24;
              end_bit = 63;
            end
            4'h06:begin       /* 6 bytes */
              start_bit = 16;
              end_bit = 63;
            end
            4'h07:begin       /* 7 bytes */
              start_bit = 8;
              end_bit = 63;
            end
            4'h08:begin       /* 8 bytes */
              start_bit = 0;
              end_bit = 63;
            end
            default:begin
              start_bit = 0;
              end_bit = 0;
            end
          endcase
        end
        else begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
          read_swire_data = 1'b0;
        end
      end

      4'h3:begin /* buffer read w/o 1wire read */
        reset = 1'b0;
        read_byte = 1'b0;
        write_byte = 1'b0;
        read_swire_data = 1'b0;
      end

      4'h4:begin /* single wire read */
        if (spi_data_rdy) begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
          read_swire_data = 1'b1;
        end
        else begin
          reset = 1'b0;
          read_byte = 1'b0;
          write_byte = 1'b0;
          read_swire_data = 1'b0;
        end 
      end

      default:begin
        reset = 1'b0;
        read_byte = 1'b0;
        write_byte = 1'b0;
        read_swire_data = 1'b0;
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
