// Code your design here

//LATCHES
//Positive level D latch with Enable as clock
module pdlatch(d,e,q);
  input d, e;
  output reg q;
  
  always @(d,e) begin //so when d or e is high, the always block gets triggered. If enable is high, latch is transparent q<=d.
                      //else is missing, so when e is low, latch is inferred and output q holds the value.
    if(e)
      q<=d;
    
  end
endmodule

//Negative level D latch with Enable as clock
module ndlatch(d,e,q);
  input d, e;
  output reg q;
  
  always @(d,e) begin
    if(!e)
      q<=d;
  end
endmodule

//FLIPFLOPS
//We start using if-else here. Note that it is priority based condition check. if->1st priority ; else if->2nd priority; else->least priority
//Positive edge Dff async
module pdff(clk,rstn,d,q);
  input clk, rstn,d;
  output reg q;
  
  always @(posedge clk, negedge rstn) begin   //Async rstn but problem with it is: 1. Needs to be timed asyn check/put 2ff sync to avoid Race    												around. 2. Is prone to glitches on rstn input and can reset the whole memory if glitch wide/thres
    if(!rstn) 
      q<=1'b0;
    else
      q<=d;
  end
endmodule

//*****For negative clk edge as active, just use always @(negedge clk) thats it.

//Positive edge Dff sync
module pdff1(d,clk,rstn,q);
  input d,clk,rstn;
  output reg q;
  								 //The reset mechanism is a part of input data path d. No issues with glitches and no timing check on reset
  always @(posedge clk) begin    //sync reset, so when clock edge arrives, then only any operatio can be perfored
    if (!rstn)
      q<=1'b0;
    else
      q<=d;
    
  end
endmodule

//Same +ve edge DFF, but with load, so when loadenable (le) is high, the output q goes to 1
//+ve edge DFF with async load and async reset

//rstn has highest priority, next priority is load; the least priortized is to assign q<=d
module pdffl(clk,rstn,le,d,q);
  input clk, rstn, le, d;
  output reg q;
  
  always @(posedge clk or negedge rstn or posedge le) begin
    if (!rstn)
      q<=1'b0;
    else if (le)
      q<=1'b1;
    else
      q<=d;
  end
endmodule

//+ve edge DFF with sync load and sync reset
module pdffl1 (clk,rstn,le,d,q);
  input clk, rstn,le,d;
  output reg q;
  
  always @(posedge clk) begin
    if(!rstn)
      q<=1'b0;
    else if (le)
      q<=1'b1;
    else
      q<=d;
  end
endmodule

//COUNTERS

//3 bit UP counter with synchronous reset and synchronous load

module s_upc(clk,rstn,le,din,q);
  input clk, rstn, le;
  input [2:0] din;
  output reg [2:0] q;
  //sync load and sync reset (rest having higher priority)
  always @(posedge clk) begin
    if(!rstn) 
      q <= 3'b000;
    else if(le)
      q<=din;
    else
      q<=q + 1'b1;
    
  end
endmodule

//3 bit UP Counter with async reset and sync load

module a_upc(clk,rstn,le,din,q);
  input clk,rstn,le;
  input [2:0] din;
  output reg [2:0] q;
  
  always @(posedge clk or negedge rstn) begin
    if(!rstn)
      q <= 3'b000;
    else if (le)
      q <= din;
    else
      q <= q + 1'b1;
    
  end
endmodule

//3 bit DOWN Counter with sync reset and sync load

module s_dc(clk,rstn,le,din,q);
  input clk, rstn, le;
  input [2:0] din;
  output reg [2:0] q;
  //sync load and sync reset (rest having higher priority)
  always @(posedge clk) begin
    if(!rstn) 
      q <= 3'b000;
    else if(le)
      q<=din;
    else
      q<=q - 1'b1;
    
  end
endmodule

//3 bit DOWN Counter with async reset and sync load

module a_dc(clk,rstn,le,din,q);
  input clk, rstn, le;
  input [2:0] din;
  output reg [2:0] q;
  //sync load and async reset (rest having higher priority)
  always @(posedge clk or negedge rstn) begin
    if(!rstn) 
      q <= 3'b000;
    else if(le)
      q<=din;
    else
      q <= q - 1'b1;
    
  end
endmodule

//3 bit UP-DOWN Counter with async reset and sync load

module a_udc (clk,rstn,updown,le,din,q);
  input clk, rstn, le, updown;
  input [2:0] din;
  output reg [2:0] q;
  
  always @(posedge clk or negedge rstn) begin
    
    if(!rstn)
      q <= 3'b000;
    
    else if (le)
      q<=din;
    
    else begin
      if (updown)
        q<=q+1'b1;
      else
      	q<=q-1'b1;
    end
    
  end
    
endmodule


//Doesn't work for me logically. Direction's value is updated at the end of the timestep and counter's value will be incremented or decremented based upon the previous timestep's direction's value. So it will act like a delayed operation.
//3 bit UP-DOWN Counter with async reset and sync load (OTHER WAY-INTEL)
module a_udco (clk,rstn,updown,le,din,q);
  input clk, rstn, le, updown;
  input [2:0] din;
  output reg [2:0] q;
  integer direction;
  
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      q<=3'b000;
    else if (le)
      q<=din;
    else begin
      if(updown)
        direction <= 1;
      else
        direction <= -1;
    end
    
    if (rstn && !le)  //this is required because you cannot put q<=q+direction right after the 1st if-else loop just beleow the last line
      					//because it will cause the statemnet to be executed even during the rstn or le event on the same clk edge
      q <= q + direction;
    
  end
endmodule


//4-bit Gray counter with sync load and sync reset

module gray(clk,rstn,datain,le,out);
  
  input clk, rstn, le;  //all control signals
  input [3:0] datain;  //for syn load
  
  output reg [3:0] out; //final gray counters o/p
  
  reg [3:0] count;  //to hold binary counter value
  
  reg q2,q1,q0; //temp regs to hold the binary->gray calculations!
  
  always @(posedge clk) begin
    
    if (!rstn) begin
      
      count <= 4'b0000;
      {q2,q1,q0} <= 3'b000;
      out <= 4'b0000;
    end
    
    else if (le) begin
      count <= datain;
      
      //{q2,q1,q0} <= {datain[2],datain[1],datain[0]};  // Instead of this and
      //out <= {datain[3],datain[2],datain[1],datain[0]}; // this line, shouldn't it be the next 4 lines??
      
      //use this instead:->
      q2 <= count[3] ^ count[2];
      q1 <= count[2] ^ count[1];
      q0 <= count[1] ^ count[0];
      out <= {count[3],q2,q1,q0};
      
    end
    
    else begin
      count <= count + 1'b1;
      q2 <= count[3] ^ count[2];
      q1 <= count[2] ^ count[1];
      q0 <= count[1] ^ count[0];
      
      out <= {count[3],q2,q1,q0};
    end
    
  end
endmodule

//4-bit GRAY Counter -> simple only with sync reset
  
module gray1(clk,rstn,out);
  
  input clk, rstn;  //all control signals

  //output reg [3:0] out; //final gray counters o/p
  output [3:0] out;
  reg [3:0] count;  //to hold binary counter value
  
  
  always @(posedge clk) begin
    
    if (!rstn) begin
      
      count <= 4'b0000;
      
    end
    
    else begin
      
      count <= count + 1'b1;
      //out <= {count[3],(count[3]^count[2]),(count[2]^count[1]),(count[1]^count[0])}; //here previous value is considered, so out is 1 cycle late
      
    end
    
  end
  
   assign out = {count[3],(count[3]^count[2]),(count[2]^count[1]),(count[1]^count[0])}; //here as soon as count gets its value the out gets 																							//	its value in the same time step
  
endmodule

//RING Counter 4-bit with sync reset action to 1000 ->used to have a predefined delay.

module ring(clk,rstn,count);
  input clk,rstn;
  output reg [3:0] count;
  
  always @(posedge clk) begin
    if (!rstn) 
      count<=4'b1000;
    else begin
      count[0]<=count[3];
      count <= count << 1;
    end
  end
endmodule


//JOHNSON Counter 4-bit with sync reset
module johnsoncounter(clk,rstn,count);
  input clk, rstn;
  output reg [3:0] count;
  
  always @(posedge clk) begin
    if (!rstn) 
      count<=4'b0000;
    
    else
      count[0] <= ~ count[3];  //visualise  the Shift registers LSB to MSB bits from diagram. You will understand this easily
    count [3:1] <= count[2:0]; //--------------------------//---------------------------------------------------------------
    
  end
endmodule

//PARAMETERIZED COUNTER -> UP Counter

module para_count(clk,rstn,datain,le,count);
  parameter N = 4;
  
  input clk, rstn, le;
  input [N-1:0] datain;
  output reg [N-1:0] count;
  
  always @(posedge clk) begin
    if (!rstn)
      count <= 0;
    else if (le)
      count <= datain;
    else 
      count <= count + 1'b1;
  end
endmodule
  
//4-bit Ripple Counter
module ripplecounter(clk,rstn,toggle_in,count);
  input clk, rstn,toggle_in;
  output [3:0] count;
  
  reg [3:0] count;
  wire c0,c1,c2;
  
  assign c0 = count[0];
  assign c1 = count[1];
  assign c2 = count[2];
  
  always @(posedge clk or negedge rstn) begin
    if(!rstn)
      count[0] <= 1'b0;
    else if (toggle_in == 1'b1)
      count[0] = ~ count[0];
  end
  
  always @(negedge c0 or negedge rstn) begin
    if(!rstn)
      count[1] <= 1'b0;
    else if (toggle_in == 1'b1)
      count[1] = ~ count[1];
  end
  
  always @(negedge c1 or negedge rstn) begin
    if(!rstn)
      count[2] <= 1'b0;
    else if (toggle_in == 1'b1)
      count[2] = ~ count[2];
  end
  
  always @(negedge c2 or negedge rstn) begin
    if(!rstn)
      count[3] <= 1'b0;
    else if (toggle_in == 1'b1)
      count[3] = ~ count[3];
  end
  
endmodule


module memory(clk,rd_en,wr_en,datain,addr,dataout);
  
  input clk;
  input rd_en;
  input wr_en;
  input [7:0] datain;
  input [9:0] addr;
  output reg [7:0] dataout;  //read data is latched here.
  reg [7:0] mem [0:1023];    //internal memory block, 1024 loaction, each having 8 bits capacity
 
  always @(posedge clk) begin
    if (wr_en==1'b1 && rd_en ==1'b0)   // if write=1,read=0, then only do write operation. this is done to not let rd wr happen at same location   
      mem[addr]<=datain;
  end
  
  always @(posedge clk) begin
    if (rd_en==1'b1 && wr_en==1'b0) 
      dataout<=mem[addr];
  end
  
endmodule
      
      
  