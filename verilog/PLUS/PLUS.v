module PLUS1(num1,num2,clow,sum,chigh);
		input num1,num2,clow;
		output sum,chigh;
		assign sum = num1^num2^clow;
		aPLUS(ssign chigh = ((num1^num2)*clow)+(num1*num2);
endmodule

module plus(a,b,led);
		input [3:0] a,b;
		output [4:0] led;
		wire cout0,cout1,cout2,co;
		wire [3:0] s;

		PLUS1 u1(.num1(a[0]),.num2(~b[0]),.clow(0),.sum(s[0]),.chigh(cout0));
		PLUS1 u2(.num1(a[1]),.num2(~b[1]),.clow(cout0),.sum(s[1]),.chigh(cout1));
		PLUS1 u3(.num1(a[2]),.num2(~b[2]),.clow(cout1),.sum(s[2]),.chigh(cout2));
		PLUS1 u4(.num1(a[3]),.num2(~b[3]),.clow(cout2),.sum(s[3]),.chigh(co));
		assign led[0]= ~s[0];
		assign led[1]= ~s[1];
		assign led[2]= ~s[2];
		assign led[3]= ~s[3];
		assign led[4]= ~co;
endmodule

