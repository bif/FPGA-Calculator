onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /line_buffer_tb/uut/col_cnt
add wave -noupdate -format Literal /line_buffer_tb/uut/col_cnt_next
add wave -noupdate -format Logic /line_buffer_tb/uut/new_ascii_in_sig
add wave -noupdate -format Literal -expand /line_buffer_tb/ascii_sign_sig
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(7)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(6)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(5)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(4)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(3)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(2)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(1)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(0)
add wave -noupdate -format Logic /line_buffer_tb/uut/vga_free
add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 172
configure wave -valuecolwidth 60
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
WaveRestoreZoom {0 ns} {619342 ns}
