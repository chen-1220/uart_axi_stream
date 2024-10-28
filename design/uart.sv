/*
*   文件名  ：uart.sv
*   模块名  ：uart
*   作者    ：Will Chen
*   日期    ：
*           -- 2024.10.27   完成代码设计，未仿真与下板验证
*           -- 2024.10.28   完成串口回环的仿真验证
*
*   模块功能 ：串口通信，波特率和数据位可配置，无奇偶校验
*   
*   模块参数 ：
*           --  CLK_FREQ        ： 实际提供给串口模块的时钟频率
*           --  BAUD_RATE       ： 波特率
*           --  DATA_WIDTH      ： 数据位宽 
*   
*   模块接口 ：采用axi stream协议
*
*/
module uart #(
    parameter CLK_FREQ      = 50_000_000    ,
    parameter BAUD_RATE     = 9600          ,
    parameter DATA_WIDTH    = 8                 
)(
    input   logic                   clk             ,
    input   logic                   rst             ,
    input   logic [DATA_WIDTH-1:0]  s_axis_tdata    ,
    input   logic                   s_axis_tvalid   ,
    output  logic                   s_axis_tready   ,
    output  logic [DATA_WIDTH-1:0]  m_axis_tdata    ,
    output  logic                   m_axis_tvalid   ,
    input   logic                   m_axis_tready   ,
    input   logic                   rx_wire         ,
    output  logic                   tx_wire         
);

    uart_rx #(
        .CLK_FREQ      (CLK_FREQ  ),
        .BAUD_RATE     (BAUD_RATE ),
        .DATA_WIDTH    (DATA_WIDTH)    
    )u_uart_rx(
        .clk             ,
        .rst             ,
        .m_axis_tdata    ,
        .m_axis_tvalid   ,
        .m_axis_tready   ,
        .rx_wire         
    );

    uart_tx #(
        .CLK_FREQ      (CLK_FREQ  ),
        .BAUD_RATE     (BAUD_RATE ),
        .DATA_WIDTH    (DATA_WIDTH)    
    )u_uart_tx(
        .clk             ,
        .rst             ,
        .s_axis_tdata    ,
        .s_axis_tvalid   ,
        .s_axis_tready   ,
        .tx_wire         
    );

endmodule
