module bus_wr_rd_task();

reg clk,rd,wr,ce;
reg [7:0]  addr,data_wr,data_rd;
reg [7:0]  read_data;

initial begin
  clk = 0;
  read_data = 0;
  rd = 0;
  wr = 0;
  ce = 0;
  addr = 0;
  data_wr = 0;
  data_rd = 0;

  // Call the write and read tasks
  #1 bus_write(8'h2,8'hAC);
  #1 bus_read(8'h2,read_data);
  #1 bus_write(8'h12,8'hBD);
  #1 bus_read(8'h12,read_data);
  #1 bus_write(8'h22,8'h5A);
  #1 bus_read(8'h22,read_data);

  #100 
  $finish;
end

// Clock Generator
always
  #1 clk = ~clk;

// Bus read task
task bus_read;
  input [7:0]  address;
  output [7:0] data;
  begin
    $display ("%g Bus read task with address : %h", $time, address);
    $display ("%g  -> Driving CE, RD and ADDRESS on to bus", $time);
    @ (posedge clk);
    addr = address;
    ce = 1;
    rd = 1;
    @ (negedge clk);
    data = data_rd;
    @ (posedge clk);
    addr = 0;
    ce = 0;
    rd = 0;
    $display ("%g Bus read data              : %h", $time, data);
    $display ("======================");
  end
endtask

// Bus write task
task bus_write;
  input [7:0]  address;
  input [7:0] data;
  begin
    $display ("%g Bus write task with address : %h Data : %h", 
      $time, address,data);
    $display ("%g  -> Driving CE, WR, WR data and ADDRESS on to bus", 
      $time);
    @ (posedge clk);
    addr = address;
    ce = 1;
    wr = 1;
    data_wr = data;
    @ (posedge clk);
    addr = 0;
    ce = 0;
    wr = 0;
    $display ("======================");
  end
endtask

// Memory model for checking tasks
reg [7:0] mem [0:255];

always @ (*)
if (ce) begin
  if (wr) begin
    mem[addr] = data_wr;
  end
  if (rd) begin
    data_rd = mem[addr];
  end
end

endmodule
