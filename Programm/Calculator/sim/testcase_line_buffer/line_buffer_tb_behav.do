if {[file exists behav_work]} {
  vdel -all -lib behav_work
}

# create work library directory
vlib behav_work

# map directory to library name "work"
vmap work behav_work

#compile vhdl files

	vcom -work work ../../../textmode_vga/src/mjl_stratix/textmode_vga_platform_dependent_pkg.vhd
	vcom -work work ../../../math/src/math_pkg.vhd
	vcom -work work ../../../textmode_vga/src/textmode_vga_pkg.vhd
	vcom -work work ../../../textmode_vga/src/font_pkg.vhd
	vcom -work work ../../../textmode_vga/src/textmode_vga_component_pkg.vhd	

	vcom -work work ../../src/sp_ram_pkg.vhd
	vcom -work work ../../src/sp_ram_ent.vhd
	vcom -work work ../../src/sp_ram_arc_beh.vhd

	vcom -work work ../../src/line_buffer_pkg.vhd
	vcom -work work ../../src/line_buffer_ent.vhd
	vcom -work work ../../src/line_buffer_arc_beh.vhd




# vcom -work work -cover bs ../../src/demo.vhd

# compile testbench
vcom -work work line_buffer_tb.vhd

# compile configuration file
#vcom -work work config_behav.vhd

# start simulation
vsim -coverage work.line_buffer_tb

quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state
add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state_next
add wave -noupdate -format Logic /line_buffer_tb/clk
add wave -noupdate -format Logic /line_buffer_tb/vga_free_sig
add wave -noupdate -format Literal /line_buffer_tb/test_string
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/mem_debug_addr
add wave -noupdate -format Literal -radix ascii /line_buffer_tb/mem_debug_data
add wave -noupdate -format Logic /line_buffer_tb/uut/enable
add wave -noupdate -format Logic /line_buffer_tb/uut/start_calc
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/lb_count
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/lb_count_next
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/reset_lb_count
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/reset_lb_count_next
add wave -noupdate -format Logic /line_buffer_tb/new_ascii_sig
add wave -noupdate -format Literal -radix ascii /line_buffer_tb/ascii_sign_sig
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/tb_line_buf_ram/address_wr
add wave -noupdate -format Literal -radix ascii /line_buffer_tb/tb_line_buf_ram/data_wr
add wave -noupdate -format Logic /line_buffer_tb/tb_line_buf_ram/wr
add wave -noupdate -format Logic /line_buffer_tb/index
add wave -noupdate -format Logic /line_buffer_tb/uut/once
add wave -noupdate -format Logic /line_buffer_tb/uut/once_next



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
#run 50 us

# autorun simulation bis vor clear buffer um speicherinhalt zu vergleichen
run 18 us

WaveRestoreZoom {13.9 us} {14.5 us}
#wave zoomfull
