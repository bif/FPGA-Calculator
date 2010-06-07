if {[file exists behav_work]} {
  vdel -all -lib behav_work
}

# create work library directory
vlib behav_work

# map directory to library name "work"
vmap work behav_work

#compile vhdl files


	vcom -work work ../../src/itoa_pkg.vhd
	vcom -work work ../../src/itoa.vhd
	vcom -work work ../../src/itoa_beh.vhd

	vcom -work work ../../src/alu_pkg.vhd
	vcom -work work ../../src/alu.vhd
	vcom -work work ../../src/alu_beh.vhd

	vcom -work work ../../src/calc.vhd
	vcom -work work ../../src/calc_beh.vhd

	vcom -work work ../../src/memarray_pkg.vhd
	vcom -work work ../../src/memarray_ent.vhd
	vcom -work work ../../src/memarray_arc_beh.vhd

	vcom -work work ../../src/main_pkg.vhd
	vcom -work work ../../src/main_ent.vhd
	vcom -work work ../../src/main_arc_beh.vhd

	vcom -work work ../../src/sp_ram_pkg.vhd
	vcom -work work ../../src/sp_ram_ent.vhd
	vcom -work work ../../src/sp_ram_arc_beh.vhd

	vcom -work work ../../src/parser_pkg.vhd
	vcom -work work ../../src/parser_ent.vhd
	vcom -work work ../../src/parser_arc_beh.vhd

# compile testbench
	vcom -work work ./parser_main_tb.vhd

# compile configuration file
#vcom -work work config_behav.vhd

# start simulation
vsim -coverage work.parser_main_tb

quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 20 {Parser}
add wave -noupdate -format Literal -radix decimal /parser_main_tb/tp_parser/operand
add wave -noupdate -format Literal /parser_main_tb/tp_parser/operator
add wave -noupdate -format Logic /parser_main_tb/tp_parser/leading_sign
add wave -noupdate -format Logic /parser_main_tb/tp_parser/parse_ready
add wave -noupdate -format Logic /parser_main_tb/tp_parser/end_of_operation
add wave -noupdate -format Literal /parser_main_tb/test_string
add wave -noupdate -format Literal /parser_main_tb/tp_parser/parser_fsm_state
add wave -noupdate -format Logic /parser_main_tb/tp_parser/error_sig
add wave -noupdate -format Logic /parser_main_tb/start_calc_sig

add wave -noupdate -divider -height 30 {Calulator}
add wave -noupdate -format Logic /parser_main_tb/calc_inst/start_decode_bcd
add wave -noupdate -format Logic /parser_main_tb/calc_inst/decode_ready_calc
add wave -noupdate -format Logic /parser_main_tb/calc_inst/need_input
add wave -noupdate -format Logic /parser_main_tb/calc_inst/calc_ready
add wave -noupdate -format Literal /parser_main_tb/calc_inst/calc_state

#add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/buffer_strich
#add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/buffer_strich_next
#add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/buffer_punkt
#add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/buffer_punkt_next

#add wave -noupdate -format Literal /parser_main_tb/calc_inst/operator_punkt
#add wave -noupdate -format Literal /parser_main_tb/calc_inst/operator_punkt_next
#add wave -noupdate -format Literal /parser_main_tb/calc_inst/operator_strich
#add wave -noupdate -format Literal /parser_main_tb/calc_inst/operator_strich_next

add wave -noupdate -format Literal /parser_main_tb/calc_inst/calculation
add wave -noupdate -format Logic /parser_main_tb/calc_inst/operation_end





#add wave -noupdate -format Logic /parser_main_tb/calc_inst/ready_flag
#add wave -noupdate -format Logic /parser_main_tb/calc_inst/error_calc
#add wave -noupdate -format Logic /parser_main_tb/calc_inst/sign_bcd_sig
#add wave -noupdate -format Literal /parser_main_tb/calc_inst/bcd_buf
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_0_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_1_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_2_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_3_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_4_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_5_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_6_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_7_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_8_sig
add wave -noupdate -format Logic -radix unsigned /parser_main_tb/calc_inst/out_9_sig
add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/operand_1
add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/operand_2

add wave -noupdate -divider -height 20 {Divider}
add wave -noupdate -format Literal /parser_main_tb/calc_inst/alu_in/alu_state
add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/alu_in/buf
add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/alu_in/buf2
add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/alu_in/buf1
add wave -noupdate -format Literal -radix decimal /parser_main_tb/calc_inst/alu_in/sum_tmp
add wave -noupdate -format Literal /parser_main_tb/calc_inst/alu_in/sm

add wave -noupdate -format Logic /parser_main_tb/clk

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update



# auto-run simulation
run 3 ms
WaveRestoreZoom {14300 ns} {14600 ns}
#wave zoomfull


