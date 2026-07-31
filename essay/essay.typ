
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
values multiple times per second, a process known as Pulse Code Modulation (PCM).
These measurements are typically stored in formats such as `.wav` or `.pcm`.

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
in what is known as the Phon scale.

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
then this frequency will look as if it is much lower than it really is.
If you only measure every 8 years, the Olympic Games will look as if they happen
with the same frequency as the Vienna Biennale.



#pagebreak()



= Chapter 3 \ Development

= Chapter 4 \ Results

= Conclusion

WIP.

#bibliography("refs.bib", style: "ieee")
