module CODE
    (
      input wire a,b,c,d,           //四位开关作为密码输入
      input wire k,				  //一位按键作为开锁使能信号
      output reg led1,    	      //保险箱打开信号对应的led输出
      output reg led2			  //报警信号对应的led输出
    );
   always@(k or a or b or c or d)
	if(k == 1'b0)
		begin
			if((a==1'b1)&(b==1'b1)&(c==1'b1)&(d==1'b1)) begin
				led1 = 1'b0;
				led2 = 1'b1;
			end
			else begin
				led1 = 1'b1;
				led2 = 1'b0;
			end
		end
	else begin
		led1 = 1'b1;
		led2 = 1'b1;
	end
endmodule
  


