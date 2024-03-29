gui_open_window Wave
gui_sg_create video_pll_group
gui_list_add_group -id Wave.1 {video_pll_group}
gui_sg_addsignal -group video_pll_group {video_pll_tb.test_phase}
gui_set_radix -radix {ascii} -signals {video_pll_tb.test_phase}
gui_sg_addsignal -group video_pll_group {{Input_clocks}} -divider
gui_sg_addsignal -group video_pll_group {video_pll_tb.CLK_IN1}
gui_sg_addsignal -group video_pll_group {{Output_clocks}} -divider
gui_sg_addsignal -group video_pll_group {video_pll_tb.dut.clk}
gui_list_expand -id Wave.1 video_pll_tb.dut.clk
gui_sg_addsignal -group video_pll_group {{Status_control}} -divider
gui_sg_addsignal -group video_pll_group {video_pll_tb.RESET}
gui_sg_addsignal -group video_pll_group {video_pll_tb.LOCKED}
gui_sg_addsignal -group video_pll_group {{Counters}} -divider
gui_sg_addsignal -group video_pll_group {video_pll_tb.COUNT}
gui_sg_addsignal -group video_pll_group {video_pll_tb.dut.counter}
gui_list_expand -id Wave.1 video_pll_tb.dut.counter
gui_zoom -window Wave.1 -full
