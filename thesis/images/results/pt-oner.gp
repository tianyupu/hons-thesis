set terminal postscript eps colour size 6.42,4.5 font "Helvetica,18"
set output "pt-oner.eps"

set termoption dash

set size 1.0, 1.0

set style line 1 lt 1 lc rgb "#aaaaff" lw 5
set style line 2 lt 1 lc rgb "#00aa00" lw 5
set style line 3 lt 1 lc rgb "#77ff00" lw 5
set style line 4 lt 1 lc rgb "#ffff00" lw 5
set style line 5 lt 1 lc rgb "#ff0000" lw 5
set style line 6 lt 1 lc rgb "#dd00ff" lw 5
set style line 7 lt 1 lc rgb "#0000ff" lw 5
set style line 8 lt 1 lc rgb "#00ffff" lw 5
set style line 9 lt 1 lc rgb "#dddddd" lw 5
set style line 10 lt 1 lc rgb "#6666ff" lw 5
set style line 11 lt 1 lc rgb "#000000" lw 5

set style line 21 lt 3 lc rgb "#aaaaff" lw 7
set style line 22 lt 3 lc rgb "#00aa00" lw 7
set style line 23 lt 3 lc rgb "#77ff00" lw 7
set style line 24 lt 3 lc rgb "#ffff00" lw 7
set style line 25 lt 3 lc rgb "#ff0000" lw 7
set style line 26 lt 3 lc rgb "#dd00ff" lw 7
set style line 27 lt 3 lc rgb "#0000ff" lw 7
set style line 28 lt 3 lc rgb "#00ffff" lw 7
set style line 29 lt 3 lc rgb "#dddddd" lw 7
set style line 30 lt 3 lc rgb "#6666ff" lw 7
set style line 31 lt 3 lc rgb "#000000" lw 7

set border 3
set tics nomirror
set title '1R Feature Selection'

set multiplot
set origin 0, 0
set size 0.5, 1
set xrange [66.905:96.905]
set yrange [70:100]
set format y "%g%%"
set xlabel '1R Accuracy Threshold'
set ylabel 'Accuracy'
unset key

plot "pt-oner.dat" u 1:($2*100) t 'Zero-R' w l ls 1, \
  "pt-oner.dat" u 1:($3*100) t '1R' w l ls 2, \
  "pt-oner.dat" u 1:($4*100) t 'NB' w l ls 3, \
  "pt-oner.dat" u 1:($5*100) t 'DT' w l ls 4, \
  "pt-oner.dat" u 1:($6*100) t 'LR' w l ls 5, \
  "pt-oner.dat" u 1:($7*100) t 'SVM' w l ls 6, \
  "pt-oner.dat" u 1:($8*100) t '1NN' w l ls 7, \
  "pt-oner.dat" u 1:($9*100) t '20NN' w l ls 8, \
  "pt-oner.dat" u 1:($10*100) t 'RD' w l ls 9, \
  "pt-oner.dat" u 1:($11*100) t 'K*' w l ls 10, \
  "pt-oner.dat" u 1:($12*100) t 'MLP' w l ls 11, \
  "pt-oner.dat" u 1:($13*100) t 'Zero-R' w l ls 21, \
  "pt-oner.dat" u 1:($14*100) t '1R' w l ls 22, \
  "pt-oner.dat" u 1:($15*100) t 'NB' w l ls 23, \
  "pt-oner.dat" u 1:($16*100) t 'DT' w l ls 24, \
  "pt-oner.dat" u 1:($17*100) t 'LR' w l ls 25, \
  "pt-oner.dat" u 1:($18*100) t 'SVM' w l ls 26, \
  "pt-oner.dat" u 1:($19*100) t '1NN' w l ls 27, \
  "pt-oner.dat" u 1:($20*100) t '20NN' w l ls 28, \
  "pt-oner.dat" u 1:($21*100) t 'RD' w l ls 29, \
  "pt-oner.dat" u 1:($22*100) t 'K*' w l ls 30, \
  "pt-oner.dat" u 1:($23*100) t 'MLP' w l ls 31

set origin 0.5, 0
set size 0.5, 1
set xrange [66.905:96.905]
set yrange [0.4:1]
set format y "%g"
set xlabel '1R Accuracy Threshold'
set ylabel 'AUC'
set key left bottom

plot "pt-oner.dat" u 1:24 t 'Zero-R' w l ls 1, \
  "pt-oner.dat" u 1:25 t '1R' w l ls 2, \
  "pt-oner.dat" u 1:26 t 'NB' w l ls 3, \
  "pt-oner.dat" u 1:27 t 'DT' w l ls 4, \
  "pt-oner.dat" u 1:28 t 'LR' w l ls 5, \
  "pt-oner.dat" u 1:29 t 'SVM' w l ls 6, \
  "pt-oner.dat" u 1:30 t '1NN' w l ls 7, \
  "pt-oner.dat" u 1:31 t '20NN' w l ls 8, \
  "pt-oner.dat" u 1:32 t 'RD' w l ls 9, \
  "pt-oner.dat" u 1:33 t 'K*' w l ls 10, \
  "pt-oner.dat" u 1:34 t 'MLP' w l ls 11, \
  "pt-oner.dat" u 1:35 t 'Zero-R' w l ls 21, \
  "pt-oner.dat" u 1:36 t '1R' w l ls 22, \
  "pt-oner.dat" u 1:37 t 'NB' w l ls 23, \
  "pt-oner.dat" u 1:38 t 'DT' w l ls 24, \
  "pt-oner.dat" u 1:39 t 'LR' w l ls 25, \
  "pt-oner.dat" u 1:40 t 'SVM' w l ls 26, \
  "pt-oner.dat" u 1:41 t '1NN' w l ls 27, \
  "pt-oner.dat" u 1:42 t '20NN' w l ls 28, \
  "pt-oner.dat" u 1:43 t 'RD' w l ls 29, \
  "pt-oner.dat" u 1:44 t 'K*' w l ls 30, \
  "pt-oner.dat" u 1:45 t 'MLP' w l ls 31

unset multiplot
