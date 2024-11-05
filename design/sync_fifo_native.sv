/*
*   �ļ�����sync_fifo_native.sv
*   ģ������sync_fifo_native
*   ����  ��Will Chen
*   ����  ��
*       -- 2024.10.29 ��ɴ���ı�д����֤����֤�˺궨����ۺϽ����ȷ
*
*   ģ�鹦�ܣ�ͬ��FIFO������������λ�����ȣ��Լ��Ƿ����������塢ͨ���궨��������õ�·ʹ��BRAM����LUTRAM��Դ
*
*   ģ�������
*       -- ADDR_WIDTH   ���������
*       -- DATA_WIDTH   ������λ��
*       -- BUFFER_OUT_EN���������
*
*   ģ��ӿڣ�native�ӿڣ���дʹ�ܡ���д���ݡ������ź�
*
*   ˵����
*       -- �������USER_BRAM�꣬��Ĭ�Ͽ���������壬�����ݻ��ڶ�ʹ�ܵ��¸�ʱ�����ڷ���
*/
//`define USER_BRAM
module sync_fifo_native #(
    parameter ADDR_WIDTH    = 8,
    parameter DATA_WIDTH    = 8,
    parameter BUFFER_OUT_EN = 1
)(
    input   logic                       clk     ,
    input   logic                       rst     ,
    input   logic                       wr_en   ,
    input   logic                       rd_en   ,
    input   logic   [DATA_WIDTH-1:0]    wr_data ,
    output  logic   [DATA_WIDTH-1:0]    rd_data ,
    output  logic                       full    ,
    output  logic                       empty
);
    //ʹ�ú궨��������ʹ��BRAM����LUTRAM������FIFO������Xlinxƽ̨
    `ifdef USER_BRAM 
        (* ram_style = "block" *) 
        logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0] = '{default:0};
    `else 
        (* ram_style = "distributed" *)
        logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0] = '{default:0};
    `endif
    logic [ADDR_WIDTH:0]    wr_ptr;
    logic [ADDR_WIDTH:0]    rd_ptr;
    logic [DATA_WIDTH-1:0]  rd_data_r;

    //fifoд�����߼������ݻ���дʹ����Ч��һ��ʱ�����ڱ�д��fifo�����fifo�������ֹд����
    always_ff @( posedge clk or posedge rst ) begin : write_ptr
        if (rst) begin
            wr_ptr <= '0;
        end  
        else if (wr_en && !full) begin
            wr_ptr <= wr_ptr + 1;
        end
        else begin
            wr_ptr <= wr_ptr;
        end
    end
    
    always_ff @( posedge clk ) begin : write_data
        if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
        end
    end

    //fifo�������߼������ݻ��ڶ�ʹ����Ч��һ��ʱ��������������fifo�����ֹ������
    always_ff @( posedge clk or posedge rst ) begin : read_ptr
        if (rst) begin
            rd_ptr <= '0;
        end
        else begin
            rd_ptr <= rd_en && !empty? rd_ptr + 1 : rd_ptr;
        end
    end

    //ѡ���Ƿ�ʹ�����buffer��Ҫ���ۺϳ�BRAMֻ�ܲ���ʱ���·���������ۺϳ�LUTRAM�������ѡ����ϵ�·���
    `ifdef USER_BRAM
        always_ff @( posedge clk) begin : read_data
            rd_data_r <= rd_en && !empty? mem[rd_ptr[ADDR_WIDTH-1:0]] : '0;
        end
    `else
        generate
            if (BUFFER_OUT_EN) begin
                always_ff @( posedge clk or posedge rst ) begin : read
                    if (rst) begin
                        rd_data_r <= '0;
                    end
                    else begin
                        rd_data_r <= rd_en && !empty? mem[rd_ptr[ADDR_WIDTH-1:0]] : '0;
                    end
                end
            end
            else begin
                assign rd_data_r = rd_en && !empty? mem[rd_ptr[ADDR_WIDTH-1:0]] : '0;
            end
        endgenerate
    `endif

    always_comb begin : comb_out
        rd_data = rd_data_r;
        full    = (wr_ptr == {!rd_ptr[ADDR_WIDTH],rd_ptr[ADDR_WIDTH-1:0]}); //|wr_ptr-rd_ptr|=2**ADDR_WIDTH����ʾ�Ѿ�д������fifo
        empty   = wr_ptr == rd_ptr;
    end

endmodule