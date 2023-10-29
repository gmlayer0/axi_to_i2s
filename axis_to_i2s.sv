module axi2_to_i2s (
  input  wire        s_axi_ctrl_aclk   ,
  input  wire        s_axi_ctrl_aresetn,
  input  wire        s_axi_ctrl_awvalid,
  output wire        s_axi_ctrl_awready,
  input  wire [ 7:0] s_axi_ctrl_awaddr ,
  input  wire        s_axi_ctrl_arvalid,
  output reg         s_axi_ctrl_arready,
  input  wire [ 7:0] s_axi_ctrl_araddr ,
  input  wire        s_axi_ctrl_wvalid ,
  output wire        s_axi_ctrl_wready ,
  input  wire [31:0] s_axi_ctrl_wdata  ,
  output wire        s_axi_ctrl_bvalid ,
  input  wire        s_axi_ctrl_bready ,
  output wire [ 1:0] s_axi_ctrl_bresp  ,
  output reg         s_axi_ctrl_rvalid ,
  input  wire        s_axi_ctrl_rready ,
  output reg  [31:0] s_axi_ctrl_rdata  ,
  output wire [ 1:0] s_axi_ctrl_rresp  ,
  output wire        irq               ,
  input  wire        aud_mclk          ,
  input  wire        aud_mrst          ,
  output wire        lrclk_out         ,
  output wire        sclk_out          ,
  output wire        sdata_0_out       ,
  input  wire        s_axis_aud_aclk   ,
  input  wire        s_axis_aud_aresetn,
  input  wire [31:0] s_axis_aud_tdata  ,
  input  wire [ 2:0] s_axis_aud_tid    ,
  input  wire        s_axis_aud_tvalid ,
  output wire        s_axis_aud_tready
);

// Controlling registers
logic [31:0] reg_ver, reg_conf, reg_ctrl, reg_validate, reg_int_ctrl, reg_int_status, reg_timing_ctrl, reg_channel_ctrl;
logic we_ver, we_conf, we_ctrl, we_validate, we_int_ctrl, we_int_status, we_timing_ctrl, we_channel_ctrl;
logic re_ver, re_conf, re_ctrl, re_validate, re_int_ctrl, re_int_status, re_timing_ctrl, re_channel_ctrl;
logic [31:0] wdata_q;
logic [5:0] waddr_q;
logic wvalid_q;

logic [31:0] rdata_d;
logic [5:0] raddr_q;
logic rvalid_q;


// Controlling register reader.
assign s_axi_ctrl_rresp = '0;
always_ff @(posedge s_axi_ctrl_aclk) begin
    if(~s_axi_ctrl_aresetn) begin
        rvalid_q <= '0;
        s_axi_ctrl_rvalid <= '0;
        s_axi_ctrl_arready <= '1;
    end else begin
        if(rvalid_q) begin
            s_axi_ctrl_rvalid <= '1;
            s_axi_ctrl_rdata <= rdata_d;
            if(s_axi_ctrl_rvalid & s_axi_ctrl_rready) begin
                rvalid_q <= '0;
                s_axi_ctrl_rvalid <= '0;
                s_axi_ctrl_arready <= '1;
            end
        end else begin
            if(s_axi_ctrl_arvalid & s_axi_ctrl_arready) begin
                raddr_q <= s_axi_ctrl_araddr[7:2];
                rvalid_q <= '1;
                s_axi_ctrl_rvalid <= '0;
                s_axi_ctrl_arready <= '0;
            end
        end
    end
end
always_comb begin
    case (raddr_q[2:0])
        /*3'd0*/ default: begin
            rdata_d = reg_ver;
        end
        3'd1: begin
            rdata_d = reg_conf;
        end
        3'd2: begin
            rdata_d = reg_ctrl;
        end
        3'd3: begin
            rdata_d = reg_validate;
        end
        3'd4: begin
            rdata_d = reg_int_ctrl;
        end
        3'd5: begin
            rdata_d = reg_int_status;
        end
        3'd6: begin
            rdata_d = reg_timing_ctrl;
        end
        3'd7: begin
            rdata_d = reg_channel_ctrl;
        end
    endcase
    if(raddr_q[5:3]) begin
        rdata_d = '0;
    end
end

// Controlling register writer.


endmodule