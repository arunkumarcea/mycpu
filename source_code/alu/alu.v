/*Designer : Arunkumar V 
This is the alu unit for the 8 bit microprocessor.
The design is based on the alu architecture explained
in coursera course by Lluis Teres Instituto de Microelectrónica de Barcelona, IMB-CNM (CSIC)
Universitat Autònoma de Barcelona (UAB)
*/
//`include "timescale.vh"
module alu 
#(
parameter m = 8,
parameter Noop	=	4'd0,
parameter Addr	=	4'd1,
parameter Subt	=	4'd2,
parameter IncL	=	4'd3,
parameter IncR	=	4'd4,
parameter DecL	=	4'd5,
parameter DecR	=	4'd6,
parameter lAnd	=	4'd7,
parameter lOr	=	4'd8,
parameter lNot	=	4'd9,
parameter ShtL	=	4'd10,
parameter RotR	=	4'd11,
parameter GoL	=	4'd12,
parameter GoR	=	4'd13,
parameter Out0	=	4'd14,
parameter Out1	=	4'd15
)
(
input	[3:0]	OpAlu,
input	[m-1:0] A,
input clk,reset,
input	[m-1:0] B,
output  [m-1:0] ResBus,
output  [3:0]   alustat

);

//FLAG REGISTERS
reg C_flag,Z_flag,O_flag,N_flag;

wire Csh; // shift carry

wire [m-1:0]	Noop_signal;
wire [m-1:0]	Addr_signal;
wire [m-1:0]	Subt_signal;
wire [m-1:0]	IncL_signal;
wire [m-1:0]	IncR_signal;
wire [m-1:0]	DecL_signal;
wire [m-1:0]	DecR_signal;
wire [m-1:0]	lAnd_signal;
wire [m-1:0]	lOr_signal;
wire [m-1:0]	lNot_signal;
wire [m-1:0]	ShtL_signal;
wire [m-1:0]	RotR_signal;
wire [m-1:0]	GoL_signal;
wire [m-1:0]	GoR_signal;
wire [m-1:0]	Out0_signal;
wire [m-1:0]	Out1_signal;

reg [m-1:0] aluout;
reg [m-1:0] addinL,addinR,A2,B2;

reg Carry_alu_out;
wire Carry_overflow_out;
reg [m-1:0] Arith_signal;

reg [m-1:0] twoscompLout,twoscompRout;
reg [m-1:0] A2_bar,B2_bar;

reg C_update_flag;
reg N_update_flag;
reg Z_update_flag;
reg O_update_flag;
//------------------------------------------------------------------------------------------
//No operations block
//------------------------------------------------------------------------------------------
assign Noop_signal 	=	{m{1'b0}};

//------------------------------------------------------------------------------------------
//Logical operation blocks
//------------------------------------------------------------------------------------------
assign lAnd_signal	=	A & B;
assign lOr_signal	= A | B;
assign lNot_signal	=	~ A;
//------------------------------------------------------------------------------------------
//Shifting Operation blocks
//------------------------------------------------------------------------------------------
// Left shift
assign ShtL_signal = A << 1;
assign Csh = A[m-1]; 			// shift carry
//Right rotate
assign RotR_signal = {A[0],A[m-1:1]};
//------------------------------------------------------------------------------------------
//Data transfer operations
//------------------------------------------------------------------------------------------
assign GoL_signal	=	A;  // A to output
assign GoR_signal	=	B;	//	B to output
assign Out0_signal	=	{m{1'b0}};  // output 0
assign Out1_signal	=	{m{1'b1}};	//	output all 1
//

//Arithmetic operations
//Logic to select operands
always@(*)
begin
//------------------------------------------------------------------------------------------
//Arithmetic block
//------------------------------------------------------------------------------------------
case(OpAlu)

			
Addr	:	begin
			B2 = B;//Addr
			A2=A;
			addinL=A2;
			addinR=B2;
			end
Subt	:	begin
			B2 = B;//Subt
			A2=A;
			addinL=A2;
			addinR=twoscompRout;
			end
IncL	:	begin
			B2 = 1;//IncL
			A2=A;
			addinL=A2;
			addinR=B2;
			end
IncR	:	begin
			B2 = B;//IncR
			A2=1;
			addinL=A2;
			addinR=B2;
			end
DecL	:	begin
			B2 = 1;//DecL
			A2=A;
			addinL=A2;
			addinR=twoscompRout;
			end
DecR	:	begin
			B2 = B;//DecR
			A2=1;
			addinL=twoscompLout;
			addinR=B2;
			end
default:	begin
			B2 = B;
			A2=A;
			addinL=A2;
			addinR=B2;
			end
		
endcase


//------------------------------------------------------------------------------------------
//MULTIPLEXER BLOCK
//------------------------------------------------------------------------------------------
case(OpAlu)
Noop	:	begin
			aluout =Noop_signal;
			end
Addr,Subt,
IncL,IncR,DecL,
DecR	:	begin
			aluout=Arith_signal;
			end
/* Subt	:	begin
			aluout=Subt_signal;
			end
IncL	:	begin
			aluout=IncL_signal;
			end
IncR	:	begin
			aluout=IncR_signal;
			end
DecL	:	begin
			aluout=DecL_signal;
			end
DecR	:	begin
			aluout=DecR_signal;
			end */
lAnd	:   begin
			aluout=lAnd_signal;
			end

lOr		:   begin
			aluout=lOr_signal;
			end

lNot	:   begin	
			aluout=lNot_signal;
			end

ShtL	:   begin	
			aluout=ShtL_signal;
			end

RotR	:   begin	
			aluout=RotR_signal;
			end

GoL		:   begin
			aluout=GoL_signal;
			end

GoR		:   begin	
			aluout=GoR_signal;
            end
			
Out0	:   begin		
			aluout=Out0_signal;
            end
			
Out1	:   begin
			aluout=Out1_signal;
		    end
			
default:	begin
			aluout=Arith_signal;
			end
			
		
endcase


end
//------------------------------------------------------------------------------------------
//TWOS COMPLEMENT BLOCKS
//------------------------------------------------------------------------------------------
always@(*)
begin
A2_bar=~(A2);
B2_bar=~(B2);
twoscompLout=A2_bar+{m{1'd1}};
twoscompRout=B2_bar+{m{1'd1}};
end
//------------------------------------------------------------------------------------------
//ADDER BLOCK
//------------------------------------------------------------------------------------------
always@(*)
begin
{Carry_alu_out,Arith_signal}=addinL+addinR+C_flag;
end
//------------------------------------------------------------------------------------------
//OVERFLOW LOGIC 
//------------------------------------------------------------------------------------------
assign Carry_overflow_out=addinL[m-1] ^ addinR[m-1] ^ Carry_alu_out ^ Arith_signal[m-1];

//------------------------------------------------------------------------------------------
//FLAG CONTROL LOGIC
//------------------------------------------------------------------------------------------
always@(*)
begin
//flags updating logic

//ZERO FLAG
if(aluout==0)
Z_update_flag=1;
else
Z_update_flag=Z_flag;

//CARRY FLAG
if(Csh==1 | Carry_alu_out==1)
C_update_flag=1;
else
C_update_flag=C_flag;

//NEGATIVE FLAG

//OVERFLOW FLAG
if(Carry_overflow_out==1)
O_update_flag=1;
else
O_update_flag=O_flag;
end


//------------------------------------------------------------------------------------------
//FLAG REGISTERS
//------------------------------------------------------------------------------------------
always@(posedge clk or negedge reset)
begin
if (!(reset))
begin
C_flag <= 0;
N_flag <= 0;
Z_flag <= 0;
O_flag <= 0;
end
else
begin
C_flag <= C_update_flag;
N_flag <= N_update_flag;
Z_flag <= Z_update_flag;
O_flag <= O_update_flag;
end
end

assign ResBus=aluout;
assign alustat={C_flag,N_flag,Z_flag,O_flag};
endmodule