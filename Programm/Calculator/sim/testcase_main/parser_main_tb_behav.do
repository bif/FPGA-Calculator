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


# vcom -work work -cover bs ../../src/demo.vhd

# compile testbench
vcom -work work parser_main_tb.vhd

# compile configuration file
#vcom -work work config_behav.vhd

# start simulation
quietly WaveActivateNextPane {} 0
#waves to simulate the parser
#add wave -noupdate -format Logic /parser_tb/clk
#add wave -noupdate -format Logic /parser_tb/parse_ready_sig
#add wave -noupdate -format Logic /parser_tb/read_next_n_o_sig
#add wave -noupdate -format Logic /parser_tb/tp_parser/read_next_n_o
#add wave -noupdate -format Literal -radix ascii /parser_tb/tp_parser/data_in
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/operand
#add wave -noupdate -format Literal /parser_tb/tp_parser/operator
#add wave -noupdate -format Logic /parser_tb/tp_parser/leading_sign
#add wave -noupdate -format Logic /parser_tb/tp_parser/parse_ready
#add wave -noupdate -format Logic /parser_tb/tp_parser/end_of_operation
#add wave -noupdate -format Logic /parser_tb/tp_parser/error_sig
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/line_count
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/addr_lb
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/addr_lb_next
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/start_pos
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/start_pos_next
#add wave -noupdate -format Literal /parser_tb/tp_parser/parser_fsm_state
#add wave -noupdate -format Literal /parser_tb/tp_parser/check_op_ready
#add wave -noupdate -format Literal /parser_tb/tp_parser/convert_ready
#add wave -noupdate -format Literal /parser_tb/tp_parser/space
#add wave -noupdate -format Literal /parser_tb/tp_parser/num
#add wave -noupdate -format Literal /parser_tb/tp_parser/once
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/convert_count
#add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/convert_count_next

#wawes to simulate man, parser, calc, lb_mem

add wave -noupdate -format Logic /parser_tb/clk
add wave -noupdate -format Logic /parser_tb/tp_parser/parse_ready
add wave -noupdate -format Logic /parser_tb/calc_inst/start_calc
add wave -noupdate -format Logic /parser_tb/calc_inst/need_input
add wave -noupdate -format Logic /parser_tb/calc_inst/calc_ready
add wave -noupdate -format Logic /parser_tb/calc_inst/decode_ready_old
add wave -noupdate -format Logic /parser_tb/calc_inst/decode_ready_calc
add wave -noupdate -format Logic /parser_tb/calc_inst/decode_ready_sig
add wave -noupdate -format Logic /parser_tb/calc_inst/operation_end
add wave -noupdate -format Literal -radix ascii /parser_tb/tp_parser/data_in
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/operand
add wave -noupdate -format Literal /parser_tb/tp_parser/operator
add wave -noupdate -format Logic /parser_tb/tp_parser/leading_sign
add wave -noupdate -format Logic /parser_tb/tp_parser/end_of_operation
add wave -noupdate -format Logic /parser_tb/tp_parser/error_sig
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/addr_lb
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/start_pos
add wave -noupdate -format Literal /parser_tb/tp_parser/parser_fsm_state
add wave -noupdate -format Literal /parser_tb/tp_parser/check_op_ready
add wave -noupdate -format Literal /parser_tb/calc_inst/operand
add wave -noupdate -format Literal /parser_tb/calc_inst/operator
add wave -noupdate -format Logic /parser_tb/calc_inst/error_calc
add wave -noupdate -format Literal /parser_tb/calc_inst/calc_state
add wave -noupdate -format Logic /parser_tb/calc_inst/operation_end_old
add wave -noupdate -format Logic /parser_tb/calc_inst/start_decode_bcd
add wave -noupdate -format Literal /parser_tb/calc_inst/buffer_strich
add wave -noupdate -format Literal /parser_tb/calc_inst/buffer_punkt
add wave -noupdate -format Literal /parser_tb/calc_inst/operator_punkt
add wave -noupdate -format Literal /parser_tb/calc_inst/operator_strich
add wave -noupdate -format Logic /parser_tb/calc_inst/op_strich_flag
add wave -noupdate -format Logic /parser_tb/calc_inst/op_punkt_flag
add wave -noupdate -format Literal /parser_tb/calc_inst/calculation
add wave -noupdate -format Logic /parser_tb/calc_inst/sign_bcd_sig
add wave -noupdate -format Logic /parser_tb/calc_inst/ready_flag
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_0
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_1
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_2
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_3
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_4
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_5
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_6
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_7
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_8
add wave -noupdate -format Literal -radix unsigned /parser_tb/calc_inst/nibble_9



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
run 300 us
#WaveRestoreZoom {14200 ns} {14400 ns}
WaveRestoreZoom {15200 ns} {15400 ns}
#wave zoomfull


