`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:44 11/24/2019 
// Design Name: 
// Module Name:    �����ܡ����� 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module cmos_write_req_gen(
	input              rst,
	input              pclk,
	input              cmos_vsync,
	output reg         write_req,
	output reg[1:0]    write_addr_index,
	output reg[1:0]    read_addr_index,
	input              write_req_ack
);
reg cmos_vsync_d0;
reg cmos_vsync_d1;
reg cmos_vsync_d2;
reg cmos_vsync_d3;
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		cmos_vsync_d0 <= 1'b0;
		cmos_vsync_d1 <= 1'b0;
		cmos_vsync_d2 <= 1'b0;
		cmos_vsync_d3 <= 1'b0;		
	end
	else
	begin
		cmos_vsync_d0 <= cmos_vsync;
		cmos_vsync_d1 <= cmos_vsync_d0;
		cmos_vsync_d2 <= cmos_vsync_d1;
		cmos_vsync_d3 <= cmos_vsync_d2;
	end
end
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		write_req <= 1'b0;
	else if(cmos_vsync_d2 == 1'b1 && cmos_vsync_d3 == 1'b0)
		write_req <= 1'b1;
	else if(write_req_ack == 1'b1)
		write_req <= 1'b0;
end
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		write_addr_index <= 2'b0;
	else if(cmos_vsync_d2 == 1'b1 && cmos_vsync_d3 == 1'b0)
		write_addr_index <= write_addr_index + 2'd1;
end

always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		read_addr_index <= 2'b0;
	else if(cmos_vsync_d2 == 1'b1 && cmos_vsync_d3 == 1'b0)
		read_addr_index <= write_addr_index;
end
endmodule 