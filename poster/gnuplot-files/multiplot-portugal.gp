set term png medium font "Helvetica" size 1000,500
set output "portugal.png"

set size 1.5, 1.0

set xlabel "False Positive Rate"
set ylabel "True Positive Rate"
set key right bottom box

set multiplot

set origin 0.0, 0.0
set size 0.5, 1.0
set title 'No Discretisation'
plot x t 'Random guessing' w lines lw 2 lc rgbcolor "#fcd186", \
  "pt-nodisc-cfs.dat" t 'Feature selection-CFS' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-nodisc-corr.dat" t 'Feature selection-Correl' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-nodisc-ig.dat" t 'Feature selection-Info gain' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-nodisc-oner.dat" t 'Feature selection-1R' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-nodisc-all.dat" t 'No feature selection' w lines lw 2 lc rgbcolor "#3c78d8", \
  "pt-nodisc-ranked.dat" t 'Ranked-NN' w lines lw 2 lc rgbcolor "green"

set origin 0.5, 0.0
set size 0.5, 1.0
set title 'With Discretisation'
plot x t 'Random guessing' w lines lw 2 lc rgbcolor "#fcd186", \
  "pt-disc-cfs.dat" t 'Feature selection-CFS' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-disc-corr.dat" t 'Feature selection-Correl' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-disc-ig.dat" t 'Feature selection-Info gain' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-disc-oner.dat" t 'Feature selection-1R' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "pt-disc-all.dat" t 'No feature selection' w lines lw 2 lc rgbcolor "#3c78d8", \
  "pt-nodisc-ranked.dat" t 'Ranked-NN' w lines lw 2 lc rgbcolor "green"
unset multiplot

set size 1.5, 1.0
