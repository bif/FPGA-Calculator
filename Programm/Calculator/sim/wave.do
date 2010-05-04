onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /main_tb/uut/uart_inst/baudrate_inst/sys_clk
add wave -noupdate -format Literal /main_tb/uut/uart_inst/baudrate_inst/baud_cnt
add wave -noupdate -format Logic /main_tb/uut/uart_inst/baudrate_inst/baud_clock_sig
add wave -noupdate -format Logic /main_tb/uut/uart_inst/uart_send_inst/baud_in_clk
add wave -noupdate -format Logic /main_tb/uut/uart_inst/baud_clk_sig
add wave -noupdate -format Logic /main_tb/uut/uart_inst/baudrate_inst/baud_out_clk
add wave -noupdate -format Literal /main_tb/uut/uart_inst/baudrate_inst/baud_cnt_next
add wave -noupdate -format Logic /main_tb/uut/uart_inst/uart_txd_sig
add wave -noupdate -format Logic /main_tb/uut/uart_inst/uart_inst_txd
add wave -noupdate -format Literal /main_tb/uut/uart_inst/uart_send_inst/uart_send_state
add wave -noupdate -format Literal /main_tb/uut/uart_inst/uart_send_inst/uart_send_state_next
add wave -noupdate -format Logic /main_tb/uut/uart_inst/uart_send_inst/uart_send_txd
add wave -noupdate -format Logic /main_tb/uut/uart_inst/tx_busy_sig
add wave -noupdate -format Logic /main_tb/uut/uart_inst/uart_send_inst/tx_busy
add wave -noupdate -format Logic /main_tb/uut/uart_inst/new_byte_sig
add wave -noupdate -format Logic /main_tb/uut/uart_inst/uart_send_inst/new_byte
add wave -noupdate -format Literal /main_tb/uut/uart_inst/byte_out_sig
add wave -noupdate -format Literal /main_tb/uut/uart_inst/uart_send_inst/byte_out
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {935 ns}
