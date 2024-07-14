floorPlan -r 1 0.2 3.0 3.0 3.0 3.0

for {set i 0} {$i < $N1} {incr i} {
    for {set j 0} {$j < $N2} {incr j} {
        createFence "systolic_inst/genblk1[$i].genblk1[$j].pe_inst" [expr (1 + $j * 51)] [expr (1 + $i * 101)] [expr (50 + $j * 51)] [expr (100 + $i * 101)] 
    }
}
