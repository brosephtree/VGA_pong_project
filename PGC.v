`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 10/24/2020 07:15:04 PM
// 
// Module Name: PGC
// 
// Description: The Pixel Generation Circuit determines what color the pixel being 
// expressed by the VGA monitor will be based on whether the pixel coincides with 
// the location of particular objects and text.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module PGC(clk,reset,sw_left,sw_right,btn_left,btn_right,pixel_x,pixel_y,video_on,rgb);
    
    input clk, reset;
    input sw_left, sw_right;
    input btn_left, btn_right;
    input [9:0] pixel_x, pixel_y;
    input video_on;
    
    output reg [11:0] rgb;
    
    
    //Preset Colors
    parameter white = 12'hfff;
    parameter black = 12'h000;
    parameter red = 12'h00f;
    parameter blue = 12'h0f0;
    parameter green = 12'hf00;
    parameter yellow = 12'h0ff;
    parameter cyan = 12'hff0;
    parameter purple = 12'hf02;
    parameter magenta = 12'hf0f;
    parameter orange = 12'h028;
    
    
    wire lp_on, rp_on, ball_on, top_on;
    wire [5:0] score;
    wire [1:0] pause;
    wire text_on;
    
    
    //Object Mapped Scheme
    PONG_OBJECTS PONG_OBJECTS(
        .clk(clk),
        .reset(reset),
        .sw_left(sw_left),
        .sw_right(sw_right),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .score(score),
        .pause(pause),
        .lp_on(lp_on),
        .rp_on(rp_on),
        .ball_on(ball_on),
        .top_on(top_on)
        );
    
    //Tile Mapped Scheme
    TEXT_TILES TEXT_TILES(
        .clk(clk),
        .reset(reset),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .score(score),
        .pause(pause),
        .text_on(text_on)
        );
    
    //RGB Mux
    always @*
        begin
        if (video_on)
            begin
            if (text_on)
                rgb = blue;     //text is blue
            else if (top_on)
                rgb = cyan;     //top is cyan
            else if (ball_on)
                rgb = red;      //ball is red
            else if (lp_on)
                rgb = white;    //paddles are white
            else if (rp_on)
                rgb = white;
            else
                rgb = black;    //background is black
            end
        else
            rgb = black;
        end
     
    
endmodule
