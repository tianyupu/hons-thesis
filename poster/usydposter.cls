%%
%% This is file `usydposter.cls'
%% 
%% Author: Tim Dawborn <tim.dawborn@sydney.edu.au>
%% Revised: 26/09/2014 by Tianyu Pu <tianyu.pu@sydney.edu.au>
%%
\ProvidesClass{usydposter}[2010/05/08]
\NeedsTeXFormat{LaTeX2e}
\LoadClass{article}

\newlength{\poster@top}
\newlength{\poster@bottom}
\newlength{\poster@left}
\newlength{\poster@right}

\newlength{\poster@logopad}
\newlength{\poster@blueboxheight} % adjustment factor for height of blue box
\newlength{\poster@sydoffset}
\newlength{\poster@logowidth}
\newlength{\poster@logoheight}
\newlength{\poster@logooffset}

\newlength{\poster@titlewidth}

% bit of a hack to get portrait/landscape mode going
\def\poster@direction{portrait}

\setlength{\poster@top}{35mm}
\setlength{\poster@bottom}{35mm}
\setlength{\poster@left}{42mm}
\setlength{\poster@right}{42mm}

\setlength{\poster@logopad}{15mm}

% update this to adjust the height of the blue heading box
\setlength{\poster@blueboxheight}{1cm}

\setlength{\poster@sydoffset}{28mm}
\setlength{\poster@logowidth}{85mm}
\setlength{\poster@logooffset}{5mm}

\setlength{\poster@titlewidth}{420mm}

\setlength{\columnsep}{20mm}

\DeclareOption{portrait}{\relax}
\DeclareOption{landscape}{%
  \def\poster@direction{landscape}
  \setlength{\poster@titlewidth}{667mm}
}
\DeclareOption{conference}{%
  \def\poster@direction{landscape}
  \setlength{\poster@titlewidth}{667mm}
  \setlength{\poster@top}{15mm}
  \setlength{\poster@bottom}{15mm}
  \setlength{\poster@left}{25mm}
  \setlength{\poster@right}{25mm}
  \setlength{\columnsep}{20mm}
}
\ProcessOptions

\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{calc}
\usepackage{color}
\usepackage{fontenc}
\usepackage[paper=a1paper,\poster@direction,noheadfoot,ignoreall,centering,
  top=\poster@top,left=\poster@left,right=\poster@right,bottom=\poster@bottom]{geometry}
\usepackage{pgf}
\usepackage{multicol}

%\usepackage{colours}
\definecolor{usydblue}{RGB}{0,152,219}
\definecolor{usydred}{RGB}{206,17,38}

% page style
\pagestyle{empty}
\pagecolor[rgb]{1.0,1.0,1.0}
\color{black}

% fonts
\renewcommand{\encodingdefault}{T1}
\renewcommand{\familydefault}{phv}
\renewcommand{\seriesdefault}{m}
\renewcommand{\shapedefault}{n}
\usefont{T1}{phv}{m}{n}

% font sizes
\renewcommand{\tiny}{\fontsize{12}{14}\selectfont}
\renewcommand{\scriptsize}{\fontsize{14.4}{18}\selectfont}   
\renewcommand{\footnotesize}{\fontsize{17.28}{22}\selectfont}
\renewcommand{\small}{\fontsize{20.74}{23}\selectfont}
\renewcommand{\normalsize}{\fontsize{23}{25}\selectfont}
\renewcommand{\large}{\fontsize{28}{00}\selectfont}
\renewcommand{\Large}{\fontsize{35.83}{45}\selectfont}
\renewcommand{\LARGE}{\fontsize{43}{54}\selectfont}
\renewcommand{\huge}{\fontsize{51.6}{64}\selectfont}
\renewcommand{\Huge}{\fontsize{61.92}{77}\selectfont}

\pgfdeclareimage[width=\poster@logowidth]{logo}{usyd-primary-reversed.png}
\settoheight{\poster@logoheight}{\pgfuseimage{logo}}

% page numbering
\pagenumbering{arabic} % needed even though will not be used

% sections
\renewcommand{\section}{\@startsection
    {section}{1}{0mm}%
    {-0.3\baselineskip}%
    {0.6\baselineskip}%
    {\fontsize{28}{30}\selectfont\bfseries\color{usydblue}}}
\renewcommand{\thesection}{\arabic{section}.}

\renewcommand{\subsection}{\@startsection
    {subsection}{2}{0mm}%
    {-0.5\baselineskip}%
    {0.3\baselineskip}%
    {\fontsize{24}{27}\selectfont\bfseries\color{black}}}
\renewcommand{\thesubsection}{\arabic{section}.\arabic{subsection}.}

% figures
\renewenvironment{figure}{%
    \stepcounter{figure}
    \renewcommand\caption[1]{\\{\small\textbf{Figure \arabic{figure}:} \textit{##1}}}
    \begin{center}
  }{%
    \end{center}
  }

% tables
\renewenvironment{table}{%
    \stepcounter{table}
    \renewcommand\caption[1]{\\{\small\textbf{Table \arabic{table}:} \textit{##1}}}
    \begin{center}
  }{%
    \end{center}
  }

% references
\newcommand{\references}{\fontsize{20}{22}\selectfont \bibliographystyle{abbrv}}

% make the header
\newcommand{\makeheader}{%
  \def\titlefont  {\color{white}\fontsize{54}{60}\selectfont}
  \def\authorfont {\color{white}\fontsize{40}{40}\selectfont\itshape}
  \def\facultyfont{\color{white}\fontsize{28}{32}\selectfont}
  \noindent\begin{pgfpicture}{0cm}{-\poster@blueboxheight}{\textwidth}{\poster@blueboxheight+9.5cm}
    % blue rectangle
    \color{usydblue}
    \pgfrect[fill]{\pgfpoint{\poster@sydoffset}{-\poster@blueboxheight}}{\pgfpoint{\textwidth - \poster@sydoffset + \poster@logopad}{\poster@blueboxheight+9.5cm}}
    % red rectangle
    \color{usydred}
    \pgfrect[fill]{\pgfpoint{-\poster@logopad}{4.2cm}}{\pgfpoint{\poster@logowidth + 2\poster@logopad}{5.3cm}}
    % logo
    \color{black}
    \pgfputat{\pgfpoint{0cm}{5.3cm}}{\pgfuseimage{logo}}
    % poster title
    \pgfputat{\pgfpoint{11cm}{8.5cm}}{\pgfbox[left,top]{%
      \titlefont
      \parbox{\poster@titlewidth}{\raggedright\MakeUppercase{\postertitle}}}
    }
    % poster author
    \pgfputat{\pgfpoint{11cm}{2.8cm}}{\pgfbox[left,bottom]{%
      \authorfont
      \parbox{\poster@titlewidth}{\posterauthor}
    }}
    % poster faculty
    \pgfputat{\pgfpoint{11cm}{-0.4cm}}{\pgfbox[left,bottom]{%
      \facultyfont
      \parbox{\poster@titlewidth}{\posterschool\newline\posterfaculty}
    }}
  \end{pgfpicture}
}

% macros which users should redefine
\newcommand{\postertitle}{Title of your talk}
\newcommand{\posterauthor}{Joe Blogs}
\newcommand{\posterschool}{\textit{Irena Koprinska} \\ School of Information Technologies}
\newcommand{\posterfaculty}{Faculty of Engineering and Information Technologies}

\renewcommand{\title}[1]{\renewcommand{\postertitle}{#1}}
\renewcommand{\author}[1]{\renewcommand{\posterauthor}{#1}}

% vim: set ft=tex et ts=2 sts=2 sw=2:
