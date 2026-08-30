`timescale 1ns/1ps
module spi_master(s0, s1,mosi, miso,run,sclk,dout, din, done,ss_in_0, ss_in_1,ss1, ss2, ss3, ss4 );
input  s0, s1;
input  miso;
input  run;
input  ss_in_0, ss_in_1;
input  [0:7] din;
output logic sclk;
output logic mosi;
output logic done;
output logic [0:7] dout;
output logic ss1, ss2, ss3, ss4;
logic [0:7] data_register;
logic [0:7] ptr;
logic clk_in;

//Internal clock
  
initial begin
    clk_in = 1'b0;
    mosi = 1'b0;
    done = 1'b0;
    dout= 8'h00;
    data_register = 8'h00;
    ptr = 8'h00;

    ss1 = 1'b0;
    ss2 = 1'b0;
    ss3 = 1'b0;
    ss4 = 1'b0;
end

always #1 clk_in = ~clk_in;

/*---------------------------------------------------------
  SPI clock polarity

  Mode 00 -> CPOL = 0
  Mode 01 -> CPOL = 0
  Mode 10 -> CPOL = 1
  Mode 11 -> CPOL = 1
---------------------------------------------------------*/
assign sclk = (s0) ? ~clk_in : clk_in;

//Master operation
  
always @(sclk) begin
    /*
      Leading edge:

      CPOL = 0 -> rising edge -> sclk becomes 1
      CPOL = 1 -> falling edge -> sclk becomes 0

      Therefore leading edge occurs when:
      sclk == ~s0
    */

    if ((sclk == ~s0) && !run) begin
        data_register = din;
        ptr  = 0;
        done = 0;
        slave_select();

        /*
          Putting first transmit bit on MOSI before
          the first sampling edge.
        */
        mosi = data_register[7];
    end

    if ((sclk == ~s0) && run && !done) begin
        if ((!s0) && (!s1)) begin
            spi_operation_00();
        end
        else if ((!s0) && (s1)) begin
            spi_operation_01();
        end
        else if ((s0) && (!s1)) begin
            spi_operation_10();
        end
        else if ((s0) && (s1)) begin
            spi_operation_11();
        end
    end
end

//Slave selection
  
task slave_select();
    begin
        if ((!ss_in_0) && (!ss_in_1)) begin
            ss1 = 1'b1;
            ss2 = 1'b0;
            ss3 = 1'b0;
            ss4 = 1'b0;
        end

        else if ((!ss_in_0) && (ss_in_1)) begin
            ss1 = 1'b0;
            ss2 = 1'b1;
            ss3 = 1'b0;
            ss4 = 1'b0;
        end

        else if ((ss_in_0) && (!ss_in_1)) begin
            ss1 = 1'b0;
            ss2 = 1'b0;
            ss3 = 1'b1;
            ss4 = 1'b0;
        end
        else begin
            ss1 = 1'b0;
            ss2 = 1'b0;
            ss3 = 1'b0;
            ss4 = 1'b1;
        end
    end
endtask

task spi_operation_00();
    begin
        case(ptr)

            0: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            1: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            2: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            3: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            4: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            5: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            6: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            7: begin

                data_register = data_register >> 1;
                data_register[0] = miso;
                dout = data_register;
                done = 1'b1;

            end

            default: begin
                done = 1'b1;
            end
        endcase
        ptr = ptr + 1;
    end

endtask
  
task spi_operation_01();
    begin

        /*
          First edge changes data.
          Second edge samples data.
        */

        mosi <= data_register[7];

        @(negedge sclk);

        data_register = data_register >> 1;
        data_register[0] = miso;

        if (ptr == 7) begin
            dout = data_register;
            done = 1'b1;
        end

        else begin
            mosi <= data_register[7];
        end
        ptr = ptr + 1;
    end
endtask
  
task spi_operation_10();
    begin
        case(ptr)

            0: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            1: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            2: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            3: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            4: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            5: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            6: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                mosi <= data_register[7];
            end

            7: begin
                data_register = data_register >> 1;
                data_register[0] = miso;
                dout = data_register;
                done = 1'b1;
            end

            default: begin
                done = 1'b1;
            end
        endcase
        ptr = ptr + 1;
    end
endtask

task spi_operation_11();

    begin

        /*
          Leading edge changes data.
          Trailing edge samples data.
        */

        mosi <= data_register[7];

        @(posedge sclk);

        data_register = data_register >> 1;
        data_register[0] = miso;

        if (ptr == 7) begin
            dout = data_register;
            done = 1'b1;
        end

        else begin
            mosi <= data_register[7];
        end
        ptr = ptr + 1;
    end
endtask
endmodule
