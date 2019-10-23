module DTOUCH
(
    input                clk,
    input                key,
	 input                reset,
	 input                sw,
    output [3:0]         led,
	 output [8:0]         Count1,
    output [8:0]         Count2
	 
);  

     reg [3:0] count;
     reg [31:0] timer;
	  reg [8:0] num [9:0];
     reg [3:0] count1=4'b0000;
     reg [3:0] count2=4'b0000;

initial                                                                                                                           
  begin
    num[0] = 9'h3f;                                    
	 num[1] = 9'h06;                                         
	 num[2] = 9'h5b;                                       
	 num[3] = 9'h4f;                                           
	 num[4] = 9'h66;                                        
	 num[5] = 9'h6d;                                         
	 num[6] = 9'h7d;                                           
	 num[7] = 9'h07;                                           
	 num[8] = 9'h7f;                                          
	 num[9] = 9'h6f;                                           
  end 	  
	  
	  reg [23:0] cnt;
	  always@(posedge clk)
	  begin
	  if(cnt==24'd12000000||sw)
			cnt<=0;
		else
			cnt<=cnt+1;
	  end
	  
	  
	  
  always@(posedge clk)
  begin    
	 if(sw)
	 begin
		if(reset ==1'b0)
			begin
				count1<=4'b0000;
				count2<=4'b0000;
			end
		else
	    if(key == 1'b0)
            timer <= timer + 24'd1;
       else
            timer <= 31'd0;    
       if(timer == 31'd500_000)
          begin 
			  if(count1==4'b0011&&count2==4'b0000)
	            begin
		            count1<=4'b0000;
		            count2<=4'b0000;
	            end
	        else
			   begin
			    if(count2==4'b1001)
		          begin
			         count1<=count1+4'b0001;
			         count2<=4'b0000;
		          end
		       else 
		          begin
			         count2<=count2+4'b0001;
			       end
				end
			  end
			end
	 else
	 begin
	 if(cnt==24'd12000000)
		if(count2==0&&count1==0)
		begin
			count1<=0;
			count2<=0;
		end
		else
		begin
		  if(count2==0)
		  begin
			count1<=count1-1;
			count2<=4'b1001;
		  end
		  else
		  begin
		   count2<=count2-1;
		  end
      end
	end
  end
     assign Count1=num[count1];
     assign Count2=num[count2];
	  
endmodule
