#!/bin/csh -f

# gnuplotFit_alpha1.csh

# 2021.09.09
# 2021.11.18


# arguments
if ( $#argv != 1 ) then
    printf "Input 1 argument..."
    printf "[inputFile]"
    exit
endif

# input
set inputFile = $argv[1]

# gnuplot
gnuplot << _EOT_

# plot
plot "${inputFile}"

# define
f(x) = a+b*(x-306.5)+c*(x-306.5)**2
g(x) = a+b*(x-306.5)
h(x) = a+b*(2000-306.5)
s(x) = x<306.5 ? f(x) : x<2000 ? g(x) : h(x)

# fit
fit s(x) "${inputFile}" using 1:2 via a,b,c

# setting
set xrange[0:2500]
set xlabel 'PHA0[ch]'
set ylabel 'Goffset[ch]'
set xlabel font "Arial,15"
set ylabel font "Arial,15"
set origin 0.05, 0.05
set size 0.9, 0.9

# plot
plot "${inputFile}" title "data" , s(x) title "fit"

# save var
save variables "FIT_ResultAllData.dat"

# save graph
set terminal pdfcairo
set output "FIT_Graph.pdf"
plot "${inputFile}" title "data" , s(x) title "fit"
quit

# end of gnuplot
exit
_EOT_

# finish
exit
