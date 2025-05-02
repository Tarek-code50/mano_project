`timescale 1ns / 1ps

module BasicComputer(
    input            clk,           // Clock signal
    output reg [15:0] IR,           // Instruction Register
    output reg [15:0] TR,           // Temporary Register
    output reg [15:0] DR,           // Data Register
    output reg [15:0] AC,           // Accumulator
    output reg [11:0] PC,           // Program Counter
    output reg [11:0] AR,           // Address Register
    output reg [3:0]  timeCount    // Time counter to control execution stages
);

    // Memory: 256 words x 16 bits (addressed from 0 to 255)
    reg [15:0] MEM [0:255];
    reg I;    // Indirect Addressing bit
    reg E;    // Extend (Carry) flip-flop
    reg S;    // Start/Stop flip-flop for controlling operation
    integer i; // Loop variable for initializing memory

    // Initialize memory and registers
    initial begin
        timeCount = 0;    // Initialize time counter
        IR        = 0;    // Initialize Instruction Register
        TR        = 0;    // Initialize Temporary Register
        DR        = 0;    // Initialize Data Register
        AC        = 0;    // Initialize Accumulator
        PC        = 0;    // Initialize Program Counter
        AR        = 0;    // Initialize Address Register
        I         = 0;    // Set Indirect bit to 0
        E         = 0;    // Clear Extend flip-flop
        S         = 1;    // Set Start/Stop flip-flop to start

        // Initialize memory with test instructions and data
        MEM[0]  = 16'h7020;  // INC
        MEM[1]  = 16'h7200;  // CMA
        MEM[2]  = 16'h7040;  // CIL
        MEM[3]  = 16'h7800;  // CLA
        MEM[4]  = 16'h000B;  // AND
        MEM[5]  = 16'h300C;  // STA
        MEM[6]  = 16'h600C;  // ISZ
        MEM[7]  = 16'h0005;  // Data = 5
        MEM[8]  = 16'h0003;  // Data = 3
        MEM[9]  = 16'h0000;  // Output register 1
        MEM[10] = 16'h0000;  // Output register 2
        MEM[11] = 16'h7000;  // HLT (Halt instruction)

        // Initialize remaining memory locations to 0
        for (i = 12; i < 256; i = i + 1)
            MEM[i] = 16'h0000;
    end

    // Fetch-Execute Cycle
    always @(posedge clk) begin
        if (!S) begin
            // If Halt (HLT) instruction is executed, CPU remains stopped
            timeCount <= timeCount;
        end
        else if (timeCount == 0) begin
            // Fetch phase: Fetch instruction from memory
            AR        <= PC;
            timeCount <= 1;
        end
        else if (timeCount == 1) begin
            // Fetch phase: Load instruction into IR and increment PC
            IR        <= MEM[AR];
            PC        <= PC + 1;
            timeCount <= 2;
        end
        else if (timeCount == 2) begin
            // Decode phase: Prepare address and indirect bit
            AR        <= IR[11:0];
            I         <= IR[15];
            timeCount <= 3;
        end
        else begin
            // Register-Reference Instructions (Opcode = 111, I = 0)
            if (IR[14:12] == 3'b111 && I == 0) begin
                casez (AR[11:0])
                    12'b1???????????: begin AC <= 0;                timeCount <= 0; end  // CLA (Clear Accumulator)
                    12'b01??????????: begin E  <= 0;                timeCount <= 0; end  // CLE (Clear Extend)
                    12'b001?????????: begin AC <= ~AC;              timeCount <= 0; end  // CMA (Complement Accumulator)
                    12'b0001????????: begin E  <= ~E;               timeCount <= 0; end  // CME (Complement Extend)
                    12'b00001???????: begin AC <= (AC >> 1); 
                                            AC[15] <= E; 
                                            E      <= AC[0];       timeCount <= 0; end  // CIR (Shift Right Accumulator)
                    12'b000001??????: begin AC <= (AC << 1); 
                                            AC[0]  <= E; 
                                            E      <= AC[15];      timeCount <= 0; end  // CIL (Shift Left Accumulator)
                    12'b0000001?????: begin AC <= AC + 1;           timeCount <= 0; end  // INC (Increment Accumulator)
                    12'b00000001????: begin if (AC[15] == 0) PC <= PC + 1; timeCount <= 0; end // SPA (Skip if Positive Accumulator)
                    12'b000000001???: begin if (AC[15] == 1) PC <= PC + 1; timeCount <= 0; end // SNA (Skip if Negative Accumulator)
                    12'b0000000001??: begin if (AC == 0)     PC <= PC + 1; timeCount <= 0; end // SZA (Skip if Zero Accumulator)
                    12'b00000000001?: begin if (E == 0)      PC <= PC + 1; timeCount <= 0; end // SZE (Skip if Zero Extend)
                    default: begin S <= 0; timeCount <= 0; end // HLT (Halt instruction)
                endcase
            end
            // Memory-Reference Instructions (Opcode != 111)
            else begin
                // Indirect Addressing
                if (I == 1 && timeCount == 3) begin
                    AR        <= MEM[AR]; // Fetch address from memory
                    timeCount <= 4;
                end
                else if (timeCount >= 3) begin
                    case (IR[14:12])
                        3'b000: begin // AND
                            if (timeCount == 4) begin DR <= MEM[AR]; timeCount <= 5; end
                            else             begin AC <= AC & DR; timeCount <= 0; end
                        end
                        3'b001: begin // ADD
                            if (timeCount == 4) begin DR <= MEM[AR]; timeCount <= 5; end
                            else             begin {E, AC} <= AC + DR; timeCount <= 0; end
                        end
                        3'b010: begin // LDA (Load Accumulator)
                            if (timeCount == 4) begin DR <= MEM[AR]; timeCount <= 5; end
                            else             begin AC <= DR; timeCount <= 0; end
                        end
                        3'b011: begin // STA (Store Accumulator)
                            MEM[AR]   <= AC;
                            timeCount <= 0;
                        end
                        3'b100: begin // BUN (Branch Unconditionally)
                            PC        <= AR;
                            timeCount <= 0;
                        end
                        3'b101: begin // BSA (Branch and Save Address)
                            if (timeCount == 4) begin MEM[AR] <= PC; AR <= AR + 1; end
                            else             begin PC <= AR; timeCount <= 0; end
                        end
                        3'b110: begin // ISZ (Increment and Skip if Zero)
                            if      (timeCount == 4) begin DR <= MEM[AR]; timeCount <= 5; end
                            else if (timeCount == 5) begin DR <= DR + 1;    timeCount <= 6; end
                            else begin
                                MEM[AR] <= DR;
                                if (DR == 0) PC <= PC + 1;
                                timeCount <= 0;
                            end
                        end
                        default: timeCount <= 0;
                    endcase
                end
                // Direct Addressing with timeCount == 3
                else if (I == 0 && timeCount == 3) begin
                    timeCount <= 4;
                end
            end
        end
    end

endmodule