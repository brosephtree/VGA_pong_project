`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 10/25/2020 08:00:44 PM
// 
// Module Name: DEBOUNCE
// 
// Description: The debouncer converts the bouncing waveforms of a button signal
// into a consistent on or off signal.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module DEBOUNCE(clk,reset,sig_in,sig_out);
    input clk, reset;
    input sig_in;
    output sig_out;
    
    parameter deb_clk = 1_000_000 - 1;  
      
    reg [31:0] deb_ctr;
    reg [2:0] deb_tick;
    
    
    always @ (posedge clk)
        begin
        if (reset)
            deb_ctr <= 0;
        else if (deb_ctr == deb_clk)
            deb_ctr <= 0;
        else
            deb_ctr <= deb_ctr + 1;
        end
        
    always @ (posedge clk)
        begin
        if (reset)
            deb_tick <= 3'b000;
        else if (deb_ctr == deb_clk)
            case (deb_tick)
                3'b000: if (sig_in) deb_tick <= 3'b001; else deb_tick <= 3'b000;
                3'b001: if (sig_in) deb_tick <= 3'b011; else deb_tick <= 3'b000;
                3'b011: if (sig_in) deb_tick <= 3'b111; else deb_tick <= 3'b000;
                3'b111: if (~sig_in) deb_tick <= 3'b110; else deb_tick <= 3'b111;
                3'b110: if (~sig_in) deb_tick <= 3'b100; else deb_tick <= 3'b111;
                3'b100: if (~sig_in) deb_tick <= 3'b000; else deb_tick <= 3'b111;
            endcase
        else
            deb_tick <= deb_tick;
        end
        
    assign sig_out = deb_tick[2];
    
endmodule
