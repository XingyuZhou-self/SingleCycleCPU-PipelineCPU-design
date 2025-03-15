`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module top(
input rstn,
input [4:0]btn_i,
input [15:0]sw_i,
input clk,

output[7:0] disp_an_o,
output[7:0] disp_seg_o,

output [15:0]led_o
);
//define all names and make the output into the input;
//define name of Enter module
wire[4:0] BTN_Enter;
wire[15:0] SW_Enter;
wire[4:0] BTN_out;
wire[15:0] SW_out;

//define name of clk_div module
wire SW2;
wire Clk_CPU;
wire[31:0] clkdiv;

//define name of SPIO module
wire EN_SPIO;
wire[31:0] P_Data;
wire[15:0] LED_out;
wire[1:0] counter_set;
wire[15:0] led;

//define name of Counter_x module
wire clk0;
wire clk1;
wire clk2;
wire[1:0] counter_ch;
wire[31:0] counter_val;
wire counter_we_Counter;
wire counter0_OUT;
wire counter1_OUT;
wire counter2_OUT;

//define dm_controller
wire[31:0] Addr_in;
wire[31:0] Data_read_from_dm;
wire[31:0] Data_write;
wire[2:0] dm_ctrl_1;
wire mem_w_control;
wire[31:0] Data_read;
wire[31:0] Data_write_to_dm;
wire[3:0] wea_mem;

//define name of ROM_D module
wire[9:0] a;
wire[31:0] spo;

//define name of RAM_B;
wire[9:0] addra;
wire[31:0] dina;
wire[3:0] wea;
wire[31:0] douta;

//define name of SCPU
wire[31:0] Data_in;
//wire INT;
//wire MIO_ready;
wire[31:0] inst_in;
wire[31:0] Addr_out;
//wire CPU_MIO;
wire[31:0] Data_out;
wire[31:0] PC_out;
wire[2:0] dm_ctrl_2;
wire mem_w_SCPU;

//define name of MIO_BUS
wire[4:0] BTN_BUS;
wire[31:0] Cpu_data2bus;
wire[15:0] SW_BUS;
wire[31:0] addr_bus;
wire[31:0] counter_out;
wire counter0_out;
wire counter1_out;
wire counter2_out;
wire[15:0] led_out;
wire mem_w_BUS;
wire[31:0] ram_data_out;
wire[31:0] Cpu_data4bus;
wire GPIOe0000000_we;
wire GPIOf0000000_we;
wire[31:0] Peripheral_in;
wire counter_we_BUS;
wire[9:0] ram_addr;
wire[31:0] ram_data_in;

//define name of Multi module;
wire EN_Multi;
wire[63:0] LES_64;
wire[2:0] Switch;
wire[31:0] data0;
wire[31:0] data1;
wire[31:0] data2;
wire[31:0] data3;
wire[31:0] data4;
wire[31:0] data5;
wire[31:0] data6;
wire[31:0] data7;
wire[63:0] point_in;
wire[31:0] Disp_num;
wire[7:0] LE_out;
wire[7:0] point_out;

//define name of SSeg7;
wire[31:0] Hexs;
wire[7:0] LES_8;
wire SW0;
wire flash;
wire[7:0] point;
wire[7:0] seg_an;
wire[7:0] seg_sout;

//define the line

//Enter module
assign BTN_Enter = btn_i;
assign SW_Enter = sw_i;

//clk_div module
assign SW2 = SW_out[2];
//SPIO module
assign EN_SPIO = GPIOf0000000_we;
assign P_Data = Peripheral_in;

//Counter_x module
assign clk0 = clkdiv[6];
assign clk1 = clkdiv[9];
assign clk2 = clkdiv[11];
assign counter_ch = counter_set;
assign counter_val = Peripheral_in;
assign counter_we_Counter = counter_we_BUS;

//dm_controller module
assign Addr_in = Addr_out;
assign Data_read_from_dm = Cpu_data4bus;
assign dm_ctrl_1 = dm_ctrl_2;
assign Data_write = ram_data_in;
assign mem_w_control = mem_w_SCPU;

//ROM_D module
assign a = PC_out[11:2];

//RAM_B module
assign addra = ram_addr;
assign dina = Data_write_to_dm;
assign wea = wea_mem;

//SCPU module
assign Data_in = Data_read;
//assign INT = counter0_OUT;
//assign MIO_ready =CPU_MIO;
assign inst_in = spo;

//MIO_BUS module
assign BTN_BUS = BTN_out;
assign Cpu_data2bus = Data_out;
assign SW_BUS = SW_out;
assign addr_bus =Addr_out;
assign counter_out = 32'b0;
assign counter0_out =counter0_OUT;
assign counter1_out =counter1_OUT;
assign counter2_out =counter2_OUT;
assign led_out = LED_out;
assign mem_w_BUS = mem_w_SCPU;
assign ram_data_out = douta;

//Multi_8CH module
assign EN_Multi = GPIOe0000000_we;
assign LES_64 = ~64'h00000000;
assign Switch = SW_out[7:5];
assign data0 = Peripheral_in;
assign data1 = {1'b0,1'b0,PC_out[31:2]};
assign data2 = spo;
assign data3 = 32'b0;
assign data4 = Addr_out;
assign data5 = Data_out;
assign data6 = Cpu_data4bus;
assign data7 = PC_out;
assign point_in = {clkdiv[31:0],clkdiv[31:0]};

//SSeg7 module
assign Hexs = Disp_num;
assign LES_8 = LE_out;
assign SW0 = SW_out[0];
assign flash = clkdiv[10];
assign point = point_out;

//Instance the module
Enter U10_Enter(
    .BTN(BTN_Enter),
    .SW(SW_Enter),
    .clk(clk),
    .BTN_out(BTN_out),
    .SW_out(SW_out)
);

clk_div U8_clk_div(
    .SW2(SW2),
    .clk(clk),
    .rst(~rstn),
    .Clk_CPU(Clk_CPU),
    .clkdiv(clkdiv)
);

SPIO U7_SPIO (
    .EN(EN_SPIO),
    .P_Data(P_Data),
    .clk(~Clk_CPU),
    .rst(~rstn),
    .LED_out(LED_out),
    .counter_set(counter_set),
    .led(led_o)
);

Counter_x U9_Counter_x(
    .clk(~Clk_CPU),
    .clk0(clk0),
    .clk1(clk1),
    .clk2(clk2),
    .counter_ch(counter_ch),
    .counter_val(counter_val),
    .counter_we(counter_we_Counter),
    .rst(~rstn),
    .counter0_OUT(counter0_OUT),
    .counter1_OUT(counter1_OUT),
    .counter2_OUT(counter2_OUT)
);

dm_controller U3_dm_controller (
    .Addr_in(Addr_in),
    .Data_read_from_dm(Data_read_from_dm),
    .Data_write(Data_write),
    .dm_ctrl(dm_ctrl_1),
    .mem_w(mem_w_control),
    .Data_read(Data_read),
    .Data_write_to_dm(Data_write_to_dm),
    .wea_mem(wea_mem)
);

ROM_D U2_ROM_D (
    .a(a),
    .spo(spo)
);

RAM_B U4_RAM_B (
    .addra(addra),
    .clka(~clk),
    .dina(dina),
    .wea(wea),
    .douta(douta)
);

SCPU U1_SCPU (
    .Data_in(Data_in),
    //.INT(INT),
    //.MIO_ready(MIO_ready),
    .clk(Clk_CPU),
    .inst_in(inst_in),
    .reset(~rstn),
    .Addr_out(Addr_out),
   // .CPU_MIO(CPU_MIO),
    .Data_out(Data_out),
    .PC_out(PC_out),
    .dm_ctrl(dm_ctrl_2),
    .mem_w(mem_w_SCPU)
);
//clk, reset, MIO_ready, inst_in, Data_in, mem_w, 
//  PC_out, Addr_out, Data_out, dm_ctrl, CPU_MIO, INT
MIO_BUS U4_MIO_BUS (
    .BTN(BTN_BUS),
    .Cpu_data2bus(Cpu_data2bus),
    .SW(SW_BUS),
    .addr_bus(addr_bus),
    .clk(clk),
    .counter_out(counter_out),
    .counter0_out(counter0_out),
    .counter1_out(counter1_out),
    .counter2_out(counter2_out),
    .led_out(led_out),
    .mem_w(mem_w_BUS),
    .ram_data_out(ram_data_out),
    .rst(~rstn),
    .Cpu_data4bus(Cpu_data4bus),
    .GPIOe0000000_we(GPIOe0000000_we),
    .GPIOf0000000_we(GPIOf0000000_we),
    .Peripheral_in(Peripheral_in),
    .counter_we(counter_we_BUS),
    .ram_addr(ram_addr),
    .ram_data_in(ram_data_in)
);

Multi_8CH32 U5_Multi_8CH32 (
    .EN(EN_Multi),
    .LES(LES_64),
    .Switch(Switch),
    .clk(~Clk_CPU),
    .data0(data0),
    .data1(data1),
    .data2(data2),
    .data3(data3),
    .data4(data4),
    .data5(data5),
    .data6(data6),
    .data7(data7),
    .point_in(point_in),
    .rst(~rstn),
    .Disp_num(Disp_num),
    .LE_out(LE_out),
    .point_out(point_out)
);

SSeg7 U6_SSeg7 (
    .Hexs(Hexs),
    .LES(LES_8),
    .SW0(SW0),
    .clk(clk),
    .flash(flash),
    .point(point),
    .rst(~rstn),
    .seg_an(disp_an_o),
    .seg_sout(disp_seg_o)
);
endmodule