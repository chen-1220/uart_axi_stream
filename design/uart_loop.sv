//串口回环：该模块用于上板验证串口功能是否正确
module uart_loop (
    input   logic           clk     ,
    input   logic           rst_n   ,
    input   logic           rx_wire ,
    output  logic           tx_wire    
);

    parameter CLK_FREQ      = 50_000_000    ;
    parameter BAUD_RATE     = 9600          ;
    parameter DATA_WIDTH    = 8             ;   
    parameter ADDR_WIDTH    = 6             ;
    parameter BUFFER_OUT_EN = 0             ;
    wire rst = ~rst_n;
    logic [DATA_WIDTH-1:0]  s_axis_tdata    ;
    logic                   s_axis_tvalid   ;
    logic                   s_axis_tready   ;
    logic [DATA_WIDTH-1:0]  m_axis_tdata    ;
    logic                   m_axis_tvalid   ;
    logic                   m_axis_tready=1 ;
    logic                   full            ;
    logic                   empty           ;

    uart #(
        .CLK_FREQ      (CLK_FREQ   )  ,
        .BAUD_RATE     (BAUD_RATE  )  ,
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
    
    assign s_axis_tvalid = !empty;
    sync_fifo_native #(
        .ADDR_WIDTH        (ADDR_WIDTH    ),
        .DATA_WIDTH        (DATA_WIDTH    ),
        .BUFFER_OUT_EN     (BUFFER_OUT_EN )
    )u_sync_fifo_native(
        .clk     ,
        .rst     ,
        .wr_en      (m_axis_tvalid  ),
        .rd_en      (s_axis_tvalid & s_axis_tready  ),
        .wr_data    (m_axis_tdata   ),
        .rd_data    (s_axis_tdata   ),
        .full   ,
        .empty  
    );
    

endmodule