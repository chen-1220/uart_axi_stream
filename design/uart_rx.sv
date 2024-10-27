module uart_rx #(
    parameter CLK_FREQ      = 50_000_000    ,
    parameter BAUD_RATE     = 9600          ,
    parameter DATA_WIDTH    = 8                 
)(
    input   logic                   clk             ,
    input   logic                   rst             ,
    output  logic [DATA_WIDTH-1:0]  m_axis_tdata    ,
    output  logic                   m_axis_tvalid   ,
    input   logic                   m_axis_tready   ,
    input   logic                   rx_wire         
);

    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    logic   [$clog2(BIT_PERIOD)-1:0]    baud_cnt        ;
    logic   [$clog2(DATA_WIDTH)-1:0]    bit_cnt         ;
    logic                               rx_wire_d0      ;
    logic                               rx_wire_d1      ;
    logic                               rx_flag         ;        //1 : 在接收数据，0：未接收数据
    wire                                rx_wire_posedge ;
    
    //上升沿检测，确定是否准备接收数据
    assign rx_wire_posedge = rx_wire_d0 & (~rx_wire_d1); 
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
            rx_flag <=  rx_wire_posedge? 1'b1 :
                        m_axis_tvalid?   1'b0 : 1'b1;
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

    always_comb begin
        m_axis_tdata    = (bit_cnt == DATA_WIDTH + 1)? rx_data[DATA_WIDTH:1] : '0;
        m_axis_tvalid   = (bit_cnt == DATA_WIDTH + 1)? 1'b1 : 1'b0; 
    end
    
endmodule