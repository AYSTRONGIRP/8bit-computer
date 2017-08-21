module cpu_control(
  input wire [3:0] opcode,
  input wire [3:0] cycle,
  input wire eq_zero,
  output reg [3:0] state
);

  `include "parameters.v"

  always @ (cycle) begin
    case (cycle)
      0: state = `STATE_FETCH_PC;
      1: state = `STATE_FETCH_INST;
      2: begin
        if (opcode == `OP_HLT)
          state = `STATE_HALT;
        else if (opcode == `OP_OUT)
          state = `STATE_OUT_A;
        else
          state = `STATE_FETCH_PC;
      end
      3: begin
        if (opcode == `OP_HLT || opcode == `OP_OUT)
          state = `STATE_NEXT;
        else if (opcode == `OP_JEZ && !eq_zero || opcode == `OP_JNZ && eq_zero)
          state = `STATE_SKIP_JUMP;
        else if (opcode == `OP_JMP || opcode == `OP_JEZ && eq_zero || opcode == `OP_JNZ && !eq_zero)
          state = `STATE_JUMP;
        else
          state = `STATE_LOAD_ADDR;
      end
      4: state = (opcode == `OP_JEZ || opcode == `OP_JNZ) ? `STATE_NEXT :
                 (opcode == `OP_LDA) ? `STATE_RAM_A :
                 (opcode == `OP_STA) ? `STATE_STORE_A : `STATE_RAM_B;
      5: state = (opcode == `OP_LDA) ? `STATE_NEXT : (opcode == `OP_ADD) ? `STATE_ADD : `STATE_SUB;
      6: state = `STATE_NEXT;
      default: $display("Cannot decode : cycle = %d, opcode = %h", cycle, opcode);
    endcase
  end

endmodule
