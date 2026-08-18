
/*

Plan:

# Introdução

## DDR e PIU
### O que são
- DDR: 1998
- PIU: 1999

### Diferenças
- 5 teclas
- culturas de charts
- janelas de tempo

### Charts
- stepmania
- stepf1 stepp1+ .ssc .sm

# Background

## Processamento de Áudio
- Som é onda no ar
- Intensidade = (Energia / Segundo) / Área ~= p²
- Decibel entre a, b = log10(a/b)
- Transformada de fourier
- Escala mel
- Features = log10(mel(FFT(audio)))

## Machine learning
- Definição
- Regressão linear
- Gradient descent
- Unidade sigmoide
- Regressão Logística
- Multilayer perceptron
- Backpropagation
- Autograd
- Convolução
- RNN
- BPTT
- Gates: LSTM, GRU
- Encoder-Decoder

# Desenvolvimento
- Objetivo: repicar DDC, DDCL, expandir
- Implementar gerador de cahrts (incluir PIUCENTER)

## Processamento de dados
- Dataset: phoenix, resistance simfiles
- parsing: msdparser
- atributos: bpms, offset, notes
- measures, beats
- gimmicks, stops, speed, warps
- conversão de beats em segundos
- lista de bpms
- mirroring horizontal/vertical

## Extração de áudio
- essentia
- stft - 3 janelas /canais: Nx80x3

## Implementação de DDC
- Placement e selection

### Placement/onset: cnn e lstm
- shuffling do dataset
- binary search

- padding out of bounds com minimo
- adam lr = 0.001, lambda = 0.0001
- dificuldade: 1..25
- performance: ok

### Selection: LSTM
- bag-of-arrows, one-hot
- delta time

### Resutlados
- performance parecida com DDC original
- F1 e AUC alinhado a 20ms para placement
- accuracy de selection: 80%

opinição pessoal:
- steps colocados em momentos etranhos
- steps colocados em fins de holds
- não gera charts adequados com níveis
- não gera crossovers
- charts repetitivos sem informação musical (ex: orbit)
- mas gera charts!

*/

#let fixme(thing) = thing
#let towork(thing) = thing

#import "stuff.typ": template
#import "@preview/algo:0.3.6": algo, i, d, comment, code

#show: template

#set align(center)

#grid(
  columns: 1fr,
  rows: (1fr, 1fr, 1fr, 1fr, auto),
  [
    #align(center, text(14pt)[
      UNIVERSIDADE DE SÃO PAULO

      INSTITUTO DE MATEMÁTICA E ESTATÍSTICA

      BACHARELADO EM CIÊNCIA DA COMPUTAÇÃO
    ])
  ]
  ,
  [
    #text(17pt)[ *Learn it Up* ]

    #text(14pt)[ Renan Ribeiro Marcelino ]
  ]
  ,
  [
    #text(17pt)[ MONOGRAFIA FINAL ]

    #text(17pt)[ MAC0499 -- TRABALHO DE FORMATURA SUPERVISIONADO ]
  ],
  [
    #text(17pt)[ Supervisor: Ronaldo Fumio Hashimoto ]
  ],
  [
    #text(14pt)[ 
      São Paulo

      2026
    ]
  ]
)

#set align(start + top)
#set par(justify: true)

#pagebreak()
#pagebreak()


#let my_summary_page(title: [], reference: [], description: [], keywords: []) = [

  #align(center)[
  #text(17pt)[ #title ]
  ]

  #block(inset: (left: 1.5cm, right: 1.5cm))[
  #reference
  ]

  #description

  #keywords
]

#my_summary_page(
  title: [ *Resumo* ],
  reference: [
    
Renan Ribeiro Marcelino. *Learn it Up*. Monografia (Bacharelado).
Instituto de Matemática e Estatística, Universidade de São Paulo, São Paulo, 2026.
  ],
  description: [

Pump it Up é um jogo de ritmo onde o objetivo consiste de
apertar botões em formatos de setas em um tapete eletrônico,
de acordo com setas exibidas na tela do jogo em sincronização
com uma música sendo tocada. Este jogo é similar ao jogo DanceDanceRevolution, de quatro
teclas, mais popular no Japão e Estados Unidos, enquanto Pump it Up é
mais famoso em outras regiões do mundo como Brasil e Coréia do Sul.

Atualmente, existem múltiplos papers estudando a viabilidade
de uso de aprendizado de máquina para a geração de níveis de DanceDanceRevolution, mas
nenhum deles aproveita a oportunidade para nalisar a viabilidade
disto no jogo Pump it Up, que possui mecânicas, velocidades, e granularidade de níveis
distintos do DanceDanceRevolution.
Este trabalho tem como objetivo produzir o melhor programa de geração de níveis de Pump it Up
até o momento, adaptando os papers _DanceDanceConvolution_, _DanceDanceConvLSTM_ e utilizar o
dataset _PIUCenter_ na geração de charts.
    
  ],
  keywords: [
  *Palavras chave*: Dance Dance Revolution, Pump it Up, Aprendizado de máquina, Aprendendo a coreografar.
  ]
)



#pagebreak()

#my_summary_page(
  title: [ *Abstract* ],
  reference: [
    
Renan Ribeiro Marcelino. *Learn it Up*. Capstone Project Report (Bachelor).
 Institute of Mathematics and Statistics, University of São Paulo, São Paulo, 2026.
],
  description: [

Pump it Up is a rhythm game that consists of
pressing arrow shaped buttons in a dance floor, according to
arrows being displayed in the game's screen in synchronization
to a music playing in the background.
This game is similar to DanceDanceRevolution, which is more popular in Japan and United States, while
Pump it Up is more played in other regions of the world, such as Brazil and South Korea.

As of today, there are multiple papers studying the applicability of machine learning for generating DanceDanceDanceRevolution
levels, but none of them take the opportunity to apply this to Pump it Up,
which has similar but different mechanics and difficulty granurality from DanceDanceRevolution,
on top of using five arrows buttons, unlike the more famous game, which uses four.

This project aims to build the best Pump it Up level generation program, adapting
the existing papers DanceDanceConvolution and DanceDanceConvLSTM and integrating the PIUCenter dataset to level generation.

],
  keywords: [
  *Keywords*: Dance Dance Revolution, Pump it Up, Machine Learning, Learning to Coreograph
  ]
)

#pagebreak()

= List of Figures

WIP.

#pagebreak()

= List of Abbreviations

WIP.

In this work:
- Function composition is of the form $(f compose g)(x) = g(f(x))$.
- The jacobian deriative of a function $f$ is denoted as $J[f]$.
- Given vectors $x, y in RR^n$, $x dot.o y$ is the hadamard product of $x$ and $y$,
that is, $(x dot.o y)_i = x_i dot y_i$.

#pagebreak()

= Contents

WIP.

#pagebreak()

#pagebreak()

= Chapter 1 \ Introduction

The goal of this section is to familiarize the reader with the games studied by this project.

DanceDanceRevolution (DDR) is a rhythm game published by the japanese company Konami
in the year 1998 in Japan and 1999 in United States and Europe.
Pump it Up (PIU), is made by the south korean company Andamiro,
and was released in 1999 in South Korea and 2001 for the rest of the world.

Both games consist of pressing arrow shaped buttons in a dance floor, according to
arrows being displayed in the game's screen, in synchronization to a music playing in the background.
The arrows appear from the bottom of the screen, and scroll up until they reach a fixed panel of arrows known as the receptors.
When the arrows reach these receptors, the player is expected to press the buttons labeled with the corresponding arrows, and then
receive a judgement based on the time accuracy of their step, such as "Perfect", "Great" or "Miss".
The arrows in a level are typically placed according to the of rhythm of the music currently playing, both in their timing and arrow sequence.
The set of arrows that play in a level is known as a _chart_, and the process of creating one for a given music is known as _charting_.
Both games provide dozens of music to play, with each music providing multiple charts of varying difficulty.
@two_ddr and @two_piu show images of people playing both games.


#figure(
  image("two_ddr.jpg", width: 50%),
  caption: [Image of two people playing on a DanceDanceRevolution arcade machine.]
) <two_ddr>

#figure(
  image("two_piu.jpg", width: 50%),
  caption: [Image of two people playing on a Pump it Up arcade machine.]
) <two_piu>

Although very similar, there are important differences between these two games,
the main one being the dancing pad layout:
DDR uses four arrows (left, down, up, right) whereas PIU uses five (down left, up left, center, up right, down right), with DDR's pad arrows
being square shaped and placed in the cardinal corners of a 3x3 grid of squares,
while in Pump it Up only the center key being a square, and the corner arrows being more vertical rectangles.
@ddr_pad and @piu_pad show images of pads of boths games.

#grid(
  columns: (1fr, 1fr),
  rows: (1fr),
  [
    #figure(
      image("ddr_pad.png", width: 80%),
      caption: [Image of a Dance Dance Revolution dance pad.]
    ) <piu_pad>
  ],
  [
  #figure(
    image("piu_pad.jpg", width: 80%),
    caption: [Image of a Pump it Up dance pad.]
  ) <ddr_pad>
  ]
)

This layout difference results in a different "culture" of charts, with Pump it Up having a greater variety of technical arrow patterns,
while DDR focuses on fast streams of notes, having a strictier time window for steps.

Another important difference between these games is regarding "holds", which are long arrows that
indicate that the player should hold the button associated with the arrow for a longer period of time.
In DDR, the player must press the button when
the top of the arrow hits the receptor. Releasing it
before the bottom of the arrow hits the receptor
counts as a single miss.
In PIU, the hold arrow counts as a multiple arrows that are scored continuously as
player is holds them during the long arrow.
Because of this, hold arrows are of greater importance in PIU, and missing them has
a greater impact in the final score. In some cases, this mechanic allows the player to quickly
release the hold step and press it again, if done during the interval between
two scoring ticks of the hold arrow. Many charts take this mechanic deliberately into consideration.

Another difference is that unlike DDR, PIU
does not require the player to hit the button when the hold arrow hits
the receptor, it is ok if the player is already holding the arrow button
before the hold arrow arrives.
This allows for some charts to add cosmetic streams of fast hold notes notes, that effectively
count as a single hold note.

TODO: Add image of hold arrows.

Although both games received ports to consoles such as Playstation 2, these games
are mostly played on arcade machines, or in personal computers through the
dance rhythm game emulator Stepmania and its forks.

Despite being simple games, they can present enjoyable challenges for players of all skill levels.
Charts have a wide range of difficulties. In DDR, charts are rated as Begginner, Easy, Medium, Hard and Challenge, whereas
Pump uses a numeric score for chart difficulty, usually ranging from 1 to 25.
The difficulty affects both the frequency of steps in a chart, with harder levels having more steps,
as well as the sequence of steps, with higher levels having more complex patterns.

== Motivation

Altough Pump it Up has a wide variety of songs, players often desire to play
songs that are not available in Pump. Players are often interested in playing songs of musical
genres  that are not available in the main game series, (which limits itself mostly to classical, k-pop and electronic music),
or songs of genres that are covered by Pump it Up, but are not available in the game, partly due to copyright licensing.

Players that own a Pump it Up or DanceDanceRevolution pad can build their own charts for songs by using
software such as #link("https://github.com/uvcat7/ArrowVortex")[ArrowVortex],
but this is a complex process, that requires both considerable amounts of time and expertise in the game, to build fun and coherent charts.
On top of that, considering DDR is more famous overall than Pump it Up, fan-made DDR charts are more easily accesible online.

There are already multiple papers that study the development of machine learning models for the generation of DanceDanceRevolution charts,

namely DanceDanceConvolution @ddc (DDC), DanceDanceConvLSTM @ddcl (DDCL) and
Yi2023 @yi2023, but to our knowledge, there have been no academic studies that cover machine learning generation of Pump it Up charts.

Additionally, Pump it Up has a database #link("https://www.piucenter.com/")[piucenter] that classifies, for every Pump it Up chart, the different
kinds of styles that are present in the chart. This information can help training models that are more well directed in particular charting styles,
as mentioned as a potential improvement in the paper DDCL:

#quote(attribution: [DanceDanceConvLSTM])[
  The Fraxtil dataset
  contains a mixture of technical and stream based
  charts, which likely creates some confusion in
  the training process. Future models may benefit
  from selecting a charting discipline and training
  a model particular to that task.
]

Our primary goal is to compare existing methodology in generative charting for Pump it Up, and to build the best Pump it Up chart generator so far.
We aim to implement a Pump it Up replication of the papers DanceDanceConvolution (DDC) and DancedDanceConvLSTM (DDCL), Yi2023 is considered to be out of scope,
since it involves pre-training on charts from another rhythm game osu!mania.

#pagebreak()

= Chapter 2 \ Background

The goal of this section is to provide a gentle introduction to the main concepts used in this project.

== Audio Intensity

This section paraphrases Bergstra2006 @bergstra2006 which studies algorithms for classifying recorded music by genre.

Sound is a wave that travels primarily through air, its vibrations cause oscilations in pressure that can be detected by microphones and organisms. Microphones continuously measure the changes in pressure caused by sound, and computers record these
measured values multiple times per second. This is known as Pulse Code Modulation (PCM) and files derived from this process are typically stored in formats such as `.wav` or `.pcm`.

Like any wave in physiscs, sound carries some energy as it travels, 
and its intensity is defined as the amount of energy transfered by it to a fixed surface over a fixed time period.
Intensity is expressed as $I = "Power" / "Area"  = "Pressure" dot "Velocity"$. In air, sound's pressure is proportional to its velocity,
so intensity is proportional to the square of the presure, $I prop "Pressure"^2$.
Therefore, when dealing with PCM audio samples, the energy/intensity of a wave is computed as $"Pressure"^2$.

Humans beings perceive sound loudness in a logarithm scale, meaning multiplicative
increments  in intensity result in constant increments in perceived loudness. Because of this,
the decibel relative unit is used to compare sound intensities in terms of human perception. The decibel units of a wave $a$ compared to another wave $b$ is defined
as $ L = 10 log_10 (I_a / I_b) = 20 log_10 (p_a / p_b) $

where $I_a$, $I_b$, $p_a$, $p_b$ are the intensities and pressures of $a$ and $b$ respectively. When using
a specific reference intensity for $I_b$, $L$ represents the loudness of the sound
in the Phon scale.

== Audio Frequency

While the intensity of a sound wave determines its loudness, the details of the sound, such as musical notes, are determined by the wave's oscillation frequency. 
Given a the signal of a wave over a time interval, the operation that
tells us the frequencies present in the signal, their intensities,
and their phase/alignments
is the Fourier Transform. This operation can be interpreted both in terms of
calculus or in terms of probabily/statistics, where it is known as the characteristic function.

If one interprets a signal $f$ as a probability function of a random variable $X$,
the presence of a certain frequency $q$ in the signal could be measured by how
well the random variable "aligns" with the frequency. That is, how much, in
average, the subtraction of samples of the random variable will near values
that are integer multiples of $q$.

For instance, if taking multiple
samples of a random variable $X$ and subtracting them results in values that
are near integers, this is an indication that $X$ is well aligned to the interval $1$.
If subtracting samples results in values that are multiples of two, this indicates
that the random variable aligns well to the interval $2$ (and thus, to frequency $0.5$).

A natural choice for a function that measures how close to an integer
 is a value, is the cosine function, more specifically $cos(2 pi dot x)$,
which equals $1$ at integers and $-1$ at values ending in "$.5$". This can
be generalized to other frequencies $q$ with $cos(q dot 2 pi dot x)$.

Therefore, the value that describes the alignment of a random variable $X$
to a frequency $q$ is the expected value of the cosine of the subtraction of
independent samples of the distribution of $X$, expressed as:

 $ bb(E)[cos(q dot 2 pi (X_1 - X_2))] $

Applying the identity $cos(a - b) = cos(a) cos(b) + sin(a) sin(b)$ and the
linearity of the expectation operator for independent variables
($bb(E)[A + B dot C] = bb(E)[A] + bb(E)[B] dot bb(E)[C]$) we get:

 $ bb(E)[cos(q dot 2 pi (X_1 - X_2))] = \
   bb(E)[cos(q dot 2 pi X_1)cos(q dot 2 pi X_2)
    + sin(q dot 2 pi X_1)sin(q dot 2 pi X_2)] = \
   bb(E)[cos(q dot 2 pi X_1)]bb(E)[cos(q dot 2 pi X_2)]
    + bb(E)[sin(q dot 2 pi X_1)]bb(E)[sin(q dot 2 pi X_2)] = \
   bb(E)[cos(q dot 2 pi X)]^2 + bb(E)[sin(q dot 2 pi X)]^2 \
 $

which can be expressed as a vector/complex norm:

$
   bb(E)[cos(q dot 2 pi X)]^2 + bb(E)[sin(q dot 2 pi X)]^2
= \   norm( lr(chevron.l  bb(E)[cos(q dot 2 pi X)] , bb(E)[sin(q dot 2 pi X)] chevron.r) )^2
= \ norm(  bb(E)[cos(q dot 2 pi X)] + i bb(E)[sin(q dot 2 pi X)]  )^2
= \ norm(  bb(E)[cos(q dot 2 pi X) + i sin(q dot 2 pi X)]  )^2
= \ norm(  bb(E)[e^(i q 2 pi X)]  )^2
$

The value $bb(E)[e^(i q 2 pi X)]$ is known as the characteristic of $X$ at frequency $q$ and is denoted as $phi_X(q)$. The norm of this vector/complex number tells us
about the alignment of the random variable $X$ to frequency $q$, and the direction
of this vector tells us about the alignment/phase in the frequency. If $X$ is a
continuous random variable with probability function $f$, this is said to be the Fourier Transform of $f$. If $X$ is a discrete random variable with probability function $f$, this is said to be the Discrete-Time Fourier Transform of $f$.

If $X$ is random variable limited to integers from 0 to $N-1$,
the Discrete Fourier Transform (DFT) of $f$ is a vector with $N$ entries
containing samples of the Discrete-Time Fourier Transform of $f$ at frequencies
($0$, $1/N$, ..., $(N-1)/N$). The algoriths used to efficiently compute the Discrete Fourier Transform of the signal are known as Fast Fourier Transforms (FFT).

An important detail of Fourier analysis is that if a frequency of the signal
being sampled is much higher than the frequency in which the samples are being taken,
then this signal frequency will look as if it is much lower than it really is.
If you only measure every 8 years, the Olympic Games will look as if they happen
with the same frequency as the Vienna Biennale or your dog's birthday. This is reflected in Nyquist-Shannon sampling theorem,
which tells us that, for sampling rate $q$, we can only safely measure frequencies up to
$q / 2$, the Nyquist frequency of $q$, without loss of information.

Just like loudness, human beings don't perceive frequency linearly. A change from 440hz to 441hz is
much more noticeable than a change from 4400hz to 4401hz.
The Mel scale is a scale unit of frequency that more closely reflects the human perception, shown in @mel_scale.

#figure(
  image("Mel-Hz_plot.svg.png"),
  caption: [Plots of pitch mel scale versus hertz scale],
  alt: "A plot of the Mel scale in the y axis and Hertz scale in the x axis.
  The y axis ranges from 0 to 3200 mel, whereas the x axis ranges from 0 to 10000 hertz.
  The curve is ascending, and it's slope reduces as it grows, like a logarithm or sqrt function.
  The curve grows fast in the slow frequencies from 0 to 500, with the mel of 500 being 600,
  and begins to slow down after that.
  "
) <mel_scale>

== Machine Learning

This section introduces the basic concepts of machine learning, and
the main architectures used in this work.

In traditional computer science, the most common way to solve a
problem is by designing a specialized algorithm for it, given a specification
of the task at hand.
However, there are many pratical problems for which there are no objective specifications, due to their subjective nature. 
Some common examples of this include object and written digit recognition, time series forecasting, 
text translation, risk classification, among many others.
Machine learning is the process solving a task by using existing data examples of it, without having 
explicit instructions on how to solve the problem, and it is suitable for this kind of application.

Machine learning implementations are modelled as functions, that take input from a set $X$, and return values 
in an output set $Y$.
The core idea, is that the values of $Y$ have some relationship with the input
$X$, represented by a probability $P(X, Y)$. Given a data set of $(X, Y)$ pairs, our goal is to produce a 
function $f: X -> Y$ that respects well this relationship.

In machine learning, this particular framework of problem solving is called supervised learning.
When the set $Y$ represents discrete label values, this is said to be a classification problem,
with the special case of $Y = {0,1}$ being known as binary classification.
Otherwise (given a continuous $Y$), this is said to be solving a problem of regression.
The process of producing a model function $f$ given a dataset of examples $S in (X times Y)^n$ is called training, and the process 
of trying to infer $y in Y$ using $x in X$ (i.e computing $y = f(x)$) is called inference.

In this work, all machine learning models will be tasked primarily with classification.

=== Model evaluation

Although the problems suited for machine learning usually have no objective specification, 
it is still possible to evaluate the quality of
a model $f$, given a set of examples. The most fundamental metric concept in machine learning is the
loss function. A loss function $ell$ takes a predicted output $y_"pred"$  and an expected output $y in Y$ and returns a 
nonnegative real number $ell(y_"pred", y)$ that tells how badly $y_"pred"$ matches $y$, with $0$ usually implying $y_"pred" = y$, 
and its output grows as the prediction worsens. Although $Y$ is discrete in classification problems, $Y$ is often
contained in $RR^n$ for some $n in NN$, and the loss function is usually continuous in the $y_"pred"$ parameter.
Given a dataset $S$, and a loss function $ell$, the primary goal of training is selecting a model function $f$
that minimizes the average loss of $ell$ in the set.

The most common loss functions are:
- The squared error loss, used for classification or regression $ ell(y_"pred", y) = (y_"pred" - y) ^ 2 $
- The binary cross entropy loss, specialized for binary classification $ ell(y_"pred", y) = -[y log y_"pred" + (1 - y)log(1 - y_"pred")] $

Although the loss function is useful for training, practical evaluation of classification models is done with more interpretable metrics. 
Given a set of examples $S$, the accuracy of a model $f$ is defined as the percentage of examples in the set that 
are correctly predicted by the model, i.e 
$ "Accuracy" = 1 / (|S|) |{x,y in S : f(x) = y}| $

In binary classification (when $Y$ is ${0, 1}$), other important metrics are:
- *Precision*: How accurate is the model when $y_"pred" = 1$; 
$ "Precision" = {x,y in S : f(x) = y = 1} / {x, y in S : f(x) = 1} $
- *Recall*: How accurate is the model when $y = 1$; 
$ "Recall" = {x,y in S : f(x) = y = 1} / {x, y in S : y = 1} $
- *F1*: The harmonic mean of precision and recall.
$ F_1 = 2 / ("Precision"^(-1) + "Recall"^(-1)) = 
2 ("Precision" dot "Recall") / ("Precision" + "Recall") $

In order to properly evaluate a model's generalization (its capability to generalize its behavior to examples outside of its training set), it is often common to use
an auxiliary dataset, sharing the same overall distribution with the training set, but not used in training, to apply model evaluations.
This is known as a  valididation or test set, and it is usually done by partitioning the full example set, with a certain percentage
of examples being used for testing/validation, and the rest for training. The term "validation set" is typically applied
when it is used during the development of the model under training, and "test set" when it is applied to 
measure the final performance of the model, with validation set and testing set usually being distinct partitions.

When a model has a measurely better performance when evaluated in its training set, compared to its validation set, we say that it is overfitting.
When a model has a bad performance in its own training set, we say that it is underfitting (not learning).

=== Introductory Algorithms

One of the most simple machine learning implementation strategies is to look up examples in the training set that are similar to the model input $x$, and
use that information to decide the model output $f(x)$. This is known as the k-Nearest-Neighbours algorithm, where the "neighbours" are
the training set examples similar to $x$ used for comparison, and $k$ is the number of neighbors to be compared. 
It requires no previous processing of the training set, which makes it easy to implement, but also unreliable for large datasets, since inference
requires access to the training set itself.
It is typically associated with classification, with the most frequent label values 
within the neighbours of an input $x$ determining the output of $x$,
but it can also be used for regression by, for instance, averaging the neighbours output value (interpolation).

Another well known regression algorithm in machine learning is linear regression.
In this implementation, given an input $x in RR^n$ and continuous output $Y subset RR$, the model output $f(x)$ is $f(x) = b + sum_(i=1)^n w_i x_i = b + w dot x$
where $w in RR^n$ and $b in RR$, known as weights or parameters, are computed from the training set, with $w$ being known as the input weights, and $b$ as the bias. 

This strategy can also be used for binary classification, where model the output $f(x)$ is 1 if $b + w dot x > 0$, and $0$ otherwise.
A classification model of this kind is known as a linear classifier, which can be useful for their simplicity, 
but also insufficient for some applications. A well known result in machine learning is that there is no linear classifier of two variables 
$f : {0, 1}^2 -> {0,1}$ that can model the exclusive-or function.

When the target values $Y$ are real numbers in the $[0,1]$ range, this model can be adapted into another one named logistic regression, in which the 
model output is $f(x) = sigma(b + w dot x)$ where $sigma(x) = 1 / (1 + exp(-x))$ is known as the sigmoid function, graphed in @sigmoid. 


#figure(
  image("sigmoid.png", width: 50%),
  caption: [Graph of the sigmoid function $sigma(x) = 1 / (1 + exp(-x))$, it translates the real line into the $(0, 1)$ interval],
  alt: "A graph of the sigmoid function, from -6 to 6. 
  This function's domain is the real number line.
  The minus infinity limit of this function is 0, 
  the plus infinity limit of this function is 1.
  This function is continuous, smooth and monotone increasing." 
) <sigmoid>

=== Neural Networks

A neural network is a function from features and parameters into prediction 
output values that is differentiable with regard to the model parameters.
The output from such networks consists of reals numbers, not $Y$ label themselves, 
but this can be adapted for binary classification by 
applying thresholding to the output $f(x) in RR$ (like for linear classifiers), 
or in the case of multiple $m$ classes, 
by interpreting the model output $f(x) in RR^m$ as probability estimates of each class,  
and choosing the class with the greatest value in the vector $f(x) in RR^m$.

A neural network is organized as a composition of differentiable functions 
known as units, or neurons, whose output indicates the presence of a certain 
characteristic in the input.
The output of a typical unit has the form $phi(w dot x + b)$ where 
$x in RR^k$ are the inputs of the unit,
$w in RR^k$ and $b in RR$ are parameters of this unit, and $phi$ is known as 
the activation function.

Activations functions allow for greater flexibility in neural networks, 
because without activation functions, units would become linear functions, and the composition of linear functions is linear, so the entire network
would be equivalent to a linear regression, and the resulting classifier would be a linear classifier.
Common choices of $phi$ include $sigma(z) = 1/(1+ exp(-z))$, $tanh(z) = (exp(2z) - 1) / (exp(2z) + 1)$, and 
and the linear rectifier, $"ReLu"(x) = max(0, x)$.
Choosing $phi$ as the sigmoid function $sigma(x) = 1/(1 + exp(-x))$, yields a unit identical to logistic regression, mentioned earlier.

Given a neural network model $M_W : RR^n -> RR^m$ of $p$ weights, 
its weights $W in RR^p$, a dataset $S subset RR^n times RR ^m$, 
and a loss function $ell : (RR^m times RR^m) -> RR$ the average loss of the model over the entire dataset is

#set math.equation(numbering: "1.")

$ "Loss" = 1/N sum_((x,y) in S) ell(M_W (x), y) $ <loss>

This loss value can be seen as the result of a function $ell_W : RR^p -> RR$ that takes the model weights $W$ as argument and returns the 
loss with respect to these weights. 
Since the model function is differentiable with respect to the weights, and the loss functions for neural networks are also differentiable (as seen earlier),
the whole $ell_W$ function is differentiable. 
This allow for the application of the gradient descent training technique, which is the main advantage of neural networks.

Given a differentiable function $f: RR^n -> RR$, and a point $x in RR^n$, the derivative of $f$ regarding the $i$-th input $x_i$
indicates what happens to the result of $f$ if a tiny change $epsilon$ is introduced to $x_i$. 
When this is positive, it means that incrementing $x_i$ increases the resulting value of $f$. 
when this is negative, it means that
decrementing $x_i$ increases the resulting value of $f$. 
The core idea of gradient descent is to decrease the result of $ell_W (W)$ given weights $W$, by nudging the values of $W$ based on the derivative of the $ell_W$ function
for each weight.
A gradient descent update equation is shown in @gd. The constant $alpha$, known as learning rate, represents the length of the step to be applied each iteration,
and $nabla ell_W (W)$ is the gradient vector containing the derivative of the loss with regard to the weights.


$ W^* <- W - alpha dot nabla ell_W (W) $ <gd>

#set math.equation(numbering: none)

This is the essence of the gradient descent update algorithm, but there are many other extensions and variants to this weight update scheme, 
to improve its stability and speed up convergence, such as AdaGrad @adagrad and Adam @adam. 

The weights are not updated after computing the gradient of the average loss over the entire dataset, but instead the dataset is divided randomly into
smaller batches, and the weights updated after computing the loss gradient over each batch $S$. This means that $N$ in @loss is not necessarily the number
of the examples in the whole dataset, but the number of examples in the batch being used for the update. This is known as mini-batch gradient descent,
or when $N = 1$, it is known as stochastic gradient descent.
Regardless of $N$, a gradient descent pass over all samples in the training dataset is known as an epoch.

The algorithm used to compute $nabla ell_W$ on an example in the dataset is named backpropagation. 
A neural network $f$ is typically structured as a composition of multiple layers, 
$f = f_1 compose f_2 compose ... compose f_k$, $f_i : RR^(a_i) -> RR^(b_i)$.
Backpropagation consists of first computing the gradient of the loss with regard to the final layer $f_k$, and then using that to compute the
gradient with regard to the previous layers. 
This can be done using the derivative chain rule, 
$J [x |-> ell(f(x))] = x |-> J [ell] (f(x)) dot J [f] (x)$,
multiplying the gradient regarding $f_(i+1)$ by the derivative of $f_i$, to obtain the gradient regarding $f_i$.

This can be implemented manually, by expressing the derivatives of the layer functions directly in code, 
but there are automatic differentiation libraries like PyTorch which can make this process easier,
by recording the function call graphs and then executing the backpropagation on the result.

The most common kind of layer in neural networks consists of multiple scalar $u$ units processing the same layer input $x in RR^n$. The output
of such layer $f$ is $ f(x) = phi(W x + b) $
where W is a $RR^(u times n)$ matrix with the input weights of each output neuron and $b in RR^u$ is a vector with the biases of each output unit, 
with $phi: RR^u -> RR^u$ being the activation function applied pointwise.
These layers are typically called dense, or linear layers. Implementations often omit $phi$ from this layers,
and treat the activation function as a separate one.

An important concept for the neural networks used in this application, is the notion of a convolutional layer. 
Given a vector/tensor $x in RR^A$ and a vector $k in RR^B$,
the convolution of $x$ and $k$ is denoted by $x * k$ and 
consists of dot products of $k$ with sliding portions of $x$.
More specifically, given an index
$i$, $ (x * k)_i = sum_j x[j] dot k[i-j] $
This operation is typically applied to one or two dimentional vectors, 
and can be used to perform many image and audio processing 
operations to $x$ such as blur and sharpness, depending on the value of $k$, known as the kernel of the operation. 
_But what is a convolution?_ @conv3b1b explains this operation in more detail
with animatated examples.

Convolutional layers in neural networks take 2D tensors as inputs, and apply convolutions to the input with kernels whose values are parameters to be learned. 
Convolutional layers are also typically used with _MaxPool_ layers, that perform a simular task of computing a sliding window operation on the input
tensors, but instead of computing the dot products of the segments of the image with a kernel, 
a max pool layer returns the maximum of these windowed segments.

When performing multi-class classification, a common layer found in neural networks is the softmax layer.
A softmax layer takes an input $x in RR^n$ and returns $"softmax"(x) in RR^n$, where
$ "softmax"(x)_i = e^(x_i) / (sum _(j = 1) ^N e^(x_j)) $
The primary effect of a softmax layer, is that it returns a list of values in the $[0, 1]$ range,
and the entries of the returned vector sum up to 1, making it suitable for final output layers, as it can be interpreted as an
estimated probability distribution over the classes.

=== Regularization 

Neural networks can achieve considerable performance on machine learning classification tasks,
but, may present overfitting on their training data.
There are many stategies to address this effect, known as regularization techniques.

#let lh = $accent(l, hat)$

L2 regularization, also known as weight decay, tries to limit the value of the weights in the neurons,
by penalizing high weights in the application of the loss function. This is done by using a modified loss function $lh$ instead of the original loss function $ell$,
which returns
$ lh (y_"pred", y) = ell(y_"pred", y) + lambda / (2 N) ||W||^2 $
Where $W in RR^p$ are the weights of the model, $||v||$ is the euclidean norm, 
and $lambda$ is the regularization parameter, that defines how much the model should be penalized for large weights.

Another, more common strategy for regularization is known as dropout. 
Instead of changing the training routine, it introduces a new layer in the network architecture itself.
A dropout layer, during evaluation/inference, takes an input $x in RR^n$ and returns $x$ unmodified, behaving as an identity transformation.
However, during training, a dropout layer randomly zeroes some of the elements of the input tensor, with probabilty $p in [0, 1]$.
This allows the trained networks not to be too reliant on the value of the neuron activations after a dropout layer, improving generalization performance.

// TODO: add references to dropout papers and regularization papers

// TODO: talk about normalization layers and residual connections if necessary

=== Recurrent neural networks and Long Short Term Memory

#let xx = $upright(bold(x))$

The neural networks covered so far all receive an input $x in RR^n$ of fixed size $n$, apply multiple transformation
layers to it, and return an output $y in RR^m$.
A network of this kind is known as a feedfoward network.
These networks are useful for tasks of fixed-size input such as image classification, 
but for some problems,
such as text processing, language translation, weather forecast and audio processing, the input for the network has a different
structure, consisting of a sequence $xx = (x_1, x_2, ..., x_T)$ of vetors $x_i in RR^n$.
Recurrent neural networks (RNN) were designed to solve this kind of task.

A recurrent neural network consists of a unit function $u$:
that receives two inputs $x in RR^(n_x)$ and $s in RR^(n_s)$ and returns
two outputs, $y in RR^(n_y)$ and $s^* in RR^(n_s)$, $ (y, s^*) = u(x, s) $
$s$ represents the current execution state of the network,
$x$ represents the current input in the sequence, $y$ represents the network output and $s^*$ represents the modified state
after processing the current input. This function $u$ is applied for every input $x_t$ in the sequence $xx$, and the state returned
after processing input $x_t$ is used as the state passed to the next input $x_(t+1)$. @rnn shows two diagrams of RNNs,
with the unrolled graph making the flow of states between steps explicit.
Recurrent neural networks can also be trained with backpropagation, by adding the gradient of the model weights over each unrolled step, 
a process known as backpropagation through time.

#figure(
  image("rnn.png"),
  caption: [Diagram of a recurrent neural network, 
  in compressed form (left) and unfolded form (right). ]
) <rnn>

Recurrent networks can be used with a direct feedfoward structure for the unit function $u$, 
but this generally leads to problems with gradient descent, since for an input of large size $T$, 
this is equivalent to running a feedforward network with $T$ layers, 
and since each layer multiplies its function's derivative $J[u]$ to the derivative of its previous layer,
the derivatives for early layers scales to $J[u]^T$, so for entries greater than 1, their derivatives tend to infinity, 
and for entries less than 1, they tend to 0. This is known as the exploding/vanishing gradient problem.

#let ctilde = $accent(c, ~)$

Long Short Term Memory (LSTM) is an RNN architecture built to address this problem 
and improve model flexibility. 

In LSTM and similar constructions, gates are intermediary values in the computation of the recurrent unit's output that 
add control over which values will be used for the new state and the unit's output.
In the case of the traditional LSTM with forget gates @lstm2, there are three gates:
- The forget gate $f$ is a mask that determines how much of the previous state $c$ will be kept or forgotten in the current step.
- The input gate $i$ is a mask that determines whether or not entries of a computed change vector $ctilde$ should be added to state.
- The output gate $o$ is a mask that determines the entries of the state that are revelant for the next steps. 

#pagebreak()
These gates are used in a LSTM unit according to the following equations:

$ f_t & = sigma(W_f x_t + U_f h_(t-1) + b_f) \
i_t & = sigma(W_i x_t + U_i h_(t-1) + b_i) \
o_t & = sigma(W_o x_t + U_o h_(t-1) + b_o) \
ctilde_t & = tanh(W_ctilde x_t + U_ctilde h_(t-1) + b_ctilde) \
\
c_t & = f dot.o c_(t-1) + i dot.o ctilde \
h_t & = c_t dot.o o_t
$


In this equation, $sigma$ is the sigmoid function seen earlier, 
and $tanh$ is the hyperbolic tangent function, 
which serves as an alternative activation function returning values
in the $[-1, 1]$ range. 
The hyperbolic tangent is used in $ctilde$ as this value represents a delta-like change 
to be added to the state.


Note that the change value $ctilde_t$ and the gates use $h_t$ in their computation
instead of $c_t$. This value $h_t$ consists of a masked version of $c_t$, 
controlled by the output gate, and allows the model to ignore state information that
is not relevant for the current and following inputs, serving as a form
of focused short term memory. As such, the state $s$ of a LSTM unit consists of both
$h$ and $c$, $s = (h, c)$. The output $y$ of a LSTM unit is usually derived from $h$.

=== Encoder-Decoder

#pagebreak()


= Chapter 3 \ Development

= Chapter 4 \ Results

= Conclusion

WIP.

#bibliography("refs.bib", style: "ieee")
