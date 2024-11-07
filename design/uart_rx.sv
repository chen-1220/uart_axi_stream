module uart_rx #(
    parameter CLK_FREQ      = 50_000_000    ,
    parameter BAUD_RATE     = 9600          ,
    parameter DATA_WIDTH    = 8             ,
    parameter PARITY        = 0             ,   //0:��У�飬1����У�飬2��żУ�� 
    parameter STOP_BIT      = 1                 //STOP_BIT��ֹͣλ    
)(
    input   logic                   clk             ,
    input   logic                   rst             ,
    output  logic [DATA_WIDTH-1:0]  m_axis_tdata    ,
    output  logic                   m_axis_tvalid   ,
    input   logic                   m_axis_tready   ,
    output  logic                   frame_error     ,       //1������֡�ṹ����
    output  logic                   parity_error    ,       //1��������żУ�����
    input   logic                   rx_wire         
);

    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    logic   [$clog2(BIT_PERIOD)-1:0]                    baud_cnt        ;
    logic   [$clog2(DATA_WIDTH+STOP_BIT+2)-1:0]         bit_cnt         ;
    logic                                               rx_wire_d0      ;
    logic                                               rx_wire_d1      ;
    logic                                               rx_flag         ;        //1 : �ڽ������ݣ�0��δ��������
    wire                                                rx_wire_negedge ;
    
    //�½��ؼ�⣬ȷ���Ƿ�׼����������
    assign rx_wire_negedge = ~rx_wire_d0 & rx_wire_d1; 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
           rx_wire_d0   <=  '0;
           rx_wire_d1   <=  '0;
        end
        else begin
            rx_wire_d0  <=  rx_wire;
            rx_wire_d1  <=  rx_wire_d0;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            rx_flag <=  1'b0;
        end
        else begin
            rx_flag <=  rx_wire_negedge? 1'b1 :
                        m_axis_tvalid?   1'b0 : rx_flag;        //��⵽�½��ؿ�ʼ�����ź�flag��1���������flag��0
        end 
    end
    

    always_ff @( posedge clk or posedge rst ) begin : baud_cnt_logic 
        if (rst) begin
            baud_cnt <= '0;
        end
        else if (rx_flag) begin
            baud_cnt <= (baud_cnt == BIT_PERIOD-1) ? '0 : baud_cnt + 1;
        end
        else begin
            baud_cnt <= '0;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin : bit_cnt_logic
        if (rst) begin
            bit_cnt <= '0;
        end
        else if (rx_flag) begin
            bit_cnt <= (baud_cnt == BIT_PERIOD-1) ? bit_cnt + 1 : bit_cnt;
        end
        else begin
            bit_cnt <= '0;
        end
    end
    
    logic   [DATA_WIDTH:0]  rx_data;
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
           rx_data  <= '0; 
        end
        else begin
            rx_data[DATA_WIDTH]     <= (baud_cnt == BIT_PERIOD/2 - 1)? rx_wire : rx_data[DATA_WIDTH];
            rx_data[DATA_WIDTH-1:0] <= (baud_cnt == BIT_PERIOD/2 - 1)? rx_data[DATA_WIDTH:1] : rx_data[DATA_WIDTH-1:0];
        end
    end

    logic [DATA_WIDTH-1:0] uart_rx_data;
    logic [STOP_BIT:0] bit_data;            //��У��ʱ0��У��λ��[STOP_BIT:1]��ֹͣλ����У���ʱ��[STOP_BIT-1:0]��ֹͣλ,[STOP_BIT]�ǿ���λ

    //�Ĵ�������ݣ���żУ��λ��ֹͣλ
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            uart_rx_data <= '0;
            bit_data <= '0;
        end  
        else begin
            uart_rx_data <= (bit_cnt == DATA_WIDTH )&&(baud_cnt == BIT_PERIOD/2)? rx_data[DATA_WIDTH:1] : uart_rx_data;
            for (int i=0; i < STOP_BIT + 1;i++) begin
                bit_data[i] <= (bit_cnt == DATA_WIDTH + 1 +i) && (baud_cnt == BIT_PERIOD/2 - 1)? rx_wire : bit_data[i];   
            end
        end
    end
    
    always_comb begin
        if ( ( bit_cnt == DATA_WIDTH + STOP_BIT + PARITY[0] + PARITY[1]) && ( baud_cnt == BIT_PERIOD/2 ) ) begin        //����żУ��ʱPARITY[0] + PARITY[1] = 1
            if (PARITY == 1) begin
                parity_error = ^uart_rx_data == bit_data[0];
                frame_error  = bit_data[STOP_BIT:1] != {STOP_BIT{1'b1}} ? 1'b1 : 1'b0;
            end
            else if (PARITY == 2) begin
                parity_error = ~^uart_rx_data == bit_data[0];
                frame_error  = bit_data[STOP_BIT:1] != {STOP_BIT{1'b1}} ? 1'b1 : 1'b0;
            end
            else begin
                parity_error = 1'b0;
                frame_error  = bit_data[STOP_BIT-1:0] != {STOP_BIT{1'b1}} ? 1'b1 : 1'b0;
            end
            m_axis_tdata = uart_rx_data;
            m_axis_tvalid = 1'b1;
        end
        else begin
            frame_error   = 1'b0;
            parity_error  = 1'b0;
            m_axis_tvalid = 1'b0;
            m_axis_tdata  = '0;
        end
    end


endmodule