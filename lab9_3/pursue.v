module pursue(
    input clk,
    input rst,
    input c,  //双方都有一个输入按钮信号c、p，c是被追方的控制按钮，改变被追方的运动
    input p,
    output reg [15:0] pursue_led,
	 output reg [7:0] cutdown_led, //最开始，8个倒计时流水灯，从两边向中间逐级熄灭，代表倒计时。当所有灯熄灭，游戏开始
	 output reg [3:0] num1,  //比赛结果小比分的成绩，最高为3，最初为0
    output reg [3:0] num2   //比赛结果大比分的成绩，每当小比分满3时，大比分加1，小比分归0，最高为3
);

//时钟降频4Hz
reg [25:0] cnt1;
always@(posedge clk or negedge rst ) begin
    if(!rst)
        cnt1 <= 16'd0;
    else if (cnt1 <= 26'd12500000)
        cnt1 <= cnt1 +1'b1;
    else
        cnt1 <= 16'd0;
end

reg clk_low1;
always@(posedge clk or negedge rst ) begin
    if(!rst)
        clk_low1 <= 1'b0;
    else if (cnt1 <= 26'd06249999) begin
        clk_low1 <= 1'b0;
    end
    else
        clk_low1 <= 1'b1;
end



//时钟降频1Hz
reg [25:0] cnt2;
always@(posedge clk or negedge rst ) begin
    if(!rst)
        cnt2 <= 16'd0;
    else if (cnt2 <= 26'd50000000)
        cnt2 <= cnt2 +1'b1;
    else
        cnt2 <= 16'd0;
end

reg clk_low2;
always@(posedge clk or negedge rst ) begin
    if(!rst)
        clk_low2 <= 1'b0;
    else if (cnt2 <= 26'd24999999) begin
        clk_low2 <= 1'b0;
    end
    else
        clk_low2 <= 1'b1;
end


//倒计时灯向左移
function [3:0] moveL;
  input [3:0]cur;
  begin
		if (cur==4'b1000)
			 moveL = 4'b0000;
		else
			 moveL = cur<<1;
  end
endfunction

//倒计时灯向右移
function [3:0] moveR;
  input [3:0]cur;
  begin
		if (cur==4'b0001)
			 moveR = 4'b0000;
		else
			 moveR = cur>>1;
  end
endfunction

reg isStart = 1'b0;
//降频后的CLK即clk_low2，触发后续操作
always@(posedge clk_low2 or negedge rst ) begin
    if(!rst) begin
        cutdown_led <= 8'hFF;
		  isStart <= 1'b0;
	 end
    else if (cutdown_led > 8'h00)begin
        cutdown_led <= {moveR(cutdown_led[7:4]),moveL(cutdown_led[3:0])};
    end
    else begin
        cutdown_led = 8'h00;
		  isStart = 1'b1;
//		  pursue_led <= 16'h8000 + 16'h0080;
    end
end

reg isStop1 = 1'b0;
reg isStop2 = 1'b0;
//顺时针跑
function [15:0] pursueL;
  input [15:0]cur;
  input [1:0]pursue;
  begin
		if (cur==16'h8000)
			 pursueL = 16'h0001;
		else begin
			 if (cur == 16'h0800 && pursue == 2'b00 && isStop1 == 1'b0) begin
			     pursueL = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0200 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueL = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0040 && pursue == 2'b00 && isStop1 == 1'b0) begin
			     pursueL = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h4000 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueL = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0002 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueL = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h2000 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueL = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h1000 && pursue == 2'b00 && isStop1 == 1'b0) begin
			     pursueL = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else begin
			     pursueL = cur<<1;
				  if(pursue == 2'b00)
				    isStop1 = 1'b0;
				  if(pursue == 2'b11)
		          isStop2 = 1'b0;
			 end
	   end
  end
endfunction

//逆时针跑
function [15:0] pursueR;
  input [15:0]cur;
  input [1:0]pursue;
  begin
		if (cur==16'h0001)
			 pursueR = 16'h8000;
		else begin
			 if (cur == 16'h0100 && pursue == 2'b00 && isStop1 == 1'b0) begin
			     pursueR = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0200 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueR = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0040 && pursue == 2'b00 && isStop1 == 1'b0) begin
			     pursueR = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h4000 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueR = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0010 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueR = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0020 && pursue == 2'b11 && isStop2 == 1'b0) begin
			     pursueR = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else if (cur == 16'h0200 && pursue == 2'b00 && isStop1 == 1'b0) begin
			     pursueR = cur;
				  isStop1 = 1'b1;
				  isStop2 = 1'b1;
			 end
			 else begin
			     pursueR = cur>>1;
				  if(pursue == 2'b00)
				    isStop1 = 1'b0;
				  if(pursue == 2'b11)
		          isStop2 = 1'b0;
			 end
	   end
  end
endfunction


reg [15:0] pursue1;
reg [15:0] pursue2;
//降频后的CLK即clk_low1，触发后续操作
always@(posedge clk_low1 or negedge rst ) begin
    if(!rst) begin
        pursue1 <= 16'h8000;
		  pursue2 <= 16'h0080;
		  isStop1 <= 1'b0;
		  isStop2 <= 1'b0;
		  num1 <= 4'd0;
        num2 <= 4'd0;
		  pursue_led <= 16'h8000 + 16'h0080;
//		  isStart <= 1'b0;
	 end
//	 else if (isStart == 1'b0) begin 
//	     pursue_led = 16'hFFFF;
//	 end
    else if (pursue1 != pursue2 && isStart == 1'b1)begin
		  if(c == 1)
           pursue1 = pursueR(pursue1,2'b00);
		  else
		     pursue1 = pursueL(pursue1,2'b00);
			  
		  if(p == 1)
           pursue2 = pursueR(pursue2,2'b11);
		  else
		     pursue2 = pursueL(pursue2,2'b11);
			  
		  if (pursue1 == pursue2)
		    pursue_led = 16'hFFFF;
		  else
		    pursue_led = pursue1 + pursue2;
		  
    end
    else if (pursue1 == pursue2)begin
        pursue1 <= 16'h8000;
		  pursue2 <= 16'h0080;
		  pursue_led <= 16'hFFFF;
		  if (num1 < 4'd3)
			  num1 <= num1 +1'b1;
		  else if (num2 == 4'd3) begin
			  num1 <= 4'd0;
			  num2 <= 4'd0;
		  end
		  else begin
           num1 <= 4'd0;
		     num2 <= num2 +1'b1;
        end
    end
end
endmodule