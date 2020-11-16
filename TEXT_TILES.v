`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 10/31/2020 01:57:50 PM
// 
// Module Name: TEXT_TILES
// 
// Description: This module outputs the text flag when the pixel coincides with a 
// letter.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module TEXT_TILES(clk,reset,pixel_x,pixel_y,score,pause,text_on);
    input clk, reset;
    input [9:0] pixel_x, pixel_y;
    input [5:0] score;
    input [1:0] pause;
    
    output text_on;



    wire [9:0] px_real, py_real;
    wire [6:0] char_adr;
    wire [7:0] font_word;


    //Correct bit value of pixel x and y
    assign px_real = pixel_x - 1;
    assign py_real = pixel_y - 1;
    
    
    //Character Generation Circuit
    CGC_PONG CGC_PONG(
        .clk(clk),
        .reset(reset),
        .tile_x(px_real[9:3]),
        .tile_y(py_real[9:4]),
        .score(score),
        .pause(pause),
        .char_adr(char_adr)
        );
    

    //ROM containing fonts
    font_rom font_rom(
        .clka(clk),
        .addra({char_adr, py_real[3:0]}),       //11 bits
        .douta(font_word)                       //8 bits; font word is reversed
        );

    //output
    assign text_on = font_word[(3'h7 - px_real[2:0] + 1)];   //text on when corresponding pixel in font word is high; shifted right 1 pixel to account for ROM retrieval delay

endmodule
