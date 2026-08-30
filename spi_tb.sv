module spi_tb();

logic master_s0;
logic master_s1;
logic master_done;
logic master_run;

logic master_mosi;
logic master_miso;
logic master_sclk;

logic master_ss_in_0;
logic master_ss_in_1;

logic [0:7] master_din;
logic [0:7] master_dout;


logic slave_1_s0;
logic slave_1_s1;
logic slave_1_done;
logic slave_1_run;

logic [0:7] slave_1_din;
logic [0:7] slave_1_dout;

logic slave_2_s0;
logic slave_2_s1;
logic slave_2_done;
logic slave_2_run;

logic [0:7] slave_2_din;
logic [0:7] slave_2_dout;


logic slave_3_s0;
logic slave_3_s1;
logic slave_3_done;
logic slave_3_run;

logic [0:7] slave_3_din;
logic [0:7] slave_3_dout;


logic slave_4_s0;
logic slave_4_s1;
logic slave_4_done;
logic slave_4_run;

logic [0:7] slave_4_din;
logic [0:7] slave_4_dout;

//SPI wires

wire w1;
wire w3;
wire w4;
wire w5;
wire w6;
wire w7;
wire w8;

//  MASTER

spi_master master1(
    .s0(master_s0),
    .s1(master_s1),
    .ss_in_0(master_ss_in_0),
    .ss_in_1(master_ss_in_1),
    .done(master_done),
    .run(master_run),
    .dout(master_dout),
    .din(master_din),
    .mosi(w1),
    .miso(w8),
    .sclk(w3),
    .ss1(w4),
    .ss2(w5),
    .ss3(w6),
    .ss4(w7)
);

spi_slave slave1( //SLAVE 1

    .s0(slave_1_s0),
    .s1(slave_1_s1),
    .done(slave_1_done),
    .run(slave_1_run),
    .dout(slave_1_dout),
    .din(slave_1_din),
    .mosi(w1),
    .miso(w8),
    .sclk(w3),
    .ss(w4)
);
  
spi_slave slave2( //SLAVE 2
    .s0(slave_2_s0),
    .s1(slave_2_s1),
    .done(slave_2_done),
    .run(slave_2_run),
    .dout(slave_2_dout),
    .din(slave_2_din),
    .mosi(w1),
    .miso(w8),
    .sclk(w3),
    .ss(w5)
);

  spi_slave slave3( //SLAVE 3
    .s0(slave_3_s0),
    .s1(slave_3_s1),
    .done(slave_3_done),
    .run(slave_3_run),
    .dout(slave_3_dout),
    .din(slave_3_din),
    .mosi(w1),
    .miso(w8),
    .sclk(w3),
    .ss(w6)

);

  spi_slave slave4(
    .s0(slave_4_s0),
    .s1(slave_4_s1),
    .done(slave_4_done),
    .run(slave_4_run),
    .dout(slave_4_dout),
    .din(slave_4_din),
    .mosi(w1),
    .miso(w8),
    .sclk(w3),
    .ss(w7)

);

assign master_mosi = w1;
assign master_miso = w8;
assign master_sclk = w3;

// TRANSACTION TASK

task automatic run_transaction(
    input logic mode_s0,
    input logic mode_s1,
    input logic select_0,
    input logic select_1,
    input logic [0:7] master_data,
    input integer selected_slave
);

    begin
        master_run = 1'b0;

        slave_1_run = 1'b0;
        slave_2_run = 1'b0;
        slave_3_run = 1'b0;
        slave_4_run = 1'b0;


        // Setting SPI MODE

        master_s0 = mode_s0;
        master_s1 = mode_s1;

        slave_1_s0 = mode_s0;
        slave_1_s1 = mode_s1;

        slave_2_s0 = mode_s0;
        slave_2_s1 = mode_s1;

        slave_3_s0 = mode_s0;
        slave_3_s1 = mode_s1;

        slave_4_s0 = mode_s0;
        slave_4_s1 = mode_s1;

        // Select slave

        master_ss_in_0 = select_0;
        master_ss_in_1 = select_1;

        //Master transmits data

        master_din = master_data;

        // Starting with known slave data

        slave_1_din = 8'h11;
        slave_2_din = 8'h22;
        slave_3_din = 8'h33;
        slave_4_din = 8'h44;

        /*-----------------------------------------------
          Give master/slaves time to load data and
          generate slave select
        -----------------------------------------------*/

        #4;
        /*-----------------------------------------------
          Run only selected slave
        -----------------------------------------------*/

        case(selected_slave)

            1: begin
                slave_1_run = 1'b1;
            end

            2: begin
                slave_2_run = 1'b1;
            end

            3: begin
                slave_3_run = 1'b1;
            end

            4: begin
                slave_4_run = 1'b1;
            end
        endcase
        
        master_run = 1'b1;

        /*-----------------------------------------------
          Wait until master completes 8-bit transfer
        -----------------------------------------------*/

        wait(master_done == 1'b1);
        #2;
        $display("---------------------------------------------");

        $display("MODE = %0d%0d | SLAVE = %0d | MASTER TX = %h",mode_s0,mode_s1,selected_slave,master_data);
        $display("MASTER RX = %h",master_dout);

        case(selected_slave)

            1:$display("SLAVE 1 RX = %h", slave_1_dout);
            2:$display("SLAVE 2 RX = %h", slave_2_dout);
            3:$display("SLAVE 3 RX = %h", slave_3_dout);
            4:$display("SLAVE 4 RX = %h", slave_4_dout);

        endcase

        $display("---------------------------------------------");
        
        master_run = 1'b0;

        slave_1_run = 1'b0;
        slave_2_run = 1'b0;
        slave_3_run = 1'b0;
        slave_4_run = 1'b0;

        #4;
    end
endtask

initial begin
    master_run = 1'b0;

    master_s0 = 1'b0;
    master_s1 = 1'b0;

    master_ss_in_0 = 1'b0;
    master_ss_in_1 = 1'b0;

    master_din = 8'h00;

    slave_1_run = 1'b0;
    slave_2_run = 1'b0;
    slave_3_run = 1'b0;
    slave_4_run = 1'b0;

    slave_1_s0 = 1'b0;
    slave_1_s1 = 1'b0;

    slave_2_s0 = 1'b0;
    slave_2_s1 = 1'b0;

    slave_3_s0 = 1'b0;
    slave_3_s1 = 1'b0;

    slave_4_s0 = 1'b0;
    slave_4_s1 = 1'b0;

    slave_1_din = 8'h11;
    slave_2_din = 8'h22;
    slave_3_din = 8'h33;
    slave_4_din = 8'h44;


    #5;
    // Slave 1 + Mode 00
    run_transaction(0,0, 0,0, 8'hA1, 1);

    // Slave 1 + Mode 01
    run_transaction(0,1, 0,0, 8'hA2, 1);

    // Slave 1 + Mode 10
    run_transaction(1,0, 0,0, 8'hA3, 1);

    // Slave 1 + Mode 11
    run_transaction(1,1, 0,0, 8'hA4, 1);

    // Slave 2 + Mode 00
    run_transaction(0,0, 0,1, 8'hB1, 2);

    // Slave 2 + Mode 01
    run_transaction(0,1, 0,1, 8'hB2, 2);

    // Slave 2 + Mode 10
    run_transaction(1,0, 0,1, 8'hB3, 2);

    // Slave 2 + Mode 11
    run_transaction(1,1, 0,1, 8'hB4, 2);

    // Slave 3 + Mode 00
    run_transaction(0,0, 1,0, 8'hC1, 3);

    // Slave 3 + Mode 01
    run_transaction(0,1, 1,0, 8'hC2, 3);

    // Slave 3 + Mode 10
    run_transaction(1,0, 1,0, 8'hC3, 3);

    // Slave 3 + Mode 11
    run_transaction(1,1, 1,0, 8'hC4, 3);

    // Slave 4 + Mode 00
    run_transaction(0,0, 1,1, 8'hD1, 4);

    // Slave 4 + Mode 01
    run_transaction(0,1, 1,1, 8'hD2, 4);

    // Slave 4 + Mode 10
    run_transaction(1,0, 1,1, 8'hD3, 4);

    // Slave 4 + Mode 11
    run_transaction(1,1, 1,1, 8'hD4, 4);

    #10;
    $display("=============================================");
    $display("       ALL 16 SPI TESTS COMPLETED");
    $display("=============================================");
    $finish;
end
endmodule
