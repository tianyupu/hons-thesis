set term png medium font "Helvetica" size 1000,500
set output "trauma.png"

set size 1.5, 1.0

set xlabel "False Positive Rate"
set ylabel "True Positive Rate"
set key right bottom box

set multiplot

set origin 0.0, 0.0
set size 0.5, 1.0
set title 'No Discretisation'
plot x t 'Random guessing' w lines lw 2 lc rgbcolor "#fcd186", \
  "tr-nodisc-cfs.dat" t 'Feature selection-CFS' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-nodisc-corr.dat" t 'Feature selection-Correl' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-nodisc-ig.dat" t 'Feature selection-Info gain' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-nodisc-oner.dat" t 'Feature selection-1R' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-nodisc-all.dat" t 'No feature selection' w lines lw 2 lc rgbcolor "#3c78d8", \
  "tr-dinh.dat" t 'Baseline' w lines lw 2 lc rgbcolor "#da8707", \
  "tr-nodisc-ranked.dat" t 'Ranked-NN' w lines lw 2 lc rgbcolor "green"

set origin 0.5, 0.0
set size 0.5, 1.0
set title 'With Discretisation'
plot x t 'Random guessing' w lines lw 2 lc rgbcolor "#fcd186", \
  "tr-disc-cfs.dat" t 'Feature selection-CFS' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-disc-corr.dat" t 'Feature selection-Correl' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-disc-ig.dat" t 'Feature selection-Info gain' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-disc-oner.dat" t 'Feature selection-1R' w lines lw 2 lc rgbcolor "#a4c2f4", \
  "tr-disc-all.dat" t 'No feature selection' w lines lw 2 lc rgbcolor "#3c78d8", \
  "tr-dinh.dat" t 'Baseline' w lines lw 2 lc rgbcolor "#da8707", \
  "tr-nodisc-ranked.dat" t 'Ranked-NN' w lines lw 2 lc rgbcolor "green"
unset multiplot

set size 1.5, 1.0
