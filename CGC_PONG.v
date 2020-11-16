`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 10/31/2020 04:27:09 PM
// 
// Module Name: CGC_PONG
// 
// Description: The Character Generation Circuit contains the location of all the 
// text on the screen, as well as the location of the text saved in the block ROM.  
// The CGC sends a signal to the block ROM to retrieve the appropriate character 
// when the pixel coincides with the tile containing that character.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module CGC_PONG(clk,reset,tile_x,tile_y,score,pause,char_adr);

    input clk, reset;
    input [6:0] tile_x;
    input [5:0] tile_y;
    input [5:0] score;
    input [1:0] pause;
    
    output [6:0] char_adr;
    
    
    //font parameters
    parameter S = 83;
    parameter C = 67;
    parameter O = 79;
    parameter R = 82;
    parameter E = 69;
    parameter COLON = 58;
    parameter DASH = 45;
    parameter BLANK = 0;
    
    parameter ZERO = 48;
    parameter ONE = 49;
    parameter TWO = 50;
    parameter THREE = 51;
    parameter FOUR = 52;
    parameter FIVE = 53;
    parameter SIX = 54;
    parameter SEVEN = 55;
    parameter EIGHT = 56;
    parameter NINE = 57;
    
    parameter A = 65;
    parameter P = 80;
    parameter I = 73;
    parameter N = 78;
    parameter G = 71;
    
    //Count Down FSM States
    parameter P0 = 0;           //no pause
    parameter P3 = 3;           //begin pause (display 3)
    parameter P2 = 2;           //display 2
    parameter P1 = 1;           //display 1
    
    
    //Reg/Wire
    reg [6:0] left_score_reg, right_score_reg;
    reg [6:0] left_score_next, right_score_next;
    reg [6:0] cd_reg, cd_next;
    
    
    //1-Tick Buffer
    always @ (posedge clk, posedge reset)
        begin
        if (reset)
            begin
            left_score_reg <= ZERO;
            right_score_reg <= ZERO;
            cd_reg <= THREE;
            end
        else
            begin
            left_score_reg <= left_score_next;
            right_score_reg <= right_score_next;
            cd_reg <= cd_next;
            end
        end
    
    
    //Update Score
    always @*
        begin
        left_score_next = left_score_reg;
        right_score_next = right_score_reg;
        case (score[5:3])
            3'h0: left_score_next = ZERO;
            3'h1: left_score_next = ONE;
            3'h2: left_score_next = TWO;
            3'h3: left_score_next = THREE;
            3'h4: left_score_next = FOUR;
            3'h5: left_score_next = FIVE;
            3'h6: left_score_next = SIX;
            3'h7: left_score_next = SEVEN;
            default: left_score_next = ZERO;
        endcase
        case (score[2:0])
            3'h0: right_score_next = ZERO;
            3'h1: right_score_next = ONE;
            3'h2: right_score_next = TWO;
            3'h3: right_score_next = THREE;
            3'h4: right_score_next = FOUR;
            3'h5: right_score_next = FIVE;
            3'h6: right_score_next = SIX;
            3'h7: right_score_next = SEVEN;
            default: right_score_next = ZERO;
        endcase
        end
    
    //Update Pause Countdown
    always @*
        case (pause)
            P3: cd_next = THREE;
            P2: cd_next = TWO;
            P1: cd_next = ONE;
            P0: cd_next = BLANK;
            default: cd_next = BLANK;
        endcase
    
    //output
    //note screen is 80x30 tiles
    assign char_adr =   ((tile_x == 33) && (tile_y == 1)) ? P:              //game title 
                        ((tile_x == 34) && (tile_y == 1)) ? I:
                        ((tile_x == 35) && (tile_y == 1)) ? N:
                        ((tile_x == 36) && (tile_y == 1)) ? G:
                        ((tile_x == 37) && (tile_y == 1)) ? DASH:
                        ((tile_x == 38) && (tile_y == 1)) ? P:
                        ((tile_x == 39) && (tile_y == 1)) ? O:
                        ((tile_x == 40) && (tile_y == 1)) ? N:
                        ((tile_x == 41) && (tile_y == 1)) ? G:
                        
                        ((tile_x == 1) && (tile_y == 1)) ? S:               //left scoreboard
                        ((tile_x == 2) && (tile_y == 1)) ? C:
                        ((tile_x == 3) && (tile_y == 1)) ? O:
                        ((tile_x == 4) && (tile_y == 1)) ? R:
                        ((tile_x == 5) && (tile_y == 1)) ? E:
                        ((tile_x == 6) && (tile_y == 1)) ? COLON:
                        ((tile_x == 7) && (tile_y == 1)) ? left_score_reg:
                        
                        ((tile_x == 72) && (tile_y == 1)) ? S:              //right scoreboard
                        ((tile_x == 73) && (tile_y == 1)) ? C:
                        ((tile_x == 74) && (tile_y == 1)) ? O:
                        ((tile_x == 75) && (tile_y == 1)) ? R:
                        ((tile_x == 76) && (tile_y == 1)) ? E:
                        ((tile_x == 77) && (tile_y == 1)) ? COLON:
                        ((tile_x == 78) && (tile_y == 1)) ? right_score_reg:
                        
                        ((tile_x == 35) && (tile_y == 15)) ? cd_reg:        //pause countdown
                        ((tile_x == 44) && (tile_y == 15)) ? cd_reg:
                        
                        BLANK;
    
    
    
    
endmodule
