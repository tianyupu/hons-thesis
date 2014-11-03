set terminal postscript eps colour size 3.2,3.2 font "Helvetica,17" solid
set output "example-roc.eps"

set xlabel "False Positive Rate"
set ylabel "True Positive Rate"
set key right bottom box

set title 'Example ROC Curves'
plot x t 'Random guessing' w lines lw 3 lc rgbcolor "#fcd186", \
  "tr-disc-all.dat" t 'No feature selection' w lines lw 3 lc rgbcolor "#3c78d8", \
  "tr-dinh.dat" t 'Baseline' w lines lw 3 lc rgbcolor "green"
