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
`include "video_define.v"
module color_bar(
	input                 clk,           //pixel clock
	input                 rst,           //reset signal high active
	output                hs,            //horizontal synchronization
	output                vs,            //vertical synchronization
	output                de,            //video valid
   output                de1,            //video valid
	output[7:0]           rgb_r,         //video red data
	output[7:0]           rgb_g,         //video green data
	output[7:0]           rgb_b          //video blue data
);
//video timing parameter definition

//1024x768 65Mhz
`ifdef  VIDEO_1024_768
parameter H_ACTIVE = 16'd1024;
parameter H_FP = 16'd24;      
parameter H_SYNC = 16'd136;   
parameter H_BP = 16'd160;     
parameter V_ACTIVE = 16'd768; 
parameter V_FP  = 16'd3;      
parameter V_SYNC  = 16'd6;    
parameter V_BP  = 16'd29;     
parameter HS_POL = 1'b0;
parameter VS_POL = 1'b0;
`endif

parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)
//define the RGB values for 8 colors
parameter WHITE_R       = 8'hff;
parameter WHITE_G       = 8'hff;
parameter WHITE_B       = 8'hff;
parameter YELLOW_R      = 8'hff;
parameter YELLOW_G      = 8'hff;
parameter YELLOW_B      = 8'h00;                                
parameter CYAN_R        = 8'h00;
parameter CYAN_G        = 8'hff;
parameter CYAN_B        = 8'hff;                                
parameter GREEN_R       = 8'h00;
parameter GREEN_G       = 8'hff;
parameter GREEN_B       = 8'h00;
parameter MAGENTA_R     = 8'hff;
parameter MAGENTA_G     = 8'h00;
parameter MAGENTA_B     = 8'hff;
parameter RED_R         = 8'hff;
parameter RED_G         = 8'h00;
parameter RED_B         = 8'h00;
parameter BLUE_R        = 8'h00;
parameter BLUE_G        = 8'h00;
parameter BLUE_B        = 8'hff;
parameter BLACK_R       = 8'h00;
parameter BLACK_G       = 8'h00;
parameter BLACK_B       = 8'h00;
reg hs_reg;                      //horizontal sync register
reg vs_reg;                      //vertical sync register
reg hs_reg_d0;                   //delay 1 clock of 'hs_reg'
reg vs_reg_d0;                   //delay 1 clock of 'vs_reg'
reg[11:0] h_cnt;                 //horizontal counter
reg[11:0] v_cnt;                 //vertical counter
reg[11:0] active_x;              //video x position 
reg[11:0] active_y;              //video y position 
reg[7:0] rgb_r_reg;              //video red data register
reg[7:0] rgb_g_reg;              //video green data register
reg[7:0] rgb_b_reg;              //video blue data register

reg h_active;                    //horizontal video active
reg v_active;                    //vertical video active
wire video_active;               //video active(horizontal active and vertical active)
reg video_active_d0;             //delay 1 clock of video_active
///////////////////////////////////////////////////////////
reg h0_active;                    //horizontal video active
reg v0_active;                    //vertical video active
wire video0_active;               //video active(horizontal active and vertical active)
reg video0_active_d0;             //delay 1 clock of video_active
////////////////////////////////////////////////////////

assign hs = hs_reg_d0;
assign vs = vs_reg_d0;
assign de = video_active_d0;
assign de1 = video0_active_d0;

assign video_active = h_active & v_active;
///////////////////////////////////////////
assign video0_active = h0_active | v0_active;
///////////////////////////////////////////

assign rgb_r = rgb_r_reg;
assign rgb_g = rgb_g_reg;
assign rgb_b = rgb_b_reg;

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		begin
			hs_reg_d0 <= 1'b0;
			vs_reg_d0 <= 1'b0;
			video_active_d0 <= 1'b0;
			video0_active_d0 <= 1'b0;
		end
	else
		begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
			video0_active_d0 <= video0_active;
		end
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 1)//horizontal counter maximum value
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		active_x <= 12'd0;
	else if(h_cnt >= H_FP + H_SYNC + H_BP - 1)//horizontal video active
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		active_x <= active_x;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_cnt <= 12'd0;
	else if(h_cnt == H_FP  - 1)//horizontal sync time H_FP + H_SYNC + H_BP + 751 >= 
		if(v_cnt == V_TOTAL - 1)//vertical counter maximum value
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		hs_reg <= 1'b0;
	else if(h_cnt == H_FP - 1)//horizontal sync begin
		hs_reg <= HS_POL;
	else if(h_cnt == H_FP + H_SYNC - 1)//horizontal sync end - 288
		hs_reg <= ~hs_reg;
	else
		hs_reg <= hs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1 + 136)//horizontal active begin         -272
		h_active <= 1'b1;
	else if(h_cnt == H_TOTAL - 1 - 136)//horizontal active end272
		h_active <= 1'b0;
	else
		h_active <= h_active;
end

/////////////////////���ο�/////////////////////
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h0_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1 + 472)//horizontal active begin 
      h0_active <= 1'b1;	
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1 + 473)//horizontal active begin 
      h0_active <= 1'b0;
		
	else if(h_cnt == H_TOTAL - 1 - 473)//horizontal active end272
		h0_active <= 1'b1;		
	else if(h_cnt == H_TOTAL - 1 - 472)//horizontal active end272
		h0_active <= 1'b0;
	else
		h0_active <= h0_active;
end
/////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))//vertical sync begin
		vs_reg <= HS_POL;
	else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))//vertical sync end
		vs_reg <= ~vs_reg;  
	else
		vs_reg <= vs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1 + 144) && (h_cnt == H_FP - 1))//vertical active begin
		v_active <= 1'b1;
	else if((v_cnt == V_TOTAL - 1 - 144) && (h_cnt == H_FP - 1)) //vertical active end    -288
		v_active <= 1'b0;   
	else
		v_active <= v_active;
end
//////////////////���ο�//////////////////
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v0_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1 + 344) && (h_cnt == H_FP - 1))//vertical active begin
		v0_active <= 1'b1;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1 + 345) && (h_cnt == H_FP - 1))//vertical active begin
		v0_active <= 1'b0;
		
	else if((v_cnt == V_TOTAL - 1 - 345) && (h_cnt == H_FP - 1)) //vertical active end    -288
		v0_active <= 1'b1;  
   else if((v_cnt == V_TOTAL - 1 - 344) && (h_cnt == H_FP - 1)) //vertical active end    -288
		v0_active <= 1'b0;  		
	else
		v0_active <= v0_active;
end
/////////////////////////////////////
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
	else if(video_active)
		if(active_x == 12'd0)
			begin
				rgb_r_reg <= WHITE_R;
				rgb_g_reg <= WHITE_G;
				rgb_b_reg <= WHITE_B;
			end
		else if(active_x == (H_ACTIVE/8) * 1)
			begin
				rgb_r_reg <= YELLOW_R;
				rgb_g_reg <= YELLOW_G;
				rgb_b_reg <= YELLOW_B;
			end         
		else if(active_x == (H_ACTIVE/8) * 2)
			begin
				rgb_r_reg <= CYAN_R;
				rgb_g_reg <= CYAN_G;
				rgb_b_reg <= CYAN_B;
			end
		else if(active_x == (H_ACTIVE/8) * 3)
			begin
				rgb_r_reg <= GREEN_R;
				rgb_g_reg <= GREEN_G;
				rgb_b_reg <= GREEN_B;
			end
		else if(active_x == (H_ACTIVE/8) * 4)
			begin
				rgb_r_reg <= MAGENTA_R;
				rgb_g_reg <= MAGENTA_G;
				rgb_b_reg <= MAGENTA_B;
			end
		else if(active_x == (H_ACTIVE/8) * 5)
			begin
				rgb_r_reg <= RED_R;
				rgb_g_reg <= RED_G;
				rgb_b_reg <= RED_B;
			end
		else if(active_x == (H_ACTIVE/8) * 6)
			begin
				rgb_r_reg <= BLUE_R;
				rgb_g_reg <= BLUE_G;
				rgb_b_reg <= BLUE_B;
			end 
		else if(active_x == (H_ACTIVE/8) * 7)
			begin
				rgb_r_reg <= BLACK_R;
				rgb_g_reg <= BLACK_G;
				rgb_b_reg <= BLACK_B;
			end
		else
			begin
				rgb_r_reg <= rgb_r_reg;
				rgb_g_reg <= rgb_g_reg;
				rgb_b_reg <= rgb_b_reg;
			end         
	else
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
end

endmodule 