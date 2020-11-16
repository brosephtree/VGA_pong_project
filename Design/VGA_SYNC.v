`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Nguyen
// 
// Create Date: 10/22/2020 04:46:12 PM
// 
// Module Name: VGA_SYNC
// 
// Description: The VGA Synchronization module outputs horizontal and vertical 
// synchronization signals to the VGA monitor based on the timing required for 
// VGA mode (640x480 60fps).  Furthermore, it keeps track of the current pixel's 
// coordinates to be used by the Pixel Generation Circuit.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_SYNC(clk, reset, pixel_x, pixel_y, h_sync, v_sync, video_on);
    input clk, reset;
    output [9:0] pixel_x, pixel_y;
    output h_sync, v_sync, video_on;
    
    
    //VGA 640x480 parameters
    parameter HD = 640;         //horizontal display
    parameter HF = 24;          //horizontal front porch (16 --> 24)
    parameter HR = 96;          //horizontal retrace (sync width)
    parameter HB = 40;          //horizontal back porch (48 --> 40)
    parameter VD = 480;
    parameter VF = 10;
    parameter VR = 2;
    parameter VB = 33;
    
    
    //Counters
    reg [9:0] h_reg, h_reg_next;        //horizontal pixel counter
    reg [9:0] v_reg, v_reg_next;        //vertical pixel counter
    
    reg h_sync_reg, v_sync_reg;
    wire h_sync_next, v_sync_next;
    wire h_end, v_end;
   
    reg [1:0] pixel_ctr;
    reg pixel_tick;
    
    //Scanning Flags
    assign h_end = (h_reg == (HD + HF + HR + HB - 1));      //flag to reset h_reg
    assign v_end = (v_reg == (VD + VF + VR + VB - 1));      //flag to reset v_reg
     
    
    
    //Pixel Tick Clock 25MHz
    always @ (posedge clk)
        begin
        if (reset)
            pixel_ctr <= 0;
        else
            pixel_ctr <= pixel_ctr + 1;
        end
            
    
    //Buffer
    always @ (posedge clk, posedge reset)
        begin
        if (reset)
            begin
            h_reg <= 0;
            v_reg <= 0;
            h_sync_reg <= 0;
            v_sync_reg <= 0;
            end
        else
            begin
            h_reg <= h_reg_next;
            v_reg <= v_reg_next;
            h_sync_reg <= h_sync_next;
            v_sync_reg <= v_sync_next;
            end
        end
    
    
    //Update Horizontal Pixel
    always @*
        begin
        if (p_tick)
            begin
            if (h_end)
                h_reg_next = 0;
            else
                h_reg_next = h_reg + 1;
            end
        else
            h_reg_next = h_reg;
        end
     
    // Update Vertical Pixel   
    always @*
        begin
        if (h_end & p_tick)
            begin
            if (v_end)
                v_reg_next = 0;
            else
                v_reg_next = v_reg + 1;
            end
        else
            v_reg_next = v_reg;
        end
    
    
    //HSYNC & VSYNC Signals
    assign h_sync_next = ~((h_reg >= (HD+HF)) && (h_reg < (HD+HF+HR)));  //h_sync low during retrace
    assign v_sync_next = ~((v_reg >= (VD+VF)) && (v_reg < (VD+VF+VR)));  //v_sync low during retrace
    
    
    //output
    assign h_sync = h_sync_reg;
    assign v_sync = v_sync_reg;
    assign pixel_x = h_reg;
    assign pixel_y = v_reg;
    assign p_tick = (pixel_ctr == 0);                               //25MHz
    assign video_on = ((h_reg < HD) && (v_reg < VD));

endmodule
