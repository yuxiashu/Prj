`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:44 11/24/2019 
// Design Name: 
// Module Name:    ƒÙŒƒ’‹°¢’‘—‘ 
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

`timescale 1ns/1ps
module  rgb_to_M(
	input                       clk,
	input                       rst,		
	input[7:0]                  cmos_frame_Gray,

	output reg[4:0]                 data_r,
	output reg[5:0]                 data_g,  //ycbcr_cb
	output reg[4:0]                 data_b //ycbcr_cr
);


//reg [4:0]data_r;
//reg [5:0]data_g;
//reg [4:0]data_b;
always@(posedge clk or posedge rst)
begin
  if(rst == 1'b1)
    begin
	   data_r <= 0;
		data_b <= 0;
		data_g <= 0;
	 end
  else if(cmos_frame_Gray < 64 && cmos_frame_Gray >= 0)
    begin
	   data_r <= 0;
		data_b <= 254 -{cmos_frame_Gray<<2};//4*data 
		data_g <= 255;
	 end
  else if(cmos_frame_Gray >= 64 && cmos_frame_Gray < 128)
    begin
	   data_r <= 0;
		data_b <= {cmos_frame_Gray<<2} - 254;//255;
		data_g <= 510 - {cmos_frame_Gray<<2};
	 end
  else if(cmos_frame_Gray >= 128 && cmos_frame_Gray < 192 )
    begin
	   data_r <= {cmos_frame_Gray<<2} - 510;
		data_b <= 255;
		data_g <= 0;
	 end
  else if(cmos_frame_Gray >= 193 && cmos_frame_Gray <= 255)
    begin
	   data_r <= 255;
		data_b <= 1022 - {cmos_frame_Gray<<2}; //1024
		data_g <= 0;
	 end
  else begin
      data_r <= data_r;
		data_b <= data_b;
		data_g <= data_g;
		 end
end


endmodule
