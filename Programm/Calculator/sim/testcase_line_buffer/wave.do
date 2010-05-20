onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state
add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state_next
add wave -noupdate -format Logic /line_buffer_tb/clk
add wave -noupdate -format Logic /line_buffer_tb/vga_free_sig
add wave -noupdate -format Logic /line_buffer_tb/uut/once
add wave -noupdate -format Logic /line_buffer_tb/uut/once_next
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/count
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/count_next
add wave -noupdate -format Logic /line_buffer_tb/new_ascii_sig
add wave -noupdate -format Literal -radix ascii /line_buffer_tb/ascii_sign_sig
add wave -noupdate -format Literal /line_buffer_tb/command_sig
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(7)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(6)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(5)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(4)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(3)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(2)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(1)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(0)
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
WaveRestoreZoom {49122 ns} {49966 ns}