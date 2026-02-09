

module cpu (
    input logic clk, 
    input logic reset, 
    input logic [31:0] instruction_data,
    output logic [31:0] instruction_address
    );


    /* ***** SECTION 1: Fetch Stage ***** */


    // Program Counter 
    logic [31:0] pc;
    // Instruction 
    logic [31:0] s_id_instr;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
        end else begin
            pc <= pc + 4; // Increment PC by 4 for next instruction
        end
    end


    // fetch
    // These could be just an assign outside an always_comb block 
    // But, keeping like this to show both examples
    always_comb begin
        // fetch instruction
        instruction_address = pc;
        s_id_instr = instruction_data;
    end


    /* ***** SECTION 2: Decode Stage ***** */


    /**  Provided **/

    // This defined variables for the different fields in the instruction
    // Note: these are not all used for all instructions (e.g., sw does not use rd)
    //       but, you can assign them all based just on their bit positions 
    //       (e.g., rd is always bits 11:7 for those instructions that use it)
    logic[6:0] s_id_opc;
    logic[2:0] s_id_fun3;
    logic[6:0] s_id_fun7;
    logic[4:0] s_id_rd;
    logic[4:0] s_id_rs1;
    logic[4:0] s_id_rs2;
    logic signed [31:0] s_id_immedi;
    logic signed [31:0] s_id_immedb;
    logic signed [31:0] s_id_immeds;
    logic signed [31:0] s_id_immedj;
    logic signed [31:0] s_id_immedu;
    logic signed [31:0] s_id_immed; // this is selected based on the instruction type

    // For the opcode (the 7 least significant bits of the instruction), this defines enumerated type
    // with the different opcodes we will see for different groups of instructions.
    // (the fun3 and fun7 will differentiate specific instructions within those groups)
    typedef enum  logic [6:0] {
        R_TYPE=7'b0110011, 
        I_TYPE_ALU=7'b0010011, 
        I_TYPE_LOAD=7'b0000011, 
        I_TYPE_ECALL=7'b1110011,
        I_TYPE_JUMP=7'b1100111, 
        S_TYPE=7'b0100011,
        B_TYPE=7'b1100011,
        J_TYPE=7'b1101111,
        U_TYPE_LUI=7'b0110111,
        U_TYPE_AUIPC=7'b0010111} opcodes_t;

    // to use this enum in a case statement, convert the logic vector (s_id_opc) to an opcode type
    // you'll assign s_id_opc below based on s_id_instr
    opcodes_t opc;
    assign opc = opcodes_t'(s_id_opc); // convert to type for case statement

    // String to hold instruction name (e.g., "add", "xor", etc.) for printing.  You will assign this in Section 2.
    string instr_string;



    /** ******  Assignment To Do ***** **/





    /* ***** SECTION 3: Print Decoded Instructions ***** */


    // Assign the instruction string based on instruction type for R_TYPE and I_TYPE_ALI instructions 
    // (look at fun3 and fun4)  
    
    always_ff @(posedge reset or posedge clk ) begin : PrintDecodedInstructions
        if (reset) begin
            // Do nothing on reset
        end else begin
            // For R_TYPE 
            // pc=0x0000, instr=0x12345678: add x1, x2, x3  (where those correspond to rd, rs1, rs2) 
            // For I_TYPE_ALU 
            // pc=0x0000, instr=0x12345678: addi x1, x2, 13  (where those correspond to rd, rs1, imm in decimal)
            // Note: %0d prints signed decimal with zero padding. 
            case(opc) 
                R_TYPE:     $display("pc=0x%h, instr=0x%h (R-type):  %s x%0d, x%0d, x%0d", pc, s_id_instr, instr_string, s_id_rd, s_id_rs1, s_id_rs2);
                I_TYPE_ALU: $display("pc=0x%h, instr=0x%h (I-type ALU):  %s x%0d, x%0d, %0d", pc, s_id_instr, instr_string, s_id_rd, s_id_rs1, s_id_immed);
                I_TYPE_LOAD: $display("pc=0x%h, instr=0x%h (I-type LOAD):  %s x%0d, %0d(x%0d)", pc, s_id_instr, instr_string, s_id_rd, s_id_immed, s_id_rs1);
                I_TYPE_JUMP: $display("pc=0x%h, instr=0x%h (I-type JUMP):  %s x%0d, x%0d, 0x%0h", pc, s_id_instr, instr_string, s_id_rd, s_id_rs1, s_id_immed);
                I_TYPE_ECALL: $display("pc=0x%h, instr=0x%h (I-type ECALL/EBREAK):  %s", pc, s_id_instr, instr_string);
                S_TYPE: $display("pc=0x%h, instr=0x%h (S-type):  %s x%0d, %0d(x%0d)", pc, s_id_instr, instr_string, s_id_rs2, s_id_immed, s_id_rs1);
                B_TYPE: $display("pc=0x%h, instr=0x%h (B-type):  %s x%0d, x%0d, 0x%0h", pc, s_id_instr, instr_string, s_id_rs1, s_id_rs2, s_id_immed);
                J_TYPE: $display("pc=0x%h, instr=0x%h (J-type):  %s x%0d, %0h", pc, s_id_instr, instr_string, s_id_rd, s_id_immed);
                U_TYPE_LUI: $display("pc=0x%h, instr=0x%h (U-type LUI):  %s x%0d, 0x%0h", pc, s_id_instr, instr_string, s_id_rd, s_id_immed);
                U_TYPE_AUIPC: $display("pc=0x%h, instr=0x%h (U-type AUIPC):  %s x%0d, 0x%0h", pc, s_id_instr, instr_string, s_id_rd, s_id_immed);
                default:    $display("pc=0x%h, instr=0x%h (other)", pc, s_id_instr); 
            endcase
        end 
    end





endmodule

/*
Some warnings from icarus verilog (that are all fine)
warning: Static variable initialization requires explicit lifetime in this context.
warning: System task ($display) cannot be synthesized in an always_ff process
warning: Assinging to a non-integral variable (instr_string) cannot be synthesized in an always_comb process.
*/

