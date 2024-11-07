/*
*   文件名  ：uart.sv
*   模块名  ：uart
*   作者    ：Will Chen
*   日期    ：
*           -- 2024.10.27   完成代码设计，未仿真与下板验证
*           -- 2024.10.28   完成串口回环的仿真验证
*           -- 2024.11.5    完成uart回环验证：在波特率1000000及以下，误码率小于10^(-5)
*           -- 2024.11.7    支持停止位和奇偶校验，并返回错误信息
*
*   模块功能 ：串口通信，波特率、数据位、奇偶校验位、停止位均可配置
*   
*   模块参数 ：
*           --  CLK_FREQ        ： 实际提供给串口模块的时钟频率
*           --  BAUD_RATE       ： 波特率
*           --  DATA_WIDTH      ： 数据位宽 
*           --  PARITY          ： 奇偶校验
*           --  STOP_BIT        ： 停止位
*   
*   模块接口 ：采用axi stream协议
*
*/
module uart #(
    parameter CLK_FREQ      = 50_000_000    ,
    parameter BAUD_RATE     = 9600          ,
    parameter DATA_WIDTH    = 8             ,
    parameter PARITY        = 0             ,   //0:无校验，1：奇校验，2：偶校验 
    parameter STOP_BIT      = 1                 //STOP_BIT个停止位，1 or 2 
)(
    input   logic                   clk             ,
    input   logic                   rst             ,
    input   logic [DATA_WIDTH-1:0]  s_axis_tdata    ,
    input   logic                   s_axis_tvalid   ,
    output  logic                   s_axis_tready   ,
    output  logic [DATA_WIDTH-1:0]  m_axis_tdata    ,
    output  logic                   m_axis_tvalid   ,
    input   logic                   m_axis_tready   ,
    output  logic                   frame_error     ,       //1：发生帧结构错误
    output  logic                   parity_error    ,       //1：发生奇偶校验错误
    input   logic                   rx_wire         ,
    output  logic                   tx_wire         
);

    uart_rx #(
        .CLK_FREQ      (CLK_FREQ  ),
        .BAUD_RATE     (BAUD_RATE ),
        .DATA_WIDTH    (DATA_WIDTH),
        .PARITY        (PARITY    ),
        .STOP_BIT      (STOP_BIT  )   
    )u_uart_rx(
        .clk             ,
        .rst             ,
        .m_axis_tdata    ,
        .m_axis_tvalid   ,
        .m_axis_tready   ,
        .frame_error     ,
        .parity_error    ,
        .rx_wire         
    );

    uart_tx #(
        .CLK_FREQ      (CLK_FREQ  ),
        .BAUD_RATE     (BAUD_RATE ),
        .DATA_WIDTH    (DATA_WIDTH),    
        .PARITY        (PARITY    ),
        .STOP_BIT      (STOP_BIT  )   
    )u_uart_tx(
        .clk             ,
        .rst             ,
        .s_axis_tdata    ,
        .s_axis_tvalid   ,
        .s_axis_tready   ,
        .tx_wire         
    );

endmodule
