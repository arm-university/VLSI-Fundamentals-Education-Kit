module A2O1_1X(A,B,C,Y);
	input	A,B,C;
	output	Y;
	or(Y,C,_n1);
	and(_n1,A,B);
endmodule

module AND2_1X(A,B,Y);
	input	A,B;
	output	Y;
	and(Y,A,B);
endmodule

module FULLADDER(A,B,C,COUT,S);
	input	A,B,C;
	output	COUT,S;
	xor(S,A,B,C);
	maj(COUT,A,B,C);
endmodule

module INV_1X(A,Y);
	input	A;
	output	Y;
	not(Y,A);
endmodule

module INV_2X(A,Y);
	input	A;
	output	Y;
	not(Y,A);
endmodule

module INV_4X(A,Y);
	input	A;
	output	Y;
	not(Y,A);
endmodule

module INV_8X(A,Y);
	input	A;
	output	Y;
	not(Y,A);
endmodule

module LATCH_C_1X(D,PH,Q);
	input	D,PH;
	output	Q;
	mux(Q,PH,D,Q);
endmodule

module MUX2_C_1X(D0,D1,S,Y);
	input	D0,D1,S;
	output	Y;
	mux(Y,S,D1,D0);
endmodule

module NAND2_1X(A,B,Y);
	input	A,B;
	output	Y;
	nand(Y,A,B);
endmodule

module NAND2_2X(A,B,Y);
	input	A,B;
	output	Y;
	nand(Y,A,B);
endmodule

module NAND3_1X(A,B,C,Y);
	input	A,B,C;
	output	Y;
	nand(Y,A,B,C);
endmodule

module NOR2_1X(A,B,Y);
	input	A,B;
	output	Y;
	nor(Y,A,B);
endmodule

module NOR2_2X(A,B,Y);
	input	A,B;
	output	Y;
	nor(Y,A,B);
endmodule

module NOR3_1X(A,B,C,Y);
	input	A,B,C;
	output	Y;
	nor(Y,A,B,C);
endmodule

module OR2_1X(A,B,Y);
	input	A,B;
	output	Y;
	or(Y,A,B);
endmodule

primitive mux(Y,S,A,B);
	output	Y;
	input	S,A,B;
	table	1 1 ? : 1;
		1 0 ? : 0;
		0 ? 1 : 1;
		0 ? 0 : 0;
		? 1 1 : 1;
		? 0 0 : 0;
	endtable
endprimitive

primitive maj(Y,A,B,C);
	output	Y;
	input	A,B,C;
	table	1 1 ? : 1;
		1 ? 1 : 1;
		? 1 1 : 1;
		0 0 ? : 0;
		0 ? 0 : 0;
		? 0 0 : 0;
	endtable
endprimitive

