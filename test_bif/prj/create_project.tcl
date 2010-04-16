package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "mjl_stratix"]} {
		puts "Project mjl_stratix is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists mjl_stratix]} {
		project_open -revision mjl_stratix mjl_stratix
	} else {
		project_new -revision mjl_stratix mjl_stratix
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY Stratix
	set_global_assignment -name DEVICE EP1S25F672C6
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name MISC_FILE "mjl_stratix.dpf"
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED WITH WEAK PULL-UP"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS INPUT TRI-STATED"

	#*******************************************************************************************
	# Used File
	#********************************************************************************************
	set_global_assignment -name TOP_LEVEL_ENTITY calculator_top
	set_global_assignment -name VHDL_FILE ../src/top_arc_struct.vhd
	set_global_assignment -name VHDL_FILE ../src/top_ent.vhd
	set_global_assignment -name VHDL_FILE ../src/counter_ent.vhd
	set_global_assignment -name VHDL_FILE ../src/counter_arc_beh.vhd
	set_global_assignment -name VHDL_FILE ../src/debounce_arc_struct.vhd
	set_global_assignment -name VHDL_FILE ../src/debounce_ent.vhd
	set_global_assignment -name VHDL_FILE ../src/debounce_fsm_arc_beh.vhd
	set_global_assignment -name VHDL_FILE ../src/debounce_fsm_ent.vhd
	set_global_assignment -name VHDL_FILE ../src/debounce_pkg.vhd
	set_global_assignment -name VHDL_FILE ../src/led_arc_beh.vhd
	set_global_assignment -name VHDL_FILE ../src/led_ent.vhd
	set_global_assignment -name VHDL_FILE ../src/led_pkg.vhd
	set_global_assignment -name VHDL_FILE ../src/sync_ent.vhd
	set_global_assignment -name VHDL_FILE ../src/sync_pkg.vhd
	set_global_assignment -name VHDL_FILE ../src/sync_arc_beh.vhd
	set_global_assignment -name VHDL_FILE ../src/top_arc_struct.vhd
	set_global_assignment -name VHDL_FILE ../src/top_ent.vhd
	set_global_assignment -name VHDL_FILE ../src/math_pkg.vhd

	#********************************************************************************************
	# Pin Mapping
	#********************************************************************************************
	set_location_assignment PIN_N3 -to sys_clk
	set_location_assignment PIN_AF17 -to sys_res_n
	set_location_assignment PIN_A3 -to btn_a
	set_location_assignment PIN_A6 -to led_a
	set_location_assignment PIN_A7 -to led_b


	
	set_global_assignment -name FMAX_REQUIREMENT "33.33 MHz" -section_id sys_clk
	set_instance_assignment -name CLOCK_SETTINGS sys_clk -to sys_clk

	set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
	set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
