`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 10/20/2020 07:14:36 PM
// 
// Module Name: top_level
// 
// Description: Top level of 2-Play Pong project.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module top_level(clk,reset,btn_left,btn_right,sw_left,sw_right,rgb,h_sync,v_sync);
    
    input clk, reset;
    input btn_left, btn_right;
    input sw_left, sw_right;
    
    output [11:0] rgb;
    output h_sync, v_sync;    
    
    
    wire left_DEB, right_DEB;
    wire reset_PED, left_PED, right_PED;
    wire [9:0] pixel_x, pixel_y;
    wire p_tick, video_on;
    
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    
    //Debounce
    DEBOUNCE dleft(
        .clk(clk),
        .reset(reset),
        .sig_in(btn_left),
        .sig_out(left_DEB)
        );
        
    DEBOUNCE dright(
        .clk(clk),
        .reset(reset),
        .sig_in(btn_right),
        .sig_out(right_DEB)
        );
    
    
    //VGA Sync
    VGA_SYNC VGA_SYNC(
        .clk(clk),
        .reset(reset),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .video_on(video_on)
        );
    
    
    //Pixel Generation Circuit
    PGC PGC(
        .clk(clk),
        .reset(reset),
        .sw_left(sw_left),
        .sw_right(sw_right),
        .btn_left(left_DEB),
        .btn_right(right_DEB),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on),
        .rgb(rgb_next)
        );
    
    //RGB Buffer
    always @ (posedge clk)
        begin
        if (reset)
            rgb_reg <= 0;
        else
            rgb_reg <= rgb_next;
        end


    assign rgb = rgb_reg;
    
endmodule
