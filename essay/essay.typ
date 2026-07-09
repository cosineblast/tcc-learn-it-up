
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
When the arrows reach these receptors, the player is expected press the buttons labeled with the corresponding arrows, and
receive a judgement based on the time accuracy of their step, such as "Perfect", "Great" or "Miss".
The arrows in a level are typically placed according to the of rhythm of the music currently playing, both in their timing, and arrow sequence.
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
In PIU, the hold arrow counts as a multiple arrows that are scored as
mutliple hits or misses depending on whether the
player is holding them during the long arrow.
Because of this, hold arrows are of greater importance in PIU, and missing them has
a greater impact in the final score. In some cases, this mechanic allows the player to quickly
release the hold step and press it again, if done during the interval between
two score ticks in the hold step.

Another difference is that unlike DDR, PIU
does not require the player to hit the button when the hold arrow hits
the receptor, it is ok if the player is already holding the arrow button
before the hold arrow arrives.
This allows for some charts to add a fast stream of several hold notes for
cosmetic reasons, that the player is expected to effectively treat as a single hold.

TODO: Add image of hold arrows.

Although both games received ports to consoles such as Playstation 2, these games
are mostly played on arcade machines, or in personal computers through the
dance rhythm game emulator Stepmania and its forks.

== Motivation

- charting is difficult.
- there already are papers doing that for DDR, but none for pump
- piucenter dataset


#pagebreak()

= Chapter 2 \ Background

The goal of this section is to provide a gentle introduction to the main concepts used in this project.

= Chapter 3 \ Development

= Chapter 4 \ Results

= Conclusion

WIP.

= References

WIP.

