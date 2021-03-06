if {[file exists behav_work]} {
  vdel -all -lib behav_work
}

# create work library directory
vlib behav_work

# map directory to library name "work"
vmap work behav_work

#compile vhdl files

	vcom -work work ../../src/sp_ram_ent.vhd
	vcom -work work ../../src/sp_ram_pkg.vhd
	vcom -work work ../../src/sp_ram_arc_beh.vhd

	vcom -work work ../../src/parser_pkg.vhd
	vcom -work work ../../src/parser_ent.vhd
	vcom -work work ../../src/parser_arc_beh.vhd


# vcom -work work -cover bs ../../src/demo.vhd

# compile testbench
vcom -work work parser_tb.vhd

# compile configuration file
#vcom -work work config_behav.vhd

# start simulation
vsim -coverage work.parser_tb

quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/operand
add wave -noupdate -format Literal /parser_tb/tp_parser/operator
add wave -noupdate -format Logic /parser_tb/tp_parser/leading_sign
add wave -noupdate -format Logic /parser_tb/tp_parser/parse_ready
add wave -noupdate -format Logic /parser_tb/tp_parser/end_of_operation
add wave -noupdate -format Literal /parser_tb/test_string
add wave -noupdate -format Literal /parser_tb/tp_parser/parser_fsm_state
add wave -noupdate -format Logic /parser_tb/tp_parser/error_sig

add wave -noupdate -format Logic /parser_tb/clk
add wave -noupdate -format Logic /parser_tb/parse_ready_sig
add wave -noupdate -format Logic /parser_tb/read_next_n_o_sig
add wave -noupdate -format Logic /parser_tb/tp_parser/read_next_n_o
add wave -noupdate -format Literal -radix ascii /parser_tb/tp_parser/data_in
add wave -noupdate -format Logic /parser_tb/continue
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/line_count
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/addr_lb
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/addr_lb_next
add wave -noupdate -format Literal /parser_tb/tp_parser/check_op_ready
add wave -noupdate -format Literal /parser_tb/tp_parser/space
add wave -noupdate -format Literal /parser_tb/tp_parser/num
add wave -noupdate -format Literal /parser_tb/tp_parser/once
add wave -noupdate -format Literal /parser_tb/get_next
add wave -noupdate -format Literal  -radix decimal /parser_tb/mem_debug_addr
add wave -noupdate -format Literal  -radix ascii /parser_tb/mem_debug_data
add wave -noupdate -format Literal  -radix decimal /parser_tb/lb_addr_wr_sig
add wave -noupdate -format Literal  -radix ascii /parser_tb/lb_data_wr_sig


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
WaveRestoreZoom {14400 ns} {14700 ns}
#wave zoomfull


