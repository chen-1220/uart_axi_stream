/*
*   文件名：sync_fifo_native.sv
*   模块名：sync_fifo_native
*   作者  ：Will Chen
*   日期  ：
*       -- 2024.10.29 完成代码的编写与验证，验证了宏定义的综合结果正确
*
*   模块功能：同步FIFO，可配置数据位宽和深度，以及是否具有输出缓冲、通过宏定义可以配置电路使用BRAM还是LUTRAM资源
*
*   模块参数：
*       -- ADDR_WIDTH   ：数据深度
*       -- DATA_WIDTH   ：数据位宽
*       -- BUFFER_OUT_EN：输出缓冲
*
*   模块接口：native接口，读写使能、读写数据、空满信号
*
*   说明：
*       -- 如果定义USER_BRAM宏，则默认开启输出缓冲，读数据会在读使能的下个时钟周期返回
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
    //使用宏定义来决定使用BRAM还是LUTRAM构建此FIFO，适用Xlinx平台
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

    //fifo写操作逻辑，数据会在写使能有效后一个时钟周期被写入fifo，如果fifo已满则禁止写操作
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

    //fifo读操作逻辑，数据会在读使能有效后一个时钟周期输出，如果fifo空则禁止读操作
    always_ff @( posedge clk or posedge rst ) begin : read_ptr
        if (rst) begin
            rd_ptr <= '0;
        end
        else begin
            rd_ptr <= rd_en && !empty? rd_ptr + 1 : rd_ptr;
        end
    end

    //选择是否使用输出buffer：要想综合成BRAM只能采用时序电路输出，如果综合成LUTRAM，则可以选择组合电路输出
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
        full    = (wr_ptr == {!rd_ptr[ADDR_WIDTH],rd_ptr[ADDR_WIDTH-1:0]}); //|wr_ptr-rd_ptr|=2**ADDR_WIDTH，表示已经写满整个fifo
        empty   = wr_ptr == rd_ptr;
    end

endmodule