
/*

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
- Given vectors $x, y in RR^n$, $x dot.o y$ is the hadamard product of $x$ and $y$, that is
$ (x dot.o y)_i = x_i dot y_i $

#pagebreak()

= Contents

WIP.

#pagebreak()

#pagebreak()

= Chapter 1 \ Introduction

#include "introduction.typ"

#pagebreak()

= Chapter 2 \ Background

#include "background.typ"

#pagebreak()

= Chapter 3 \ Development

#include "development.typ"

= Chapter 4 \ Results

= Conclusion

WIP.

#bibliography("refs.bib", style: "ieee")
