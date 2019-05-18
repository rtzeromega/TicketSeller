  module VOTE3
    (
      input wire a,           //3个输入变量a、b、c
      input wire b,
      input wire c,
      output wire led         //显示表决结果led
    );
     assign 	led = ~((a&b)|(b&c)|(a&c));   //根据逻辑表达式得到表决结果
  endmodule