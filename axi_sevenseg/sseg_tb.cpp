#include <stdint.h>
#include <signal.h>

#include "verilated_vcd_c.h"
#include "Vwb_sevenseg.h"

#include "sseg.h"

using namespace std;

static bool done;

vluint64_t main_time = 0;       // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.

double sc_time_stamp () {       // Called by $time in Verilog
  return main_time;           // converts to double, to match
  // what SystemC does
}

void INThandler(int signal)
{
	printf("\nCaught ctrl-c\n");
	done = true;
}

void do_cycle(Vwb_sevenseg *top, VerilatedVcdC *tfp) {
    if (tfp)
      tfp->dump(main_time);

    main_time+=10;

    top->i_wb_clk = false;
    top->eval();

    if (tfp)
      tfp->dump(main_time);

    main_time+=10;

    top->i_wb_clk = true;
    top->eval();
}
int main(int argc, char **argv, char **env)
{
  Verilated::commandArgs(argc, argv);
  Vwb_sevenseg* top = new Vwb_sevenseg;
  sseg_context_t sseg_context;

  VerilatedVcdC * tfp = 0;
  const char *vcd = Verilated::commandArgsPlusMatch("vcd=");
  if (vcd[0]) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("trace.vcd");
  }

  vluint64_t timeout = 0;
  const char *arg_timeout = Verilated::commandArgsPlusMatch("timeout=");
  if (arg_timeout[0])
    timeout = atoi(arg_timeout+9);

  signal(SIGINT, INThandler);

  uint8_t data[8] = {0x79,0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00};

  top->i_wb_clk = true;
  top->i_wb_rst = 1;
  top->eval();

  //Start up
  while (main_time < 200) {
    do_cycle(top, tfp);
    if (main_time == 100) {
      printf("Releasing reset\n");
      top->i_wb_rst = 0;
    }
  }

  //Start a Wishbone write transaction
  top->i_wb_dat = 0x12345678;
  top->i_wb_sel = 0xf;
  top->i_wb_we  = true;
  top->i_wb_cyc = true;
  top->i_wb_stb = true;

  //Wait for wishbone ack
  while (!top->o_wb_ack)
    do_cycle(top, tfp);
  do_cycle(top, tfp);
  top->i_wb_cyc = false;
  top->i_wb_stb = false;

  //Wait for correct data to be presented on the 7-segment controller pins
  while (!(done || Verilated::gotFinish())) {
    do_cycle(top, tfp);
    if (do_sseg(&sseg_context, top->o_an, top->o_ca)) {
      uint32_t number = sseg_to_int(sseg_context.data);
      printf("%08x\n", number);
      if (number == 0x12345678) {
	printf("Success!\n");
	done = true;
      }
    }

    if (timeout && (main_time >= timeout)) {
      printf("Timeout: Exiting at time %lu\n", main_time);
      done = true;
    }
  }
  if (tfp)
    tfp->close();
  exit(0);
}
