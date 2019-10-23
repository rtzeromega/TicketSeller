module metro(clk,sw,rst,btn,ds,seg,row,rcol,gcol); //1khz 
input clk;
input sw;
input rst;
input [7:0] btn;
wire [7:0] tbtn;
reg [3:0] count0=0;//张数
reg [3:0] count1=0;//站数 个位
reg [3:0] count2=0;//站数 十位
reg [7:0] count3=0;//钱数 一元
reg [7:0] count4=0;//钱数 五元
reg [7:0] count5=0;//钱数 十元
reg [7:0] fee;//费用
reg [7:0] pay;//支付
reg [7:0] change;
reg [3:0] pay1;
reg [3:0] pay10;
reg [3:0] pay100;
reg [2:0] std;//状态
reg [7:6] key;//状态信号
reg [11:0] four;
reg zero=0;

debounce u1 (.clk(clk),.key(btn[0]),.key_pulse(tbtn[0]));//消抖
debounce u2 (.clk(clk),.key(btn[1]),.key_pulse(tbtn[1]));
debounce u3 (.clk(clk),.key(btn[2]),.key_pulse(tbtn[2]));
debounce u4 (.clk(clk),.key(btn[3]),.key_pulse(tbtn[3]));
debounce u5 (.clk(clk),.key(btn[4]),.key_pulse(tbtn[4]));
debounce u6 (.clk(clk),.key(btn[5]),.key_pulse(tbtn[5]));
debounce u7 (.clk(clk),.key(btn[6]),.key_pulse(tbtn[6]));//确认
debounce u8 (.clk(clk),.key(btn[7]),.key_pulse(tbtn[7]));//取零

always @(	posedge clk or
			posedge tbtn[0] or
			posedge tbtn[1] or
			posedge tbtn[2] or
			posedge tbtn[3] or
			posedge tbtn[4] or
			posedge tbtn[5] or
			posedge tbtn[6] or
			posedge tbtn[7])
begin 
	if(tbtn[0]||tbtn[1]||tbtn[2]||tbtn[3]||tbtn[4]||tbtn[5]||tbtn[6]||tbtn[7])
	begin
		four<=0;
	end
	else
		four<=four+1;//延时自动跳转计时
end

always @(four or sw or std)//zero重置信号
begin
	if(sw)
	begin
		if(rst) zero<=1;//重置键
		else if(four==12'b1111111111111) zero<=1;//自动跳转重置
		//else if(std==3'b101) zero<=1;
		else zero<=0;
	end
	else zero<=1;//关机时重置
end

always @(posedge tbtn[0] or posedge zero)//按键计数 张数
begin
	if(zero)//置零信号
	begin
		count0<=0;
	end
	else
	begin
		if(count0<4'b1001)
			count0<=count0+1;
		else
			count0<=0;
	end
end

always @(posedge tbtn[1] or posedge zero)//站数 个位
begin
	if(zero)
	begin
		count1<=0;
	end
	else
	begin
		if(count1<4'b1001)
			count1<=count1+1;
		else
			count1<=0;
	end
end

always @(posedge tbtn[2] or posedge zero)//站数 十位
begin
	if(zero)
	begin
		count2<=0;
	end
	else
	begin
		if(count2<4'b1001)
			count2<=count2+1;
		else
			count2<=0;
	end
end

always @(posedge tbtn[3] or posedge zero)//钱数 一元
begin
	if(zero)
	begin
		count3<=0;
	end
	else
	begin
		if(count3<8'b11111111)
			count3<=count3+1;
		else
			count3<=0;
	end
end

always @(posedge tbtn[4] or posedge zero)//钱数 五元
begin
	if(zero)
	begin
		count4<=0;
	end
	else
	begin
		if(count4<8'b11111111)
			count4<=count4+8'b00000101;
		else
			count4<=0;
	end
end

always @(posedge tbtn[5] or posedge zero)//钱数 十元
begin
	if(zero)
	begin
		count5<=0;
	end
	else
	begin
		if(count5<8'b11111111)
			count5<=count5+8'b00001010;
		else
			count5<=0;
	end
end

always @(posedge tbtn[6] or posedge zero)//确认
begin
	if(zero)
		key[6]<=0;
	else
	begin
		key[6]<=1;
	end
end

always @(posedge tbtn[7] or posedge zero)//取零
begin
	if(zero)
		key[7]<=0;
	else
	begin
		key[7]<=1;
	end
end

//状态 000错误 001待机 010输入 100找零 111出票 101自检
always @(sw or zero or key)
begin
pay<=count5+count4+count3;
pay1<=pay%10;
pay10<=(pay/10)%10;
pay100<=pay/100;
if(sw)
	begin
		if(test>0)
			std<=3'b101;
		else//自检完成
		begin
			if(key[6])
			begin
				if(key[7])//有BTN7状态信号
				begin
					if(std==3'b100)//若正处于找零状态
						std<=3'b111;//出票
						pay1<=0;
						pay10<=0;
						pay100<=0;
				end
				else
				begin//费用计算
					if((10*count2+count1)<=5)
						fee<=3*count0;
					else if(((10*count2+count1)>5)&&((10*count2+count1)<=10))
						fee<=4*count0;
					else if(((10*count2+count1)>10)&&((10*count2+count1)<=15))
						fee<=5*count0;
					else if(((10*count2+count1)>15)&&((10*count2+count1)<=20))
						fee<=6*count0;
					else
						fee<=(6+((10*count2+count1)-20)/10)*count0;
					change<=pay-fee;
					if(pay==fee)//正好
					begin
						std<=3'b111;//出票 
					end
					else if(pay>fee)//钱多
					begin	
						std<=3'b100;//找零
						pay1<=change%10;
						pay10<=(change/10)%10;
						pay100<=change/100;
					end
					else//钱不够
						std<=3'b000;//失败
				end//else key7
			end//key6
			else if(key==2'b00)
				std<=3'b001;	
		end//else test>0
	end
end

/********************************************************数码管part*******************************************************/
output [7:0] ds;//八位
output [7:0] seg;//单个数码管
reg [7:0] ds;
reg [7:0] seg;
reg [2:0] cnt;
reg [3:0] data;//数码管扫描数据寄存

always @(posedge clk)//共八个数码管，使用八位分频扫描
begin 
	cnt<=cnt+1;
end


always @(std or cnt or sw)//状态图案设计
begin
if(!sw)
	ds<=8'b11111111;
else
begin
if(std==3'b101)
begin
	if(!cntp[9])
	begin
		ds<=8'b000000000;
		data[3:0]<=4'b1000;
	end
	else
	begin
		ds<=8'b11111111;
		data[3:0]<=4'b1000;
	end
end

else
begin
	case(cnt)//根据分频扫描各晶体管数字
	3'b000:begin ds<=8'b11111110;data[3:0]<=count0;end
	3'b001:begin ds<=8'b11111111;data[3:0]<=0;end
	3'b010:begin ds<=8'b11111011;data[3:0]<=count1;end
	3'b011:begin ds<=8'b11110111;data[3:0]<=count2;end
	3'b100:begin ds<=8'b11111111;data[3:0]<=0;end
	3'b101:begin ds<=8'b11011111;data[3:0]<=pay1;end
	3'b110:begin ds<=8'b10111111;data[3:0]<=pay10;end
	3'b111:begin ds<=8'b01111111;data[3:0]<=pay100;end
	default:begin ds<='bz;data[3:0]<='bz;end
	endcase
end
end
end


always @(data)
begin
	case(data[3:0])//数码管数字显示
	4'b0000:seg[7:0]<=8'b00111111;
	4'b0001:seg[7:0]<=8'b00000110;
	4'b0010:seg[7:0]<=8'b01011011;
	4'b0011:seg[7:0]<=8'b01001111;
	4'b0100:seg[7:0]<=8'b01100110;
	4'b0101:seg[7:0]<=8'b01101101;
	4'b0110:seg[7:0]<=8'b01111101;
	4'b0111:seg[7:0]<=8'b00000111;
	4'b1000:seg[7:0]<=8'b01111111;
	4'b1001:seg[7:0]<=8'b01101111;
	default:seg[7:0]<='bz;
	endcase
end

/*********************************************************点阵part*******************************************************/
output [7:0] row;
output [7:0] rcol;
output [7:0] gcol;
reg [7:0] row;
reg [7:0] rcol;
reg [7:0] gcol;

reg [7:0] r0;
reg [7:0] r1;
reg [7:0] r2;
reg [7:0] r3;
reg [7:0] r4;
reg [7:0] r5;
reg [7:0] r6;
reg [7:0] r7;

reg [7:0] g0;
reg [7:0] g1;
reg [7:0] g2;
reg [7:0] g3;
reg [7:0] g4;
reg [7:0] g5;
reg [7:0] g6;
reg [7:0] g7;

always @(cnt)
if(!sw)
	row<=8'b11111111;
else
begin
	case(cnt)
	3'b000:begin row[7:0]<=8'b11111110;rcol[7:0]<=r7;gcol[7:0]<=g7;end
	3'b001:begin row[7:0]<=8'b11111101;rcol[7:0]<=r6;gcol[7:0]<=g6;end
	3'b010:begin row[7:0]<=8'b11111011;rcol[7:0]<=r5;gcol[7:0]<=g5;end
	3'b011:begin row[7:0]<=8'b11110111;rcol[7:0]<=r4;gcol[7:0]<=g4;end
	3'b100:begin row[7:0]<=8'b11101111;rcol[7:0]<=r3;gcol[7:0]<=g3;end
	3'b101:begin row[7:0]<=8'b11011111;rcol[7:0]<=r2;gcol[7:0]<=g2;end
	3'b110:begin row[7:0]<=8'b10111111;rcol[7:0]<=r1;gcol[7:0]<=g1;end
	3'b111:begin row[7:0]<=8'b01111111;rcol[7:0]<=r0;gcol[7:0]<=g0;end
	default:;
	endcase
end

reg [9:0] cntp;//分频 一轮1秒 [9]0.5秒
reg [1:0] test=2'b11;

always @(posedge clk)//动画显示分频
begin
	cntp<=cntp+1;
end

always @(posedge cntp[9] or negedge sw)//开机自检倒计数三次
begin
	if(!sw)
		test<=2'b11;
	else
	begin
		if(test>0)
			test<=test-1;
		else if(test==0)
			test<=0;
	end
end

always @(std)//状态图案设计
if(std==3'b101)
begin
	if(!cntp[9])
	begin
		r0<=8'b1111_1111;g0<=8'b1111_1111;
		r1<=8'b1111_1111;g1<=8'b1111_1111;
		r2<=8'b1111_1111;g2<=8'b1111_1111;
		r3<=8'b1111_1111;g3<=8'b1111_1111;
		r4<=8'b1111_1111;g4<=8'b1111_1111;
		r5<=8'b1111_1111;g5<=8'b1111_1111;
		r6<=8'b1111_1111;g6<=8'b1111_1111;
		r7<=8'b1111_1111;g7<=8'b1111_1111;
	end
	else
	begin
		r0<=8'b0000_0000;g0<=8'b0000_0000;
		r1<=8'b0000_0000;g1<=8'b0000_0000;
		r2<=8'b0000_0000;g2<=8'b0000_0000;
		r3<=8'b0000_0000;g3<=8'b0000_0000;
		r4<=8'b0000_0000;g4<=8'b0000_0000;
		r5<=8'b0000_0000;g5<=8'b0000_0000;
		r6<=8'b0000_0000;g6<=8'b0000_0000;
		r7<=8'b0000_0000;g7<=8'b0000_0000;
	end
end

else if(std==3'b001)
begin
	r0<=8'b0000_0000;g0<=8'b0000_0000;
	r1<=8'b0000_0000;g1<=8'b1111_1111;
	r2<=8'b0000_0000;g2<=8'b1000_0001;
	r3<=8'b0000_0000;g3<=8'b1000_0001;
	r4<=8'b0000_0000;g4<=8'b1000_0001;
	r5<=8'b0000_0000;g5<=8'b1111_1111;
	r6<=8'b0000_0000;g6<=8'b1000_0001;
	r7<=8'b0010_0100;g7<=8'b1010_0101;
end

else if(std==3'b000)
begin
	r0<=8'b1000_0001;g0<=8'b0000_0000;
	r1<=8'b0100_0010;g1<=8'b0000_0000;
	r2<=8'b0010_0100;g2<=8'b0000_0000;
	r3<=8'b0001_1000;g3<=8'b0000_0000;
	r4<=8'b0001_1000;g4<=8'b0000_0000;
	r5<=8'b0010_0100;g5<=8'b0000_0000;
	r6<=8'b0100_0010;g6<=8'b0000_0000;
	r7<=8'b1000_0001;g7<=8'b0000_0000;
end

else if(std==3'b100)
begin
	if(cntp[9])
	begin
		r0<=8'b0011_1100;g0<=8'b0011_1100;
		r1<=8'b0101_1010;g1<=8'b0101_1010;
		r2<=8'b1011_1001;g2<=8'b1011_1001;
		r3<=8'b1001_1001;g3<=8'b1001_1001;
		r4<=8'b1001_1001;g4<=8'b1001_1001;
		r5<=8'b1001_1001;g5<=8'b1001_1001;
		r6<=8'b0101_1010;g6<=8'b0101_1010;
		r7<=8'b0011_1100;g7<=8'b0011_1100;
	end
	else
	begin
		if(cntp[8])
		begin
			r0<=8'b0011_1100;g0<=8'b0011_1100;
			r1<=8'b0101_1010;g1<=8'b0101_1010;
			r2<=8'b0101_1010;g2<=8'b0101_1010;
			r3<=8'b0101_1010;g3<=8'b0101_1010;
			r4<=8'b0101_1010;g4<=8'b0101_1010;
			r5<=8'b0101_1010;g5<=8'b0101_1010;
			r6<=8'b0101_1010;g6<=8'b0101_1010;
			r7<=8'b0011_1100;g7<=8'b0011_1100;
		end
		else
		begin
			r0<=8'b0001_1000;g0<=8'b0001_1000;
			r1<=8'b0001_1000;g1<=8'b0001_1000;
			r2<=8'b0001_1000;g2<=8'b0001_1000;
			r3<=8'b0001_1000;g3<=8'b0001_1000;
			r4<=8'b0001_1000;g4<=8'b0001_1000;
			r5<=8'b0001_1000;g5<=8'b0001_1000;
			r6<=8'b0001_1000;g6<=8'b0001_1000;
			r7<=8'b0001_1000;g7<=8'b0001_1000;
		end
	end
end

else if(std==3'b111)
	if(cntp[9])
	begin
		r0<=8'b0000_0000;g0<=8'b0000_0000;
		r1<=8'b0000_0000;g1<=8'b0000_0000;
		r2<=8'b1010_1010;g2<=8'b0101_0101;
		r3<=8'b0000_0001;g3<=8'b1000_0000;
		r4<=8'b1000_0000;g4<=8'b0000_0001;
		r5<=8'b0101_0101;g5<=8'b1010_1010;
		r6<=8'b0000_0000;g6<=8'b0000_0000;
		r7<=8'b0000_0000;g7<=8'b0000_0000;
	end
	else
	begin
		g0<=8'b0000_0000;r0<=8'b0000_0000;
		g1<=8'b0000_0000;r1<=8'b0000_0000;
		g2<=8'b1010_1010;r2<=8'b0101_0101;
		g3<=8'b0000_0001;r3<=8'b1000_0000;
		g4<=8'b1000_0000;r4<=8'b0000_0001;
		g5<=8'b0101_0101;r5<=8'b1010_1010;
		g6<=8'b0000_0000;r6<=8'b0000_0000;
		g7<=8'b0000_0000;r7<=8'b0000_0000;
	end

endmodule

/***********************************************************消抖**********************************************************/
module debounce (clk,key,key_pulse);
	parameter N=1;
	input clk;
	input [N-1:0] key;
	output [N-1:0] key_pulse;
	reg [N-1:0] key_rst_pre;
	reg [N-1:0] key_rst;
	wire [N-1:0] key_edge;

always @(posedge clk)
begin
	key_rst <= key;
	key_rst_pre <= key_rst;
end
assign key_edge = (~key_rst_pre) & (key_rst);
reg [3:0] cnt;//产生延时所用的计数器，系统时钟1kHz，要延时20ms左右时间，至少需要4位计数器     

always @(posedge clk)
begin
	if(key_edge)
		cnt <= 4'b0001;
	else
		cnt <= cnt + 4'b0001;
end

reg [N-1:0] key_sec_pre;
reg [N-1:0] key_sec;                    

always @(posedge clk)
begin
	if (cnt==4'b1111)
		key_sec <= key;  
end

always @(posedge clk)
begin
	key_sec_pre <= key_sec;             
end      
	
assign  key_pulse = (~key_sec_pre)& (key_sec);     
 
endmodule
