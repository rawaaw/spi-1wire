//--------------------------------------------------------------------------------------------
//
//      Input file      : 
//      Component name  : one_wire
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------
`define fclk  24
`define Trstl 480*24
`define Trsth 480*24
`define Tpdih 40*24
`define Tslot 100*24 // 60-120us
`define Tlow1 10*24  // write '1' : 10us (<=15us)
`define Trec  2*24   // recovery time : 2u (>=1us)
`define T1us  1*24


module one_wire(
input           reset,      //cmd reset
input           read_byte,  //cmd write byte
input           write_byte, //cmd read byte
output reg      wire_out,   // 1wire in/out
input           wire_in,
output reg      presense,   //1w defice presense
output reg      busy,
input      [7:0]in_byte,
output reg [7:0]out_byte,
input           clk         //24 MHz
);

  reg              count;
  reg     [13:0]   counter; //0-16383
   


  parameter [2:0]  state_start       = 0,
                   state_delay_reset = 1,
                   state_wire_read_presense = 2,
                   state_wire_0      = 3,
                   state_wire_write  = 4,
                   state_wire_read   = 5,
                   state_delay       = 6,
                   state_rec         = 7;

  reg [2:0]        state = state_start;

  reg [2:0]        n_bit;
  reg              f;

//`define DUMMY
`ifdef DUMMY
  always @(posedge clk)begin
    wire_out <= 1'bZ;
  end
`else
  always @(posedge clk)begin
    case (state)
      state_start: begin
        if (reset == 1'b1)begin
           busy <= 1'b1;
           presense <= 1'b0;
           state <= state_delay_reset;
        end
        else if (write_byte == 1'b1)begin
           f <= 1'b0;
           busy <= 1'b1;
           state <= state_wire_0;
        end
        else if (read_byte == 1'b1)begin
           f <= 1'b1;
           busy <= 1'b1;
           state <= state_wire_0;
        end
        else begin
          wire_out <= 1'bZ;
          busy <= 1'b0;
          count <= 1'b0;
        end
      end
       
      state_delay_reset: begin
        wire_out <= 1'b0;
        count <= 1'b1;
        if (counter == `Trstl) begin  // 480us
           state <= state_wire_read_presense;
           count <= 1'b0;
        end
      end
       
      state_wire_read_presense: begin
        wire_out <= 1'bZ;
        count <= 1'b1;
        if (counter == `Tpdih)       // 40us (for DS18B20 ~29us)
          presense <= (~wire_in);
        if (counter == `Trsth)begin  // 480us
          state <= state_start;
          count <= 1'b0;
        end
      end
       
      state_wire_0: begin
        wire_out <= 1'b0;
        count <= 1'b1;
        if (counter == `Tlow1) begin // 10us (1-15us)
          if (f == 1'b0)
            state <= state_wire_write;
          else
            state <= state_wire_read;
          count <= 1'b0;
        end
      end
       
      state_wire_write: begin
        if (in_byte[n_bit] == 1'b1)
          wire_out <= 1'bZ;
        state <= state_delay;
      end
       
      state_wire_read:begin
        wire_out <= 1'bZ;
        count <= 1'b1;
        if (counter == `T1us) begin
           out_byte[n_bit] <= wire_in;
           count <= 1'b0;
           state <= state_delay;
        end
      end
       
      state_delay:begin
        count <= 1'b1;
        if (counter == (`Tslot - `Tlow1))begin // 100us - 10us
          count <= 1'b0;
          wire_out <= 1'bZ;
          if (n_bit == 7)begin
            n_bit <= 0;
            state <= state_start;
          end
          else begin
            n_bit <= n_bit + 1;
            state <= state_rec;
          end
        end
      end

      state_rec:begin  //recovery time
        count <= 1'b1;
        if (counter == (`Trec))begin // 2us
          count <= 1'b0;
          state <= state_wire_0;
        end
      end

      3'h7: begin
        wire_out <= 1'bZ;
      end

    endcase
  end /*always @(posedge clk) */
`endif
   
   
  always @(posedge clk)begin
    if (count == 1'b0)
      counter <= 0;
    else
      counter <= counter + 1;
  end
   
endmodule
