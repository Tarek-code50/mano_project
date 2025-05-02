`timescale 1ns / 1ps

module BasicComputer_tb;

    reg           clk;
    wire [15:0]   IR;
    wire [15:0]   TR;
    wire [15:0]   DR;
    wire [15:0]   AC;
    wire [11:0]   PC;
    wire [11:0]   AR;
    wire [3:0]    timeCount;

    BasicComputer uut (
        .clk       (clk),
        .IR        (IR),
        .TR        (TR),
        .DR        (DR),
        .AC        (AC),
        .PC        (PC),
        .AR        (AR),
        .timeCount (timeCount)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        #5;
        $display("Time   PC   IR    DR    AC    AR   TC");
        $display("----   --   --    --    --    --   --");
        repeat (20) begin
            @(posedge clk);
            $display("%4dns  %h   %h   %h   %h   %h   %0d",
                     $time, PC, IR, DR, AC, AR, timeCount);
        end
        $display("\n--- Simulation Complete ---");
        $finish;
    end

    initial begin
        $dumpfile("BasicComputer_tb.vcd");
        $dumpvars(0, BasicComputer_tb);
    end

endmodule