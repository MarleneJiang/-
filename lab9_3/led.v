module dig8_2(
    input clk,
    input rst,

    input [3:0] num1,
	 input [3:0] num2,

    output reg [1:0] dig, //2个数码管
    output reg [7:0] dict
);

//时钟降频
reg [15:0] cnt1;
always@(posedge clk or negedge rst ) begin
    if(!rst)
        cnt1 <= 16'd0;
    else if (cnt1 <= 16'd50000)
        cnt1 <= cnt1 +1'b1;
    else
        cnt1 <= 16'd0;
end

reg clk_low1;
always@(posedge clk or negedge rst ) begin
    if(!rst)
        clk_low1 <= 1'b0;
    else if (cnt1 <= 16'd24999) begin
        clk_low1 <= 1'b0;
    end
    else
        clk_low1 <= 1'b1;
end


//字典
reg [3:0] data;
always@(posedge clk or negedge rst ) begin
    if(!rst)
        dict <= 8'd0;
    else begin
        case (data)
                4'h0:dict <= 8'b0000_0010;
                4'h1:dict <= 8'b1111_0010;
                4'h2:dict <= 8'b0010_0100;
                4'h3:dict <= 8'b0000_1100;
                4'h4:dict <= 8'b1001_1000;
                4'h5:dict <= 8'b0100_1000;
                4'h6:dict <= 8'b0100_0000;
                4'h7:dict <= 8'b0001_1110;
                4'h8:dict <= 8'b0000_0000;
                4'h9:dict <= 8'b0000_1000;
                4'ha:dict <= 8'b0001_0000;
                4'hb:dict <= 8'b0000_0000;
                4'hc:dict <= 8'b0110_0010;
                4'hd:dict <= 8'b0000_0010;
                4'he:dict <= 8'b0110_0000;
                4'hf:dict <= 8'b0111_0000;
        endcase
    end
end

//轮流切换数码管
reg [2:0]cnt2;
always@(posedge clk_low1 or negedge rst ) begin
    if(!rst)
        cnt2 <= 3'd0;
    else if (cnt2 < 3'd2)
        cnt2 <= cnt2 +1'b1;
    else
        cnt2 <= 3'd0;
end

always@(posedge clk or negedge rst ) begin
    if(!rst)
        dig <= 2'b01;
    else 
    begin
        case (cnt2)
        3'd0:dig <= 2'b01;
        3'd1:dig <= 2'b10;
        endcase
    end
end

//在切换数码管的同时，赋予位选数据
always@(posedge clk or negedge rst ) begin
    if(!rst)
        data <= num1;
    else 
    begin
        case (dig)
        2'b01:data <= num1;
        2'b10:data <= num2;
        endcase
    end
end
endmodule
