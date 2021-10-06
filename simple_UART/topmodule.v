`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2020 11:13:48 PM
// Design Name: 
// Module Name: topmodule
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


module topmodule(
	  input  wire clk, reset,        // clock reset input lines
	  input  wire rx,		 // receive
	  output wire tx ,
	  output Rx_Data // transmit
	);
	
	reg  [7:0] r_reg;                       // baud rate generator register
	wire [7:0] r_next;                      // baud rate generator next state logic
	wire tick;                              // baud tick for uart_rx & uart_tx
	wire [7:0] rx_data_out;                 // routing path for received ascii data 
	wire rx_done_tick, tx_done_tick;        // done ticks for rx and tx circuits
	reg [7:0] tx_d_next, tx_d_reg;           // register for tx output to PC
	reg tx_start; 
	        

	// tx_d register for tx data to PC
	always @(posedge reset, posedge clk)
		if(reset)
			tx_d_reg <= 8'b00000000;
		else 
			tx_d_reg <=  rx_data_out;
	// register for oversampling baud rate generator
	always @(posedge clk, posedge reset)
		if(reset)
			r_reg <= 0;
		else
			r_reg <= r_next;
	
	// next state logic, mod 163 counter
	assign r_next = r_reg == 163 ? 0 : r_reg + 1;
	
	// tick high once every 163 clock cycles, for 19200 baud
	assign tick = r_reg == 163 ? 1 : 0;
	always @(*)
	begin 
	 tx_start<=1'b1;
	end
	
	// instantiate uart rx ciruit
	uart_rx uart_rx_unit (.clk(clk), .reset(reset), .rx(rx), .baud_tick(tick), .rx_done_tick(rx_done_tick), .rx_data(rx_data_out));
	
	// instantiate uart tx circuit
	uart_tx uart_tx_unit (.clk(clk), .reset(reset), .tx_start(tx_start), .baud_tick(tick), .tx_data(tx_d_reg), .tx_done_tick(tx_done_tick), .tx(tx));
	assign Rx_Data= rx_data_out;
	
endmodule 