module count_pixel_frame (
    input               clk                , // Clock
    input               clk_en             , // Clock Enable
    input               rst_n              , // Asynchronous reset active low
    input               hs_i               ,
    input               vs_i               ,
    input               valid_i            ,
    output logic [31:0] count_pixel_frame_o,
    output logic [15:0] count_hs_max_o     ,
    output logic [15:0] count_hs_min_o     ,
    output logic [15:0] count_vs_o
);

logic        vs_ff       ;
logic        hs_ff       ;
logic        valid_ff    ;
logic        drop_vs     ;
logic        drop_hs     ;
logic        drop_hs_vs  ;
logic        ena_hs      ;
logic        ena_vs      ;
logic [15:0] count_vs    ;
logic [15:0] count_hs    ;
logic [15:0] count_hs_max;
logic [15:0] count_hs_min;
logic        w_hs_max    ;
logic        w_hs_min    ;
logic [31:0] count_pixel ;

/*------------------------------------------------------------------------------
--  Shift
------------------------------------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin : proc_vs_ff
    if(~rst_n) begin
        vs_ff <= 0;
    end else if(clk_en) begin
        vs_ff <= vs_i;
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_hs_ff
    if(~rst_n) begin
        hs_ff <= 0;
    end else if(clk_en) begin
        hs_ff <= hs_i;
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_valid_ff
   if(~rst_n) begin
    valid_ff <= 0;
    end else if(clk_en) begin
    valid_ff <= valid_i;
    end
end

assign drop_vs    = ~vs_ff & vs_i;
assign drop_hs    = ~hs_ff & hs_i;
assign drop_hs_vs = ~hs_ff & hs_i & vs_ff;
assign ena_hs     =  hs_ff & valid_ff;
assign ena_vs     =  hs_ff & valid_ff & vs_ff;
/*------------------------------------------------------------------------------
--  Count
------------------------------------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin : proc_count_hs
    if(~rst_n) begin
        count_hs <= '0;
 end else if(clk_en) begin
        if(drop_hs)
            count_hs <= '0;
  else if(ena_hs)
            count_hs <= count_hs + 1'b1;
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_count_vs
    if(~rst_n) begin
        count_vs <= '0;
    end else if(clk_en) begin
        if(drop_vs)
            count_vs <= '0;
        else if(drop_hs_vs)
            count_vs <= count_vs + 1'b1;
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_count_pixel
    if(~rst_n) begin
        count_pixel <= '0;
    end else if(clk_en) begin
         if(drop_vs)
            count_pixel <= '0;
        else if(ena_vs)
            count_pixel <= count_pixel + 1'b1;
    end
end

/*------------------------------------------------------------------------------
--  MIN MAX HS
------------------------------------------------------------------------------*/
assign w_hs_max = (count_hs_max > count_hs);
assign w_hs_min = (count_hs_min > count_hs);
always_ff @(posedge clk or negedge rst_n) begin : proc_count_hs_max
    if(~rst_n) begin
        count_hs_max <= '0;
    end else if(clk_en) begin
        if(drop_vs)
            count_hs_max <= '0;
        else if(drop_hs)
            count_hs_max <= (w_hs_max) ? count_hs_max : count_hs;
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_count_hs_min
    if(~rst_n) begin
        count_hs_min <= '1;
    end else if(clk_en) begin
        if(drop_vs)
            count_hs_min <= '1;
        else if(drop_hs)
            count_hs_min <= (w_hs_min) ? count_hs : count_hs_min;
    end
end

/*------------------------------------------------------------------------------
--  Output Data
------------------------------------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin : proc_count_hs_max_o
    if(~rst_n) begin
        count_hs_max_o <= '0;
    end else if(clk_en) begin
        if(drop_vs) begin
            count_hs_max_o <= count_hs_max;
            $display("COUNT HS MAX = %0d", count_hs_max_o);
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_count_hs_min_o
    if(~rst_n) begin
        count_hs_min_o <= '0;
    end else if(clk_en) begin
        if(drop_vs) begin
            count_hs_min_o <= count_hs_min;
            $display("COUNT HS MIN = %0d", count_hs_min_o);
        end 
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_count_vs_o
    if(~rst_n) begin
        count_vs_o <= '0;
    end else if(clk_en) begin
        if(drop_vs) begin
            count_vs_o <= count_vs + 1'b1; 
            $display("COUNT VS = %0d", count_vs_o);
        end 
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_count_pixel_o
    if(~rst_n) begin
        count_pixel_frame_o <= '0;
    end else if(clk_en) begin
        if(drop_vs) begin
            count_pixel_frame_o <= count_pixel;
            $display("COUNT PIXEL FRAME = %0d", count_pixel_frame_o);
        end
    end
end

endmodule : count_pixel_frame