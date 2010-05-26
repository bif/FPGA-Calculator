onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /parser_tb/clk
add wave -noupdate -format Logic /parser_tb/parse_ready_sig
add wave -noupdate -format Logic /parser_tb/read_next_n_o_sig
add wave -noupdate -format Literal -radix ascii /parser_tb/tp_parser/data_in
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/operand
add wave -noupdate -format Literal /parser_tb/tp_parser/operator
add wave -noupdate -format Logic /parser_tb/tp_parser/parse_ready
add wave -noupdate -format Logic /parser_tb/tp_parser/end_of_operation
add wave -noupdate -format Logic /parser_tb/tp_parser/error_sig
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/line_count
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/addr_lb
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/addr_lb_next
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/start_pos
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/start_pos_next
add wave -noupdate -format Literal /parser_tb/tp_parser/parser_fsm_state
add wave -noupdate -format Literal /parser_tb/tp_parser/check_op_ready
add wave -noupdate -format Literal /parser_tb/tp_parser/convert_ready
add wave -noupdate -format Literal /parser_tb/tp_parser/debug_sig
add wave -noupdate -format Literal /parser_tb/tp_parser/debug_sig_next
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/convert_count
add wave -noupdate -format Literal -radix decimal /parser_tb/tp_parser/convert_count_next
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
WaveRestoreZoom {14200 ns} {14400 ns}
