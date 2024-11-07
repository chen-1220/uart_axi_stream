/*
*   �ļ���  ��uart.sv
*   ģ����  ��uart
*   ����    ��Will Chen
*   ����    ��
*           -- 2024.10.27   ��ɴ�����ƣ�δ�������°���֤
*           -- 2024.10.28   ��ɴ��ڻػ��ķ�����֤
*           -- 2024.11.5    ���uart�ػ���֤���ڲ�����1000000�����£�������С��10^(-5)
*           -- 2024.11.7    ֧��ֹͣλ����żУ�飬�����ش�����Ϣ
*
*   ģ�鹦�� ������ͨ�ţ������ʡ�����λ����żУ��λ��ֹͣλ��������
*   
*   ģ����� ��
*           --  CLK_FREQ        �� ʵ���ṩ������ģ���ʱ��Ƶ��
*           --  BAUD_RATE       �� ������
*           --  DATA_WIDTH      �� ����λ�� 
*           --  PARITY          �� ��żУ��
*           --  STOP_BIT        �� ֹͣλ
*   
*   ģ��ӿ� ������axi streamЭ��
*
*/
module uart #(
    parameter CLK_FREQ      = 50_000_000    ,
    parameter BAUD_RATE     = 9600          ,
    parameter DATA_WIDTH    = 8             ,
    parameter PARITY        = 0             ,   //0:��У�飬1����У�飬2��żУ�� 
    parameter STOP_BIT      = 1                 //STOP_BIT��ֹͣλ��1 or 2 
)(
    input   logic                   clk             ,
    input   logic                   rst             ,
    input   logic [DATA_WIDTH-1:0]  s_axis_tdata    ,
    input   logic                   s_axis_tvalid   ,
    output  logic                   s_axis_tready   ,
    output  logic [DATA_WIDTH-1:0]  m_axis_tdata    ,
    output  logic                   m_axis_tvalid   ,
    input   logic                   m_axis_tready   ,
    output  logic                   frame_error     ,       //1������֡�ṹ����
    output  logic                   parity_error    ,       //1��������żУ�����
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
