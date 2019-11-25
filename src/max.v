module max
(
  input clk,
  input rst_n,

  input [7:0]indata,
  input cmos_frame_href,
  output reg [7:0] max_data
);

reg [31:0]cnt;
always @(posedge clk or posedge rst_n)
begin
    if(rst_n ==1'b1)
	    cnt <= 32'd0;
	 else if(cnt >= 32'd19_999_999)
	    cnt <= 32'd0;
	 else
	    cnt <= cnt + 1'b1;
end
always @(posedge clk or posedge rst_n) begin
	if (rst_n ==1'b1) begin
	   max_data <= 8'd0;	   		
	end
	else if ((indata > max_data)&(cnt == 32'd25)) 
	begin			 
	        max_data <= indata;
	end
//	else if(((indata < (max_data - 20))&(cmos_frame_href == 1)))
//	begin
//	        max_data <= 8'd0;
//	end
	else begin
	   max_data <= max_data;
	end
end

endmodule 