`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 11/03/2020 10:18:02 AM
// 
// Module Name: PSM
// 
// Description: The Pause Finite State Machine initiates a pause countdown for 3 
// seconds when activated.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module PSM(clk,reset,pause_tick,pause);
    input clk, reset;
    input pause_tick;
    
    output [1:0] pause;
    
    
    //Count Down FSM States
    parameter P0 = 0;           //no pause
    parameter P3 = 3;           //begin pause (display 3)
    parameter P2 = 2;           //display 2
    parameter P1 = 1;           //display 1
    
    
    reg [1:0] state_reg, state_next;
    reg [31:0] pause_clk, pause_clk_next;
    
    
    
    //1-Tick Buffer
    always @ (posedge clk)
        begin
        if (reset)
            begin
            state_reg <= P3;
            pause_clk <= 0;
            end
        else
            begin
            state_reg <= state_next;
            pause_clk <= pause_clk_next;
            end
        end
    
    
    //State Machine
    always @*
        case (state_reg)
            P3: begin
                if (pause_clk == 100_000_000)       //pause for 1 second in 100MHz clock
                    begin
                    state_next = P2;
                    pause_clk_next = 0;
                    end
                else
                    begin
                    state_next = P3;
                    pause_clk_next = pause_clk + 1;
                    end
                end
                
            P2: begin
                if (pause_clk == 100_000_000)       //pause for 1 second in 100MHz clock
                    begin
                    state_next = P1;
                    pause_clk_next = 0;
                    end
                else
                    begin
                    state_next = P2;
                    pause_clk_next = pause_clk + 1;
                    end
                end
                
            P1: begin
                if (pause_clk == 100_000_000)       //pause for 1 second in 100MHz clock
                    begin
                    state_next = P0;
                    pause_clk_next = 0;
                    end
                else
                    begin
                    state_next = P1;
                    pause_clk_next = pause_clk + 1;
                    end
                end
                
            P0: begin
                if (pause_tick)
                    begin
                    state_next = P3;
                    pause_clk_next = pause_clk + 1;
                    end
                else
                    begin
                    state_next = P0;
                    pause_clk_next = 0;
                    end
                end
                    
            default: begin
                state_next = P0;
                pause_clk_next = 0;
                end
        endcase
    
    
    //output
    assign pause = state_reg;
    
    
endmodule
