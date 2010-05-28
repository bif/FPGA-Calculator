onerror {resume}
quietly WaveActivateNextPane {} 0
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
WaveRestoreCursors {{Cursor 1} {20016 ns} 0}
configure wave -namecolwidth 208
configure wave -valuecolwidth 52
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
WaveRestoreZoom {19896 ns} {20136 ns}
