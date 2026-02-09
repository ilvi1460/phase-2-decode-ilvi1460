

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
    // ------------------------------------------------------------
    // Step 1) Extract fixed-position fields (must be assigns)
    // ------------------------------------------------------------
    assign s_id_opc  = s_id_instr[6:0];
    assign s_id_rd   = s_id_instr[11:7];
    assign s_id_fun3 = s_id_instr[14:12];
    assign s_id_rs1  = s_id_instr[19:15];
    assign s_id_rs2  = s_id_instr[24:20];
    assign s_id_fun7 = s_id_instr[31:25];

    // ------------------------------------------------------------
    // Step 1b) Build immediates (sign-extended to 32)
    // ------------------------------------------------------------
    // I-type immediate: instr[31:20]
    assign s_id_immedi = $signed({{20{s_id_instr[31]}}, s_id_instr[31:20]});

    // S-type immediate: instr[31:25] instr[11:7]
    assign s_id_immeds = $signed({{20{s_id_instr[31]}}, s_id_instr[31:25], s_id_instr[11:7]});

    // B-type immediate: instr[31] instr[7] instr[30:25] instr[11:8] 0
    assign s_id_immedb = $signed({{19{s_id_instr[31]}},
                                  s_id_instr[31],
                                  s_id_instr[7],
                                  s_id_instr[30:25],
                                  s_id_instr[11:8],
                                  1'b0});

    // J-type immediate: instr[31] instr[19:12] instr[20] instr[30:21] 0
    assign s_id_immedj = $signed({{11{s_id_instr[31]}},
                                  s_id_instr[31],
                                  s_id_instr[19:12],
                                  s_id_instr[20],
                                  s_id_instr[30:21],
                                  1'b0});

    // U-type immediate: instr[31:12] << 12
    assign s_id_immedu = $signed({s_id_instr[31:12], 12'b0});

    // ------------------------------------------------------------
    // Step 2) Select the "active" immediate based on opcode
    // ------------------------------------------------------------
    always_comb begin
        s_id_immed = 32'sd0;
        case (opc)
            I_TYPE_ALU,
            I_TYPE_LOAD,
            I_TYPE_JUMP,
            I_TYPE_ECALL:  s_id_immed = s_id_immedi;

            S_TYPE:        s_id_immed = s_id_immeds;
            B_TYPE:        s_id_immed = s_id_immedb;
            J_TYPE:        s_id_immed = s_id_immedj;

            U_TYPE_LUI,
            U_TYPE_AUIPC:  s_id_immed = s_id_immedu;

            default:       s_id_immed = 32'sd0;
        endcase
    end

    // ------------------------------------------------------------
    // Step 3) Decode instruction name into instr_string
    // ------------------------------------------------------------
    always_comb begin
        instr_string = "unknown";

        case (opc)

            // ---------------- R-TYPE ----------------
            R_TYPE: begin
                case (s_id_fun3)
                    3'b000: instr_string = (s_id_fun7 == 7'b0100000) ? "sub" :
                                           (s_id_fun7 == 7'b0000000) ? "add" : "unknown";
                    3'b001: instr_string = (s_id_fun7 == 7'b0000000) ? "sll"  : "unknown";
                    3'b010: instr_string = (s_id_fun7 == 7'b0000000) ? "slt"  : "unknown";
                    3'b011: instr_string = (s_id_fun7 == 7'b0000000) ? "sltu" : "unknown";
                    3'b100: instr_string = (s_id_fun7 == 7'b0000000) ? "xor"  : "unknown";
                    3'b101: instr_string = (s_id_fun7 == 7'b0100000) ? "sra"  :
                                           (s_id_fun7 == 7'b0000000) ? "srl"  : "unknown";
                    3'b110: instr_string = (s_id_fun7 == 7'b0000000) ? "or"   : "unknown";
                    3'b111: instr_string = (s_id_fun7 == 7'b0000000) ? "and"  : "unknown";
                    default: instr_string = "unknown";
                endcase
            end

            // -------------- I-TYPE ALU --------------
            I_TYPE_ALU: begin
                case (s_id_fun3)
                    3'b000: instr_string = "addi";
                    3'b010: instr_string = "slti";
                    3'b011: instr_string = "sltiu";
                    3'b100: instr_string = "xori";
                    3'b110: instr_string = "ori";
                    3'b111: instr_string = "andi";
                    3'b001: instr_string = (s_id_fun7 == 7'b0000000) ? "slli" : "unknown";
                    3'b101: instr_string = (s_id_fun7 == 7'b0100000) ? "srai" :
                                           (s_id_fun7 == 7'b0000000) ? "srli" : "unknown";
                    default: instr_string = "unknown";
                endcase
            end

            // -------------- I-TYPE LOAD --------------
            I_TYPE_LOAD: begin
                case (s_id_fun3)
                    3'b000: instr_string = "lb";
                    3'b001: instr_string = "lh";
                    3'b010: instr_string = "lw";
                    3'b100: instr_string = "lbu";
                    3'b101: instr_string = "lhu";
                    default: instr_string = "unknown";
                endcase
            end

            // -------------- I-TYPE JUMP --------------
            I_TYPE_JUMP: begin
                // jalr is identified by opcode=1100111, funct3=000 in RV32I
                instr_string = (s_id_fun3 == 3'b000) ? "jalr" : "unknown";
            end

            // ----------- I-TYPE ECALL/EBREAK ---------
            I_TYPE_ECALL: begin
                // funct3 is 000 for system instructions; imm distinguishes ecall/ebreak
                if (s_id_fun3 == 3'b000) begin
                    if (s_id_instr[31:20] == 12'h000) instr_string = "ecall";
                    else if (s_id_instr[31:20] == 12'h001) instr_string = "ebreak";
                    else instr_string = "system";
                end else begin
                    instr_string = "unknown";
                end
            end

            // ---------------- S-TYPE -----------------
            S_TYPE: begin
                case (s_id_fun3)
                    3'b000: instr_string = "sb";
                    3'b001: instr_string = "sh";
                    3'b010: instr_string = "sw";
                    default: instr_string = "unknown";
                endcase
            end

            // ---------------- B-TYPE -----------------
            B_TYPE: begin
                case (s_id_fun3)
                    3'b000: instr_string = "beq";
                    3'b001: instr_string = "bne";
                    3'b100: instr_string = "blt";
                    3'b101: instr_string = "bge";
                    3'b110: instr_string = "bltu";
                    3'b111: instr_string = "bgeu";
                    default: instr_string = "unknown";
                endcase
            end

            // ---------------- J-TYPE -----------------
            J_TYPE: begin
                instr_string = "jal";
            end

            // ------------- U-TYPE LUI/AUIPC ----------
            U_TYPE_LUI:   instr_string = "lui";
            U_TYPE_AUIPC: instr_string = "auipc";

            default: instr_string = "unknown";
        endcase
    end






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

