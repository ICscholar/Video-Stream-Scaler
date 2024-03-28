onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/clk
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/rst_n
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/clk_div2
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/clk_div4
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/clk_div8
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/r_data
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/g_data
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/b_data
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/p_vs
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/p_hs
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/p_de
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/rd_clk
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/datatype
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/clk_sel
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/hs
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/vs
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/de
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/h_cnt
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/v_cnt
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/sync
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/rdclk
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/dout
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/vs_r0
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/pos_vs
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/wdata
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/w_hs
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/w_vs
add wave -noupdate -group sim:/color_bar_tb/Group1 /color_bar_tb/w_de
add wave -noupdate -radix hexadecimal /color_bar_tb/u_sep2par/din
add wave -noupdate -radix hexadecimal /color_bar_tb/u_sep2par/sync
add wave -noupdate -radix hexadecimal /color_bar_tb/u_sep2par/wrclk
add wave -noupdate -radix hexadecimal /color_bar_tb/u_sep2par/rdclk
add wave -noupdate -radix hexadecimal /color_bar_tb/u_sep2par/dout
add wave -noupdate -radix hexadecimal /color_bar_tb/u_sep2par/shift_reg
add wave -noupdate -radix hexadecimal /color_bar_tb/u_sep2par/shift_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23247370000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 255
configure wave -valuecolwidth 40
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
WaveRestoreZoom {627767860 ps} {991910043 ps}
