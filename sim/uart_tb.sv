`timescale 1ns/1ns
module uart_tb;

    parameter DATA_WIDTH = 8;
    parameter CLK_FREQ   = 50_000_000;
    parameter BAUD_RATE  = 115200;

    logic                   clk             ;
    logic                   rst             ;
    logic [DATA_WIDTH-1:0]  s_axis_tdata    ;
    logic                   s_axis_tvalid   ;
    logic                   s_axis_tready   ;
    logic [DATA_WIDTH-1:0]  m_axis_tdata    ;
    logic                   m_axis_tvalid   ;
    logic                   m_axis_tready   = 1'b1;
    logic                   rx_wire         ;
    logic                   tx_wire         ;

    initial begin
        clk = 0 ;
        forever #5 clk = ~clk;      //50MHz
    end

    initial begin
        rst = 1;
        #100
        @(posedge clk)
        rst = 0;
    end

    always_ff @( posedge clk or posedge rst ) begin 
        if (rst) begin
            s_axis_tdata    <=  '0;
            s_axis_tvalid   <=  '0;
        end 
        else begin
            s_axis_tvalid   <=  s_axis_tready? 1'b1 : 1'b0;
            s_axis_tdata    <=  (s_axis_tready&&s_axis_tvalid)? s_axis_tdata + 1 : s_axis_tdata;
        end
    end

    assign  rx_wire = tx_wire;
    uart #(
        .CLK_FREQ      (CLK_FREQ   ),
        .BAUD_RATE     (BAUD_RATE  ),
        .DATA_WIDTH    (DATA_WIDTH )    
    )u_uart(
        .clk             ,
        .rst             ,
        .s_axis_tdata    ,
        .s_axis_tvalid   ,
        .s_axis_tready   ,
        .m_axis_tdata    ,
        .m_axis_tvalid   ,
        .m_axis_tready   ,
        .rx_wire         ,
        .tx_wire         
    );

endmodule