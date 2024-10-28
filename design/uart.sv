/*
*   �ļ���  ��uart.sv
*   ģ����  ��uart
*   ����    ��Will Chen
*   ����    ��
*           -- 2024.10.27   ��ɴ�����ƣ�δ�������°���֤
*           -- 2024.10.28   ��ɴ��ڻػ��ķ�����֤
*
*   ģ�鹦�� ������ͨ�ţ������ʺ�����λ�����ã�����żУ��
*   
*   ģ����� ��
*           --  CLK_FREQ        �� ʵ���ṩ������ģ���ʱ��Ƶ��
*           --  BAUD_RATE       �� ������
*           --  DATA_WIDTH      �� ����λ�� 
*   
*   ģ��ӿ� ������axi streamЭ��
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
