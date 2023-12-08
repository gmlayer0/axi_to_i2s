module axi2_to_i2s (
  input  wire        s_axi_ctrl_aclk   ,
  input  wire        s_axi_ctrl_aresetn,
  input  wire        s_axi_ctrl_awvalid,
  output reg         s_axi_ctrl_awready,
  input  wire [ 7:0] s_axi_ctrl_awaddr ,
  input  wire        s_axi_ctrl_arvalid,
  output reg         s_axi_ctrl_arready,
  input  wire [ 7:0] s_axi_ctrl_araddr ,
  input  wire        s_axi_ctrl_wvalid ,
  output reg         s_axi_ctrl_wready ,
  input  wire [31:0] s_axi_ctrl_wdata  ,
  output reg         s_axi_ctrl_bvalid ,
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
  logic        we_ver, we_conf, we_ctrl, we_validate, we_int_ctrl, we_int_status, we_timing_ctrl, we_channel_ctrl;
  logic [31:0] wdata_q ;
  logic [ 5:0] waddr_q ;
  logic        wvalid_q;

  logic [31:0] rdata_d ;
  logic [ 5:0] raddr_q ;
  logic        rvalid_q;

// Controlling registers reader
  assign s_axi_ctrl_rresp = '0;
  always_ff @(posedge s_axi_ctrl_aclk) begin
    if(~s_axi_ctrl_aresetn) begin
      rvalid_q           <= '0;
      s_axi_ctrl_rvalid  <= '0;
      s_axi_ctrl_arready <= '1;
      s_axi_ctrl_rdata <= 'x;
      raddr_q <= 'x;
    end else begin
      if(rvalid_q) begin
        s_axi_ctrl_rvalid <= '1;
        if(!s_axi_ctrl_rvalid) begin
          s_axi_ctrl_rdata <= rdata_d;
        end
        if(s_axi_ctrl_rvalid & s_axi_ctrl_rready) begin
          rvalid_q           <= '0;
          s_axi_ctrl_rvalid  <= '0;
          s_axi_ctrl_arready <= '1;
        end
      end else begin
        if(s_axi_ctrl_arvalid & s_axi_ctrl_arready) begin
          raddr_q            <= s_axi_ctrl_araddr[7:2];
          rvalid_q           <= '1;
          s_axi_ctrl_rvalid  <= '0;
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
      3'd1 : begin
        rdata_d = reg_conf;
      end
      3'd2 : begin
        rdata_d = reg_ctrl;
      end
      3'd3 : begin
        rdata_d = reg_validate;
      end
      3'd4 : begin
        rdata_d = reg_int_ctrl;
      end
      3'd5 : begin
        rdata_d = reg_int_status;
      end
      3'd6 : begin
        rdata_d = reg_timing_ctrl;
      end
      3'd7 : begin
        rdata_d = reg_channel_ctrl;
      end
    endcase
    if(raddr_q[5:3]) begin
      rdata_d = '0;
    end
  end

// Controlling register writer.
  typedef logic[1:0] w_fsm_t;
  w_fsm_t w_fsm_q            ;
  localparam w_fsm_t S_WAIT_ADDR  = 2'd0;
  localparam w_fsm_t S_WAIT_DATA  = 2'd1;
  localparam w_fsm_t S_WAIT_WRITE = 2'd2;
  localparam w_fsm_t S_WAIT_RESP  = 2'd3;

  assign s_axi_ctrl_bresp = '0;
  always_ff@(posedge s_axi_ctrl_aclk) begin
    if(~s_axi_ctrl_aresetn) begin
      w_fsm_q            <= S_WAIT_ADDR;
      wvalid_q           <= '0;
      s_axi_ctrl_awready <= '1;
      s_axi_ctrl_wready  <= '0;
      s_axi_ctrl_bvalid  <= '0;
    end else begin
      case(w_fsm_q)
        /*S_WAIT_ADDR*/ default: begin
          if(s_axi_ctrl_awvalid) begin
            w_fsm_q            <= S_WAIT_DATA;
            waddr_q            <= s_axi_ctrl_awaddr[7:2];
            s_axi_ctrl_awready <= '0;
            s_axi_ctrl_wready  <= '1;
          end
        end
        S_WAIT_DATA : begin
          wdata_q <= s_axi_ctrl_wdata;
          if(s_axi_ctrl_wvalid) begin
            w_fsm_q           <= S_WAIT_WRITE;
            wvalid_q          <= '1;
            s_axi_ctrl_wready <= '0;
          end
        end
        S_WAIT_WRITE : begin
          wvalid_q          <= '0;
          w_fsm_q           <= S_WAIT_RESP;
          s_axi_ctrl_bvalid <= '1;
        end
        S_WAIT_RESP : begin
          if(s_axi_ctrl_bready) begin
            w_fsm_q            <= S_WAIT_ADDR;
            s_axi_ctrl_bvalid  <= '0;
            s_axi_ctrl_awready <= '1;
          end
        end
      endcase
    end
  end


// I2S Generation

endmodule