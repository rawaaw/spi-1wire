module SPI_slave(
  input        nRST,
  input        CLK,
  input        SCK,
  input        MOSI,
  input  [7:0] SPI_WR_BUF,  //write to SPI
  output reg   MISO,
  input        CS,
  output [15:0] SPI_RD_BUF, //read from SPI
  output       SPI_DONE,
  output [2:0] STATE
);
  
  reg [15:0]    dat_out_reg = 16'h0;
  reg [7:0]    dat_in_reg = 8'h0;
  
  reg clk_in;
  reg cs_in;
  reg sSCK;
  reg sCS;

  always @(posedge CLK)begin
    clk_in <= SCK;
    cs_in  <= CS;
  end
  always @(posedge CLK)begin
    sSCK <= clk_in;
    sCS <= cs_in;
  end

  reg [1:0]cs_state = 0;
  reg start = 0;
  reg stop = 0;

  assign SPI_DONE = stop;  /* pulse on CS 0 -> 1: SPI cycle done and all data in buffer */
  assign SPI_RD_BUF = dat_out_reg; /* data read from SPI */
  assign STATE = cs_state;


  always @(posedge CLK)begin
    case (cs_state)
      0:begin
        if (sCS == 0)
          cs_state <= 1;
        start <= 0;
        stop <= 0;
      end
      1:begin
        if (sCS == 1)begin
          cs_state <= 0;
        end  
        else if (sSCK == 0)begin
          cs_state <= 2;
          start <= 1;
        end
      end
      2:begin
        start <= 0;
        if (sCS == 1)begin
          cs_state <= 0;
          stop <= 1;
        end  
      end
      default:begin end
    endcase
  end
 
  always @(posedge CLK)begin
    if (sCS == 0)
      MISO  <= dat_in_reg[7];
    else
      MISO  <= 1'b1;
  end
   
  always @(negedge sSCK, posedge start, posedge stop)begin
    if (start)
      //dat_in_reg <= 8'hA5;
      dat_in_reg <= SPI_WR_BUF;
    else if (stop)begin
      //SPI_RD_BUF <= (~dat_out_reg);
    end  
    else
    begin   
      if (sCS == 1'b0 && start == 1'b0 && stop == 1'b0)begin  // negedge sSCK
         dat_in_reg <= {dat_in_reg[6:0], 1'b0};
      end
    end  
  end

  always @(posedge sSCK)begin
    if (cs_state == 2 /*sCS == 1'b0*/)begin
       dat_out_reg <= {dat_out_reg[14:0], MOSI};
    end
  end

   
endmodule

