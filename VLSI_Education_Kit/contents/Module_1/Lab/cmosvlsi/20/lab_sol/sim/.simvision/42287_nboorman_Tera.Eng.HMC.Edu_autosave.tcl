
# NC-Sim Command File
# TOOL:	ncsim(64)	15.20-s069
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias . run
alias iprof profile
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves testbench.dut.arm.dp.rf.wabb testbench.dut.arm.dp.rf.wab testbench.dut.arm.dp.rf.wa testbench.dut.arm.dp.rf.w testbench.dut.arm.dp.rf.vdd_ testbench.dut.arm.dp.rf.rd2 testbench.dut.arm.dp.rf.rd1 testbench.dut.arm.dp.rf.ra2bb testbench.dut.arm.dp.rf.ra2b testbench.dut.arm.dp.rf.ra2 testbench.dut.arm.dp.rf.ra1bb testbench.dut.arm.dp.rf.ra1b testbench.dut.arm.dp.rf.ra1 testbench.dut.arm.dp.rf.r15 testbench.dut.arm.dp.rf.ph2 testbench.dut.arm.dp.rf.net017 testbench.dut.arm.dp.rf.net016 testbench.dut.arm.dp.rf.net015 testbench.dut.arm.dp.rf.net014 testbench.dut.arm.dp.rf.gnd_ testbench.dut.arm.dp.rf.RegWrite
probe -create -database waves testbench.dut.arm.dp.reset testbench.dut.arm.dp.ph2 testbench.dut.arm.dp.ph1 testbench.dut.arm.dp.WriteData testbench.dut.arm.dp.SrcB testbench.dut.arm.dp.SrcA testbench.dut.arm.dp.ResultSrc testbench.dut.arm.dp.Result testbench.dut.arm.dp.RegWrite testbench.dut.arm.dp.RegSrc testbench.dut.arm.dp.ReadData testbench.dut.arm.dp.RD2 testbench.dut.arm.dp.RD1 testbench.dut.arm.dp.RA2 testbench.dut.arm.dp.RA1 testbench.dut.arm.dp.PCWrite testbench.dut.arm.dp.PC testbench.dut.arm.dp.Instr testbench.dut.arm.dp.ImmSrc testbench.dut.arm.dp.IRWrite testbench.dut.arm.dp.ExtImm testbench.dut.arm.dp.Data testbench.dut.arm.dp.AdrSrc testbench.dut.arm.dp.Adr testbench.dut.arm.dp.ALUSrcB testbench.dut.arm.dp.ALUSrcA testbench.dut.arm.dp.ALUResult testbench.dut.arm.dp.ALUOut testbench.dut.arm.dp.ALUFlags testbench.dut.arm.dp.ALUControl testbench.dut.arm.dp.A

simvision -input /courses/cmosvlsi/20/lab_sol/sim/.simvision/42287_nboorman_Tera.Eng.HMC.Edu_autosave.tcl.svcf
