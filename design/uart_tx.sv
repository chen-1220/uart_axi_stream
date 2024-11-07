module uart_tx #(
    parameter CLK_FREQ      = 50_000_000    ,
    parameter BAUD_RATE     = 9600          ,
    parameter DATA_WIDTH    = 8             ,
    parameter PARITY        = 0             ,   //0:��У�飬1����У�飬2��żУ�� 
    parameter STOP_BIT      = 1                 //STOP_BIT��ֹͣλ
)(
    input   logic                   clk             ,
    input   logic                   rst             ,
    input   logic [DATA_WIDTH-1:0]  s_axis_tdata    ,
    input   logic                   s_axis_tvalid   ,
    output  logic                   s_axis_tready   ,
    output  logic                   tx_wire         
);

    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;
 
    logic   [$clog2(BIT_PERIOD)-1:0]                                        baud_cnt    ;
    logic   [$clog2(DATA_WIDTH+STOP_BIT+2)-1:0]                             bit_cnt     ;            //bit_cnt����Ϊ����λ+��ʼλ+��żУ��λ+ֹͣλ
    logic   [DATA_WIDTH+STOP_BIT+PARITY[0]+PARITY[1]:0]                     tx_data     ;            //���ڵķ������ݣ�����λ+��ʼλ+��żУ��λ+ֹͣλ
    logic                                                                   tx_finish   ;
    wire                                                                    parity_bit_data = ^s_axis_tdata;
    wire    [STOP_BIT-1:0]                                                  stop_bit_data = '1;

    assign tx_finish = (bit_cnt == DATA_WIDTH + STOP_BIT + PARITY[0] + PARITY[1])&&(baud_cnt == BIT_PERIOD - 1) ? 1'b1 : 1'b0;  //��Ϊ���������������ݿ��Բ��ÿ���λ�����Լ�����DATA_WIDTH+2���ɱ�ʾһ�η��ͽ���
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
           s_axis_tready    <=  1'b1; 
           tx_data          <=  '0;
        end
        else if (s_axis_tvalid&&s_axis_tready) begin        //���ֳɹ�
            s_axis_tready   <=  1'b0;
            if (PARITY == 1) begin  //��У��
                tx_data <= {stop_bit_data,~parity_bit_data,s_axis_tdata,1'b0};               
            end
            else if (PARITY == 2) begin //żУ��
                tx_data <= {stop_bit_data,parity_bit_data,s_axis_tdata,1'b0};              
            end
            else begin //Ĭ�ϲ�У��
                tx_data <= {stop_bit_data,s_axis_tdata,1'b0};              
            end
        end
        else begin
            s_axis_tready   <=  tx_finish?     1'b1 : s_axis_tready;    
            tx_data         <=  (baud_cnt == BIT_PERIOD - 1)?   tx_data >> 1 : tx_data;
        end
    end


    always_ff @( posedge clk or posedge rst ) begin : baud_cnt_logic 
        if (rst) begin
            baud_cnt <= '0;
        end
        else if (!s_axis_tready) begin
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
        else if (!s_axis_tready) begin
            bit_cnt <= (baud_cnt == BIT_PERIOD-1) ? bit_cnt + 1 : bit_cnt;
        end
        else begin
            bit_cnt <= '0;
        end
    end

    always_comb begin : send_data
        tx_wire = s_axis_tready? 1'b1 : tx_data[0];
    end
    
endmodule