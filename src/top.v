`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:44 11/24/2019 
// Design Name: 
// Module Name:    聂文哲、赵言 
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

module top(
	input                       clk,    
	input                       rst_n,
                output[5:0]seg_sel,
                output[7:0]seg_data,	

	input                       cmos_vsync,        //cmos vsync                   
	input                       cmos_href,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock              
	output                      cmos_xclk,         //cmos externl clock            
	input   [7:0]               cmos_db,           //cmos data                     

	
	output                      vga_out_hs,        //vga horizontal synchronization
	output                      vga_out_vs,        //vga vertical synchronization
	output[4:0]                 vga_out_r,         //vga red
	output[5:0]                 vga_out_g,         //vga green
	output[4:0]                 vga_out_b,         //vga blue
	
	output				cmos_ctl0,		//Unused
	output				cmos_ctl1,		//Sensor exposure
	output				cmos_ctl2,		//Sensor Standby
	
	output                      sdram_clk,         //sdram clock               
	output                      sdram_cke,         //sdram clock enable        
	output                      sdram_cs_n,        //sdram chip select         
	output                      sdram_we_n,        //sdram write enable        
	output                      sdram_cas_n,       //sdram column address 
	output                      sdram_ras_n,       //sdram row address strobe   
	output[1:0]                 sdram_dqm,         //sdram data enable
	output[1:0]                 sdram_ba,          //sdram bank address
	output[12:0]                sdram_addr,        //sdram address
	inout[15:0]                 sdram_dq           //sdram data                 
);
assign	cmos_ctl0 = 1'bz;
assign	cmos_ctl1 = 1'b0;	//Sensor exposure
assign	cmos_ctl2 = 1'b0;   //Sensor Standby
parameter MEM_DATA_BITS         = 16;             //external memory user interface data width   
parameter ADDR_BITS             = 24;             //external memory user interface address 
parameter BUSRT_BITS            = 10;             //external memory user interface burst width  

wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[15:0]                      read_data;
wire                            write_en;
wire[15:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;
wire                            ext_mem_clk;       //external memory clock 
wire                            video_clk;         //video pixel clock     
wire                            hs;
wire                            vs;
wire                            de;
wire[4:0]                       data_r;
wire[5:0]                       data_g;
wire[4:0]                       data_b;
wire[7:0]                       ycbcr_y;
wire[15:0]                      vout_data;
wire[15:0]                      cmos_16bit_data;
wire                            cmos_16bit_wr;
wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;
wire                            clk_bufg;
wire                            mem_ref_clk;
wire                            clk_cmos;
wire                            ycbcr_hs;
wire                            ycbcr_vs;
wire                            ycbcr_de;

assign vga_out_hs =hs;//;ycbcr_hs
assign vga_out_vs =vs ;//;ycbcr_hs
assign vga_out_r  = vout_data[4:0];//;data_r
assign vga_out_g  = vout_data[10:5];//;data_g
assign vga_out_b  = vout_data[15:11];//;data_b
assign sdram_clk  = ext_mem_clk;
assign cmos_rst_n = 1'b1;
assign cmos_pwdn  = 1'b0;

assign write_en   = cmos_frame_href ;//cmos_16bit_wr
assign write_data = {data_r,data_g,data_b}; //data_r,data_g,data_bcmos_frame_Gray[7:3],cmos_frame_Gray[7:2],cmos_frame_Gray[7:3]

IBUFG IBUFG_INST
(    .O(clk_bufg),
     .I(clk    )      
);


//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0
(
	.sys_clk_in                     (clk_bufg                 ),
	.sys_clk_out1                   (clk_cmos                 ),   //24M 
	.sys_clk_out2                   (ext_mem_clk              ),   //
	.sys_clk_out3                   (mem_ref_clk              ),	//
	.reset                          (~rst_n                   ),
	.locked                         (                         )
);
assign	cmos_xclk = clk_cmos;
//
//generate video pixel clock
video_pll video_pll_m0
(
	.video_clk_in                   (clk_bufg                 ),
	.video_clkout                   (video_clk                ),  //65M 用于像素的输出时钟
	.reset                          (~rst_n                   ),
	.locked                         (                         )
);


//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0
(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	
	.cmos_vsync                 (~cmos_vsync              ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);

wire			cmos_frame_vsync;	//cmos frame data vsync valid signal
wire			cmos_frame_href;	//cmos frame data href vaild  signal
wire	[7:0]	cmos_frame_Gray;		//cmos frame data output: 8 Bit raw data	
wire			cmos_frame_clken;	//cmos frame data output/capture enable clock
wire	[7:0]	cmos_fps_rate;		//cmos image output rate
CMOS_Capture_RAW_Gray	
#(
	.CMOS_FRAME_WAITCNT		(4'd10)				//Wait n fps for steady(OmniVision need 10 Frame)
)
u_CMOS_Capture_RAW_Gray
(
	//global clock
	.clk_cmos				(clk_cmos),			//24MHz CMOS Driver clock input
	.rst_n					(rst_n),	//global reset & cmos_init_done

	//CMOS Sensor Interface
	.cmos_pclk				(cmos_pclk),  		//24MHz CMOS Pixel clock 
	.cmos_xclk				(cmos_xclk),		//24MHz drive clock   
	.cmos_data				(cmos_db),		//8 bits cmos data input    
	.cmos_vsync				(cmos_vsync),		//L: vaild, H: invalid   
	.cmos_href				(cmos_href),		//H: vaild, L: invalid   
	
	//CMOS SYNC Data output
	.cmos_frame_vsync		(cmos_frame_vsync),	//cmos frame data vsync valid signal   
	.cmos_frame_href		(cmos_frame_href),	//cmos frame data href vaild  signal   
	
	.cmos_frame_data		(cmos_frame_Gray),	//cmos frame data output: 8 Bit raw data	
	.cmos_frame_clken		(cmos_frame_clken),	//cmos frame data output/capture enable clock   
	
	//user interface
	.cmos_fps_rate			(cmos_fps_rate)		//cmos image output rate  
);

//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ), //
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                         ),
	.vout_data                  (vout_data                )
);

wire [7:0] max_data;

max data_max (
    .clk(clk_cmos), 
    .rst_n(~rst_n), 
    .indata(cmos_frame_Gray), 
	 
	 .cmos_frame_href(cmos_frame_href),
    .max_data(max_data)
    );


rgb_to_M rgb_to_M_m0(
	.clk                        (clk_cmos                ),
	.rst	                      (~rst_n                   ),
	.cmos_frame_Gray            (cmos_frame_Gray          ),

	.data_r                     (data_r                   ),
	.data_g                     (data_g                   ),
	.data_b                     (data_b                   )

);
//视频帧数据读写控制FIFO读写
//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (mem_ref_clk              ),
	
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),   //
	.rd_burst_data              (rd_burst_data            ),  //
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	.read_addr_index            (read_addr_index          ),
	.read_len                   (24'd786432               ), //frame size
	.read_en                    (read_en                  ),  //
	.read_data                  (read_data                ),  //

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),   //
	.wr_burst_finish            (wr_burst_finish          ),
	
	.write_clk                  (cmos_pclk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	.write_addr_index           (write_addr_index         ),
	.write_len                  (24'd786432               ), //frame size
	
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )   //
);

//
//sdram controller
sdram_core sdram_core_m0
(
	.rst                        (~rst_n                   ),
	.clk                        (mem_ref_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ), //
	.rd_burst_data              (rd_burst_data            ),  //
	.rd_burst_finish            (rd_burst_finish          ),
	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ), //
	.wr_burst_data              (wr_burst_data            ), //
	.wr_burst_finish            (wr_burst_finish          ),
	.sdram_cke                  (sdram_cke                ),
	.sdram_cs_n                 (sdram_cs_n               ),
	.sdram_ras_n                (sdram_ras_n              ),
	.sdram_cas_n                (sdram_cas_n              ),
	.sdram_we_n                 (sdram_we_n               ),
	.sdram_dqm                  (sdram_dqm                ),
	.sdram_ba                   (sdram_ba                 ),
	.sdram_addr                 (sdram_addr               ),
	.sdram_dq                   (sdram_dq                 )   //
);
//wire[35:0] CONTROL0;
//wire[255:0] TRIG0; 
//chipscope_icon icon_debug (
//    .CONTROL0(CONTROL0)
//    );
//chipscope_ila ila_filter_debug (
//    .CONTROL(CONTROL0), 
//    .CLK(clk_cmos), 
//    .TRIG0(TRIG0)
//    );
//
//assign TRIG0[7:0] = cmos_frame_Gray;
//
//assign TRIG0[15:8] = max_data;
//assign TRIG0[24:24] = write_en;
//assign TRIG0[40:25] = wr_burst_data;
//
//assign TRIG0[56:41] = rd_burst_data;
//assign TRIG0[57:57] = read_en;
//assign TRIG0[73:58] = read_data;
//
//assign TRIG0[74:74] = wr_burst_data_req;
//assign TRIG0[90:75] = vout_data;
//assign TRIG0[91:91] = rd_burst_data_valid;
endmodule
