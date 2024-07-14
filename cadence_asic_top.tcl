set M [getenv "M"]
set N1 [getenv "N1"]
set N2 [getenv "N2"]

set init_mmmc_file "setup-timing.tcl"
set init_verilog   "post-synth.v"
set init_top_cell  "mm_M${M}_N1${N1}_N2${N2}"
set init_lef_file  "/opt/FreePDK45/osu_soc/lib/files/gscl45nm.lef sram_s2mm.lef sram_mm2s.lef"
set init_gnd_net   "VSS"
set init_pwr_net   "VDD"


init_design
setDelayCalMode -siAware false
set_ccopt_property buffer_cells {CLKBUF1 CLKBUF2 CLKBUF3}
set_ccopt_property inverter_cells {}
set_ccopt_property clock_gating_cells {}
set_ccopt_property use_inverters false

setDesignMode -process 45 -flowEffort standard
setDesignMode -earlyClockFlow true

set_interactive_constraint_modes [all_constraint_modes -active]
set_ideal_network mm_rst_n

setFillerMode -corePrefix FILL -core "FILL"

source cadence_asic_floorplan.tcl

set PAR [getenv "PAR"]

if {$PAR == 1} {
	source cadence_asic_par.tcl
} else  {
	win
}
