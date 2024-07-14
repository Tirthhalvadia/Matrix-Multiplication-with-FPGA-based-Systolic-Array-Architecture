globalNetConnect VDD -type pgpin -pin vdd -inst * -verbose
globalNetConnect VSS -type pgpin -pin gnd -inst * -verbose

addRing -nets {VDD VSS} -width 0.6 -spacing 0.5 -layer [list top 5 bottom 5 left 6 right 6]

sroute -nets {VDD VSS}

setPlaceMode -place_global_place_io_pins true
setRouteMode -earlyGlobalMaxRouteLayer 7


place_opt_design

extractRC
optDesign -preCTS
optDesign -preCTS -incr

extractRC
create_ccopt_clock_tree_spec
ccopt_design

optDesign -postCTS
optDesign -postCTS -incr

setAnalysisMode -analysisType onChipVariation -cppr both

routeDesign
optDesign -postRoute
optDesign -postRoute -incr

reportDensity > density.rpt
addFiller

verifyConnectivity
verify_drc

saveNetlist post-par.v

extractRC
rcOut -rc_corner typical -spef post-par.spef

streamOut post-par.gds -merge "/opt/pdk_v1.3_v2010_12/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/gds/NangateOpenCellLibrary.gds sram_mm2s.gds sram_s2mm.gds" -mapFile "/opt/FreePDK45/osu_soc/flow/gds2_encounter.map"

report_timing > timing.rpt
report_area > area.rpt
report_power -hierarchy all > power.rpt

exit

