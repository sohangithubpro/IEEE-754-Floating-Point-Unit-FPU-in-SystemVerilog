// Code your design here


module fpu(a,b,op,out);
  input logic [31:0] a,b;
  input logic [1:0] op;
  output logic [31:0] out;
  
  
  //create mantissa
  logic [23:0] mant_a,mant_b;
  assign mant_a={1,a[22:0]};
  assign mant_b={1,b[22:0]};
  
  //create exponents
  logic [7:0] exp_a,exp_b;
  
  assign exp_a=a[30:23];
  assign exp_b=b[30:23];
  
  //create sum and diff reg
  logic [23:0] sum,diff;
  
  int index;
  //create_alligned mantissa (for add and sub)
  logic [23:0] all_manta,all_mantb;
  assign all_manta=(exp_b>exp_a)?(mant_a >>(exp_b-exp_a)):mant_a;
  assign all_mantb=(exp_a>exp_b)?(mant_b >>(exp_a-exp_b)):mant_b;
  
  //create prod reg
  logic [47:0] prod;
  
  //create dividend and quotient reg
  logic [47:0] dividend,quotient;
  
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
  assign sign=(a[0]==1 || b[0] == 1)?1:0;
  
  always_comb begin
    case(op)
      //add
      2'b00:begin
        sum=(a[0]==b[0])? all_manta+all_mantb : all_manta-all_mantb;
        $display("Sum is : %24b",sum);
      end
      
      //sub
      2'b01: begin
        diff=(all_manta > all_mantb) ? (all_manta-all_mantb) : (all_mantb-all_manta);
        $display("difference is %24b",diff);
      end
      
      //mul
      2'b10: begin
        prod=mant_a * mant_b;
        $display("prod is : %48b",prod);
        //normalize the prod(msb==1)
        for(int i=47;i>=0;i--)
          begin
            if(prod[i]==1)
              begin
                index=i;
                break;
              end
          end
        $display("index is %0d",index);
        normalized_val=prod<<(47-index);
        $display("normalized result is :%48b",normalized_val);
        nor_mant=normalized_val[47:24];
        $display("nor mant is : %24b",nor_mant);
        //rounding logic
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
      end
      
      //div (a/b)
      2'b11: begin
        dividend=mant_a<<24;
        quotient=dividend/mant_b;
        $display("quotient is :%48b",quotient);
        //normalize the quotient(msb==1)
        for(int i=47;i>=0;i--)
          begin
            if(quotient[i]==1)
              begin
                index=i;
                break;
              end
          end
        $display("index is %0d",index);
        normalized_val=quotient<<(47-index);
        $display("normalized result is :%48b",normalized_val);
        nor_mant=normalized_val[47:24];
        //rounding logic
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
      end
      /*exp_result=(exp_a > exp_b)? exp_a-exp_b+127 :exp_b-exp_a+127;
      out={sign,exp_result,rounded_result};
      $display("actual output is :%32b",out);*/
    endcase
  end
endmodule
    
    
            
        
        
        
        
        
        
