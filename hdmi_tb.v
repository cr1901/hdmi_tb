`timescale 1ns/100ps

module hdmi_tb();
reg btn;
reg sys_clk;

reg rx;
wire tx;


// clock
initial sys_clk = 1'b0;
always #5 sys_clk = ~sys_clk;

// reset
initial begin
	rx = 1'b1;
	btn <= 1'b0;
	#20
	btn = 1'b1;
end


top dut(
    .clk100(sys_clk),
    .serial_tx(tx),
    .serial_rx(rx),
	.user_btn5(btn)
);

initial begin
    $dumpfile("hdmi_tb.vcd");
    $dumpvars(0, dut);
end

always @ (posedge sys_clk)
begin
    if($time > 3000000) begin
        $finish;
    end
end

endmodule
