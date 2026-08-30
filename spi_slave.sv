module spi_slave(s0, s1,miso, mosi,run, ss,sclk,dout, din,done);
input s0, s1;
input mosi;
input run;
input ss;
input sclk;
input  [0:7] din;
output logic miso;
output logic done;
output logic [0:7] dout;
logic [0:7] data_register;
logic [0:7] ptr;

initial begin

    miso = 1'bz;
    done = 1'b0;
    dout = 8'h00;
  
    data_register = 8'h00;
    ptr           = 8'h00;

end


//Slave operation

always @(sclk) begin

    /*
      Leading edge:
      sclk == ~s0
    */

    if ((sclk == ~s0) && !run) begin
        data_register = din;
        ptr  = 0;
        done = 0;
        if (ss)
            miso = data_register[7];
        else
            miso = 1'bz;
    end

    if ((sclk == ~s0) && run && ss && !done) begin
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

    /*
      If this slave is not selected, never drive MISO.
    */

    if (!ss) begin
        miso = 1'bz;
    end
end

task spi_operation_00();
    begin
        case(ptr)
            0: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            1: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            2: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            3: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            4: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            5: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            6: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            7: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                dout = data_register;
                done = 1'b1;
                miso <= 1'bz;
            end

            default: begin
                done = 1'b1;
                miso <= 1'bz;
            end
        endcase

        ptr = ptr + 1;

    end
endtask

task spi_operation_01();
    begin
        miso <= data_register[7];
        @(negedge sclk);
        data_register = data_register >> 1;
        data_register[0] = mosi;
        if (ptr == 7) begin
            dout = data_register;
            done = 1'b1;
            miso <= 1'bz;
        end

        else begin
            miso <= data_register[7];
        end

        ptr = ptr + 1;

    end
endtask
  
task spi_operation_10();
    begin
        case(ptr)
            0: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            1: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            2: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            3: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            4: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            5: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            6: begin
                data_register = data_register >> 1;
                data_register[0] = mosi;
                miso <= data_register[7];
            end

            7: begin

                data_register = data_register >> 1;
                data_register[0] = mosi;
                dout = data_register;
                done = 1'b1;
                miso <= 1'bz;

            end

            default: begin
                done = 1'b1;
                miso <= 1'bz;
            end

        endcase

        ptr = ptr + 1;

    end
endtask

task spi_operation_11();
    begin
        miso <= data_register[7];

        @(posedge sclk);
        data_register = data_register >> 1;
        data_register[0] = mosi;

        if (ptr == 7) begin
            dout = data_register;
            done = 1'b1;
            miso <= 1'bz;
        end

        else begin
            miso <= data_register[7];
        end

        ptr = ptr + 1;

    end
endtask
endmodule
