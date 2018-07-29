//--------------------------------------------------------------------------------------------
//
//      Input file      : 
//      Component name  : single_wire DHT11
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------
`define fclk  24

`define Tlow1  20000*24  // write '0' : 20ms (>=18ms)
`define Thigh1 50*24  // write 'Z' : 40us (20-40us)
`define Tlow2  100*24 // wait high from DHT11 100us (80us)
`define Thigh2 100*24 // wait low from DHT11 100us (80us)
`define Tstarttr 60*24 // start to transmit (50us)
`define Tonemax 80*24  // ONE  70us
`define Tzeromax 30*24 // ZERO 26-28us



module single_wire(
input           read_wire,  // start read single wire device
output reg      wire_out,   // single_wire in/out
input           wire_in,
output reg      busy,
output reg [39:0]out_data,
input           clk         //24 MHz
//,output reg      state
);

  reg              count;
  reg     [19:0]   counter; //0-7FFFF (524287)
  reg     [5:0]    n_bit;

  parameter [2:0]  state_start          = 0,
                   state_wire_0         = 1,
                   state_wire_1         = 2,
                   state_wire_wait_high = 3,
                   state_wire_wait_tr   = 4,
                   state_wire_start_tr  = 5,
                   state_wire_read      = 6,
                   state_next_cycle     = 7; 

  reg [2:0]        state = state_start;

  always @(posedge clk)begin
    case (state)
      state_start: begin
        if (read_wire == 1'b1)begin
          wire_out <= 1'bZ;
          busy <= 1'b1;
          state <= state_wire_0;
          n_bit <= 39;
          //out_data <= 0;
        end
        else begin
          wire_out <= 1'bZ;
          busy <= 1'b0;
          count <= 1'b0;
        end
      end

      state_wire_0: begin
        wire_out <= 1'b0;
        count <= 1'b1;
        if (counter == `Tlow1) begin // 20us (>= 18us)
          wire_out <= 1'bZ;
          count <= 1'b0;
          state <= state_wire_1;
        end
      end

      state_wire_1: begin            // wait for DHT11 set 0 on bus
        wire_out <= 1'bZ;
        count <= 1'b1;
        if (wire_in == 0) begin
          state <= state_wire_wait_high;
          count <= 1'b0;
        end 
        else if (counter == `Thigh1) begin // DHT11 not answered for 50us
          state <= state_start;
          count <= 1'b0;
        end
      end

      state_wire_wait_high: begin
        wire_out <= 1'bZ;
        count <= 1'b1;
        if (wire_in == 1) begin
          state <= state_wire_wait_tr;
          count <= 1'b0;
        end 
        else if (counter == `Tlow2) begin // DHT11 not answered for 50us
          state <= state_start;
          count <= 1'b0;
        end
      end

      state_wire_wait_tr:begin
        wire_out <= 1'bZ;
        count <= 1'b1;
        if (wire_in == 0) begin
          state <= state_wire_start_tr;
          count <= 1'b0;
        end 
        else if (counter == `Thigh2) begin // DHT11 not answered for 100us
          count <= 1'b0;
          state <= state_start;
        end
      end
       
      state_wire_start_tr:begin
        wire_out <= 1'bZ;
        count <= 1'b1;
        if (count == `Tstarttr) begin  // if start transmit state >= 60us we assume error state on wite
          count <= 1'b0;
          state <= state_start;
        end 
        else if (wire_in == 1) begin
          count <= 1'b0;
          state <= state_wire_read;
        end
      end

      state_wire_read: begin
        count <= 1'b1;
        if (counter == `Tonemax) begin // DHT not answered for 80us
          count <= 1'b0;
          state <= state_start;
        end 
        else if (wire_in == 0) begin
          count <= 1'b0;
          out_data[n_bit] <= (counter > `Tzeromax)? 1:0;
          state <= state_next_cycle;
        end
      end

      state_next_cycle: begin
        n_bit <= n_bit - 1;
        if (n_bit == 0) begin
          n_bit <= 39;
          state <= state_start;
        end
        else begin
          state <= state_wire_start_tr;
        end
      end

    endcase
  end // always 

  always @(posedge clk)begin
    if (count == 1'b0)
      counter <= 0;
    else
      counter <= counter + 1;
  end
   
endmodule
