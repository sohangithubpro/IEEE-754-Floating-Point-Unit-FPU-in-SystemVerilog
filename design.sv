// Code your design here


module fpu(clk,rst,a,b,perm,op,out);
  input logic clk,rst;
  input logic [31:0] a,b;
  input logic perm;
  input logic [1:0] op;
  output logic [31:0] out;
  
  //define reg which keep of track of the operations being performed in each state
  logic prep,comp,norm,round,wb,edge1;
  
  //define states
  typedef enum logic [3:0] {Idle, Prepare, Edge, Compute, Normalize, Round, Writeback} state_type;
  state_type state;
  state_type next_state;
  
  
  //define state values
  always_ff @(posedge clk)
    begin
      if(rst)
        begin
          state<=Idle;
        end
      else
        state<=next_state;
    end
  
  
  //define state transition
  always_comb begin
    case(state)
      Idle: next_state=(perm==1)?Prepare:Idle;
      Prepare: next_state=(prep==1 && (op==2'b00 || op==2'b01))?Compute:Edge;
      Edge: next_state=(a[30:0] !=0 && b[30:0] !=0)?Compute:(edge1==1)?Writeback:Edge;
      Compute: next_state=((op==2'b10 || op==2'b11) & (comp==1))?Normalize: (comp==1)?Writeback:Compute;
      Normalize: next_state=(norm==1)?Round:Normalize;
      Round: next_state=(round==1)?Writeback:Round;
      Writeback: next_state=(wb==1)?Idle:Writeback;
    endcase
  end
  
  
  
  
  
  //create mantissa
  logic [23:0] mant_a,mant_b;
  
  //create exponents
  logic [7:0] exp_a,exp_b;
  
  //create sum and diff reg
  logic [23:0] sum,diff;
  
  int index;
  //create_alligned mantissa (for add and sub)
  logic [23:0] all_manta,all_mantb;
  
  //create reg to store prod or div result based on op value
  logic [47:0] proddiv;
  
  //create dividend and quotient reg
  logic [47:0] dividend;
  
  //normalized prod and quo
  logic [47:0] normalized_val;
  
  //mantissa in normalized val
  logic [23:0] nor_mant;
  
  //rounded result
  logic g,r;
  logic [21:0] s;
  logic [22:0] rounded_result;
  
  logic [7:0] exp_result;
  logic sign;
  
  
  //define operations in each state
  always_ff @(posedge clk)
    begin
      if(!rst)
        begin
          case(state)
            //reset everything to zero
            Idle: begin
              mant_a<=0;
              mant_b<=0;
              exp_a<=0;
              exp_b<=0;
              all_manta<=0;
              all_mantb<=0;
              sign<=0;
            end
            //assign values
            Prepare: begin
              mant_a={1,a[22:0]};
              mant_b={1,b[22:0]};
              exp_a=a[30:23];
              exp_b=b[30:23];
              all_manta=(exp_b>exp_a)?(mant_a >>(exp_b-exp_a)):mant_a;
              all_mantb=(exp_a>exp_b)?(mant_b >>(exp_a-exp_b)):mant_b;
              $display("mant_a is %24b",mant_a);
              $display("mant_b is %24b",mant_b);
              prep=1;
            end
            
            //detect Edge
            Edge: begin
              //edge case for multiplication (+0 x b or a x +0)
              if(op==2'b10 && (a[30:0]==0 || b[30:0]==0))
                begin
                  rounded_result=24'h0;
                  exp_result=0;
                  sign=a[31]^b[31];
                  edge1=1;
                end
              
              //edge case detection for division (0/b)
              else if(op==2'b11 && (a[30:0]==0 && b[30:0]!=0))
                begin
                  rounded_result=0;
                  exp_result=0;
                  sign=a[31]^b[31];
                  edge1=1;
                end
            //edge case detection for division(a/0)
            else if(op==2'b11 && (a[30:0] !=0 && b[30:0]==0))
              begin
                rounded_result=0;
                exp_result=8'hFF; //infinity condition
                sign=a[31]^b[31];
                edge1=1;
              end
            end
            
            //perform the operation 
            Compute: begin
              case(op)
                2'b00: begin
                  sum=(a[0]==b[0])? all_manta+all_mantb : all_manta-all_mantb;
                  $display("Sum is %24b",sum);
                  rounded_result<=sum[22:0];
                  exp_result=(exp_a>exp_b)?exp_a:exp_b;
                  //a+b
                  if(a[0]==0 && b[0]==0)
                    sign=0;
                  //a+(-b) (all_manta>all_mantb)
                  else if(a[0]==0 && b[0]==1 && (all_manta>all_mantb))
                    sign=0;
                  //a+(-b) //all_mantb>all_mantb
                  else if(a[0]==0 && b[0]==1 && (all_mantb>all_manta))
                    sign=1;
                  //-a+(-b)
                  else if(a[0]==1 && b[0]==1)
                    sign=1;
                  comp=1;
                end
                2'b01: begin
                  diff=(all_manta>all_mantb)?all_manta-all_mantb : all_mantb-all_mantb;
                  $display("difference is %24b",diff);
                  rounded_result=diff[22:0];
                  exp_result=(exp_a>exp_b)?exp_a:exp_b;
                  //a-b, a>b
                  if(all_manta>all_mantb)
                    sign=0;
                  //a-b, b>a
                  else if(all_mantb>all_manta)
                    sign=1;
                  //a-(-b)
                  else if(b[0]==1 && a[0]==0)
                    sign=0;
                  //-a-b
                  else if(a[0]==1 && b[0]==0)
                    sign=1;
                  comp=1;
                end
                2'b10: begin
                  proddiv=mant_a*mant_b;
                  $display("prod is %48b",proddiv);
                  exp_result=(exp_a>exp_b)?exp_a-exp_b+127:exp_b-exp_a+127;
                  sign=a[0]^b[0];
                  comp=1;
                end
                2'b11: begin
                  dividend=mant_a<<24;
                  proddiv=dividend/mant_b;
                  $display("quotient is %48b",proddiv);
                  exp_result=(exp_a>exp_b)?exp_a-exp_b+127:exp_b-exp_a+127;
                  sign=a[0]^b[0];
                  comp=1;
                end
              endcase
            end
            
            Normalize: begin
                 for(int i=47;i>=0;i--)
                  begin
                    if(proddiv[i]==1)
                      begin
                        index=i;
                        break;
                      end
                  end
              $display("index is %0d",index);
              normalized_val=proddiv<<(47-index);
              $display("normalized result is :%48b",normalized_val);
              nor_mant=normalized_val[47:24];
              $display("nor mant is : %24b",nor_mant);
              norm=1;
              end
            
            Round: begin
              g=normalized_val[23];
              r=normalized_val[22];
              s=normalized_val[21:0];
              if(g==1 && (r==1 || |s==1 || normalized_val[0]==1))
                begin
                  rounded_result=nor_mant+1;
                  $display("rounded result : %23b",rounded_result);
                end
              else
                begin
                  rounded_result=nor_mant;
                  $display("not rounded result : %23b",rounded_result);
                end
              round=1;
            end
            
            Writeback: begin
              $display("a is %32b",a);
              $display("b is %32b",b);
              out={sign,exp_result,rounded_result};
              $display("actual output is %32b",out);
              wb=1;
            end
          endcase
        end
    end
endmodule
        

    
    
            
        
        
        
        
        
        
