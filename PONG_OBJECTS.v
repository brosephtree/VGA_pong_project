`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 10/31/2020 01:02:51 PM
// 
// Module Name: PONG_OBJECTS
// 
// Description: This module maintains and updates the location of the left and 
// right paddles, ball, and top wall, outputting the proper flag when the pixel 
// coincides with the respective object.  Furthermore, this module keeps track of 
// the score, and pauses the ball briefly after each point.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module PONG_OBJECTS(clk,reset,sw_left,sw_right,btn_left,btn_right,pixel_x,pixel_y,score,pause,lp_on,rp_on,ball_on,top_on);
    input clk, reset;
    input sw_left, sw_right;
    input btn_left, btn_right;
    input [9:0] pixel_x, pixel_y;
    
    output [5:0] score;
    output [1:0] pause;
    output lp_on, rp_on, ball_on, top_on;
    
    
    parameter CLK_FRQ = 100 * 10**6;    //100MHz
    
    parameter HD = 640;         //horizontal display
    parameter VD = 480;         //vertical display
    
    //Object Parameters
    parameter PW = 10;          //paddle width
    parameter PH = 100;         //paddle height
    parameter BD = 10;          //ball diameter
    parameter LP = 60;          //left paddle left face
    parameter RP = 570;         //right paddle left face
    
    parameter PS = 2;           //paddle speed
    parameter BSH = 1;          //ball speed horizontal
    parameter BSV = 1;          //ball speed vertical
    
    parameter TOP = 33;         //top bar location
    parameter TOPT = 3;         //top bar thickness
    
    //Count Down FSM States
    parameter P0 = 0;           //no pause
    parameter P3 = 1;           //begin pause (display 3)
    parameter P2 = 2;           //display 2
    parameter P1 = 3;           //display 1
    
    
    //Declarations
    reg [9:0] left_pad_y, right_pad_y;
    reg [9:0] left_pad_y_next, right_pad_y_next;
    reg [9:0] ball_x, ball_x_next, ball_y, ball_y_next;
    reg [9:0] ball_vel_x, ball_vel_x_next;
    reg [9:0] ball_vel_y, ball_vel_y_next;
    wire [9:0] ball_up, ball_down, ball_left, ball_right;
    wire ball_sq_on;
    reg [5:0] score_reg, score_next;
    
    reg pause_tick, pause_next;
    
    wire [9:0] LPL, LPR, LPT, LPB;          //edges of left paddle
    wire [9:0] RPL, RPR, RPT, RPB;          //edges of right paddle
    wire [9:0] BL, BR, BT, BB;              //edges of square ball
    
    wire refr_tick;                         //flag to update objects
    
    wire [4:0] round_x, round_y;
    reg [(BD-1):0] round_row;
    
    
    //Object Specs
    assign LPL = LP-1;
    assign LPR = LP+PW-1;
    assign LPT = left_pad_y;
    assign LPB = left_pad_y+PH;
    assign RPL = RP-1;
    assign RPR = RP+PW-1;
    assign RPT = right_pad_y;
    assign RPB = right_pad_y+PH;
    assign BL = ball_x;
    assign BR = ball_x+BD;
    assign BT = ball_y;
    assign BB = ball_y+BD;
    
    assign ball_up = -BSV;
    assign ball_down = BSV;
    assign ball_left = -BSH;
    assign ball_right = BSH;
    
    
    //1-Tick Buffer
    always @ (posedge clk, posedge reset)
        begin
        if (reset)
            begin;
            left_pad_y <= (VD/2 - 1) - (PH/2);
            right_pad_y <= (VD/2 - 1) - (PH/2);
            ball_x <= (HD/2 - 1) - (BD/2);
            ball_y <= (VD/2 - 1) - (BD/2);
            ball_vel_x <= ball_right;
            ball_vel_y <= ball_up;
            score_reg <= 0;
            pause_tick <= 1;
            end
        else
            begin
            left_pad_y <= left_pad_y_next;
            right_pad_y <= right_pad_y_next;
            ball_x <= ball_x_next;
            ball_y <= ball_y_next;
            ball_vel_x <= ball_vel_x_next;
            ball_vel_y <= ball_vel_y_next;
            score_reg <= score_next;
            pause_tick <= pause_next;
            end
        end
        
    
    //Update Objects
    assign refr_tick = (pixel_x == 0) && (pixel_y == VD);
    
    //Update Left Paddle
    always @*
        begin
        left_pad_y_next = left_pad_y;                           
        if (refr_tick)
            begin
            if (sw_left && btn_left && (LPT >= (TOP + TOPT + PS)))
                left_pad_y_next = left_pad_y - PS;                      //move up
            else if (~sw_left && btn_left && (LPB <= (VD - PS - 1)))
                left_pad_y_next = left_pad_y + PS;                      //move down
            else
                left_pad_y_next = left_pad_y;
            end
        end
    
    //Update Right Paddle
    always @*
        begin
        right_pad_y_next = right_pad_y;                           
        if (refr_tick)
            begin
            if (sw_right && btn_right && (RPT >= (TOP + TOPT + PS)))
                right_pad_y_next = right_pad_y - PS;                      //move up
            else if (~sw_right && btn_right && (RPB <= (VD - PS - 1)))
                right_pad_y_next = right_pad_y + PS;                      //move down
            else
                right_pad_y_next = right_pad_y;
            end
        end
    
    //Update Ball Position
    always @*
        begin
        score_next = score_reg;
        ball_x_next = ball_x;
        ball_y_next = ball_y;
        pause_next = pause_tick;
        if (refr_tick)
            begin
            if (BL < BSH)                                   //ball hits left edge
                begin
                score_next = score_reg + 6'b00001;          //right scores
                ball_x_next = (HD/2 - 1) - (BD/2);          //reset ball
                ball_y_next = (VD/2 - 1) - (BD/2);
                pause_next = 1;                             //begin pause
                end
            else if ((HD - BSH - 1) < BR)                   //ball hits right edge
                begin
                score_next = score_reg + 6'b001000;         //left scores
                ball_x_next = (HD/2 - 1) - (BD/2);          //reset ball
                ball_y_next = (VD/2 - 1) - (BD/2);
                pause_next = 1;                             //begin pause
                end
            else                                            //otherwise, ball continues trajectory
                begin
                score_next = score_reg;
                pause_next = 0;
                if (pause != 2'b00)                         //ball does not move during pause
                    begin
                    ball_x_next = ball_x;
                    ball_y_next = ball_y;
                    end
                else
                    begin
                    ball_x_next = ball_x + ball_vel_x;
                    ball_y_next = ball_y + ball_vel_y;
                    end
                end
            end
        end
    
    //Update Ball Velocity
    always @*
        begin
        ball_vel_x_next = ball_vel_x;
        ball_vel_y_next = ball_vel_y;
        if (BT < (TOP + TOPT))                          //ball hits top
            ball_vel_y_next = ball_down;
        else if (BB > (VD - BSV - 1))                   //ball hits bottom
            ball_vel_y_next = ball_up;
        else if ((BT >= LPT) && (BB <= LPB) && (BL <= LPR) && (BL >= LPL))      //ball hits left paddle
            ball_vel_x_next = ball_right;
        else if ((BT >= RPT) && (BB <= RPB) && (BR >= RPL) && (BR <= RPR))      //ball hits right paddle
            ball_vel_x_next = ball_left;
        else
            begin
            ball_vel_x_next = ball_vel_x;
            ball_vel_y_next = ball_vel_y;
            end
        end
    
    
    //Object Recognition
    assign lp_on = ((LPL < pixel_x) && (pixel_x <= LPR) && (LPT < pixel_y) && (pixel_y <= LPB)) ? 1'b1 : 1'b0;
    assign rp_on = ((RPL < pixel_x) && (pixel_x <= RPR) && (RPT < pixel_y) && (pixel_y <= RPB)) ? 1'b1 : 1'b0;
    assign ball_sq_on = ((BL < pixel_x) && (pixel_x <= BR) && (BT < pixel_y) && (pixel_y <= BB)) ? 1'b1 : 1'b0;
    assign top_on = ((TOP < pixel_y) && (pixel_y <= (TOP + TOPT))) ? 1'b1 : 1'b0;
    
    //Round Ball
    assign round_x = pixel_x - BL - 1;
    assign round_y = pixel_y - BT - 1;
    assign ball_on = round_row[round_x] && ball_sq_on;
    
    always @*
        begin
        if (ball_sq_on)
            case (round_y)
                5'h0: round_row = 10'b0001111000;
                5'h1: round_row = 10'b0111111110;
                5'h2: round_row = 10'b0111111110;
                5'h3: round_row = 10'b1111111111;
                5'h4: round_row = 10'b1111111111;
                5'h5: round_row = 10'b1111111111;
                5'h6: round_row = 10'b1111111111;
                5'h7: round_row = 10'b0111111110;
                5'h8: round_row = 10'b0111111110;
                5'h9: round_row = 10'b0001111000;
                default: round_row = 10'b1111111111;
            endcase
        else
            round_row = 0;
        end
    
    
    //Pause FSM
    PSM PSM(
        .clk(clk),
        .reset(reset),
        .pause_tick(pause_tick),
        .pause(pause)
        );
    
    
    //Output
    assign score = score_reg;
    
endmodule
