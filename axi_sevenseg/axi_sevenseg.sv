// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: Wrapper for ETHMAC instantiation
// Comments:
//
//********************************************************************************

//`default_nettype none
module axi_sevenseg_wrapper
  #(parameter ID_WIDTH = 1) /*FIXME: Parameter */
  (
   input wire 		     clk,
   input wire 		     rst_n,

   // AXI Slave interface, 64 bit data
   // AW
   input wire [ID_WIDTH-1:0] i_awid,
   input wire [11:0] 	     i_awaddr,
   input wire [7:0] 	     i_awlen,
   input wire [2:0] 	     i_awsize,
   input wire [1:0] 	     i_awburst,
   input wire 		     i_awvalid,
   output wire 		     o_awready,
   // AR
   input wire [ID_WIDTH-1:0] i_arid,
   input wire [11:0] 	     i_araddr,
   input wire [7:0] 	     i_arlen,
   input wire [2:0] 	     i_arsize,
   input wire [1:0] 	     i_arburst,
   input wire 		     i_arvalid,
   output wire 		     o_arready,
   // W
   input wire [63:0] 	     i_wdata,
   input wire [7:0] 	     i_wstrb,
   input wire 		     i_wlast,
   input wire 		     i_wvalid,
   output wire 		     o_wready,
   // B
   output reg [ID_WIDTH-1:0] o_bid,
   output wire [1:0] 	     o_bresp,
   output wire 		     o_bvalid,
   input wire 		     i_bready,
   // R
   output reg [ID_WIDTH-1:0] o_rid,
   output wire [63:0] 	     o_rdata,
   output wire [1:0] 	     o_rresp,
   output wire 		     o_rlast,
   output wire 		     o_rvalid,
   input wire 		     i_rready,

   // Sevensegment signals
   output wire [6:0] 	     o_ca,
   output wire [7:0] 	     o_an);

   always @(posedge clk)
     if (i_awvalid & o_awready)
       o_bid <= i_awid;

   always @(posedge clk)
     if (i_arvalid & o_arready)
       o_rid <= i_arid;

   wire [31:0] 		      wbs_sevenseg_dat;
   wire [3:0] 		      wbs_sevenseg_sel;
   wire 		      wbs_sevenseg_we;
   wire 		      wbs_sevenseg_cyc;
   wire 		      wbs_sevenseg_stb;
   wire [31:0] 		      wbs_sevenseg_rdt;
   wire 		      wbs_sevenseg_ack;

    axi2wb csrbridge
     (
      .i_clk (clk),
      .i_rst (~rst_n),
      .o_wb_adr     (),
      .o_wb_dat     (wbs_sevenseg_dat),
      .o_wb_sel     (wbs_sevenseg_sel),
      .o_wb_we      (wbs_sevenseg_we),
      .o_wb_cyc     (wbs_sevenseg_cyc),
      .o_wb_stb     (wbs_sevenseg_stb),
      .i_wb_rdt     (wbs_sevenseg_rdt),
      .i_wb_ack     (wbs_sevenseg_ack),
      .i_wb_err     (1'b0),

      .i_awaddr     (i_awaddr),
      .i_awvalid    (i_awvalid),
      .o_awready    (o_awready),

      .i_araddr     (i_araddr),
      .i_arvalid    (i_arvalid),
      .o_arready    (o_arready),

      .i_wdata     (i_wdata),
      .i_wstrb     (i_wstrb),
      .i_wvalid    (i_wvalid),
      .o_wready    (o_wready),

      .o_bvalid    (o_bvalid),
      .i_bready    (i_bready),

      .o_rdata     (o_rdata),
      .o_rvalid    (o_rvalid),
      .i_rready    (i_rready));

   wb_sevenseg sevenseg
     (.i_wb_clk (clk),
      .i_wb_rst (~rst_n),
      .i_wb_dat (wbs_sevenseg_dat),
      .i_wb_sel (wbs_sevenseg_sel),
      .i_wb_we  (wbs_sevenseg_we),
      .i_wb_cyc (wbs_sevenseg_cyc),
      .i_wb_stb (wbs_sevenseg_stb),
      .o_wb_rdt (wbs_sevenseg_rdt),
      .o_wb_ack (wbs_sevenseg_ack),
      .o_ca     (o_ca),
      .o_an     (o_an));

endmodule
