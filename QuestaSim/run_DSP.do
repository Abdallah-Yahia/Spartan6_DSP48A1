vlib work
vlog MUX4x1.v MUX_Reg.v Spartan6_DSP48A1.v Spartan6_DSP48A1_tb.v
vsim -voptargs=+acc work.Spartan6_DSP48A1_tb
add wave *
run -all
#quit -sim