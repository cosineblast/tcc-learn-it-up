
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
In PIU, the hold arrow counts as a multiple arrows 
that are scored continuously as
the player is holds the step during the long arrow.
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

Altough Pump it Up has a wide variety of songs, users often desire to play
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

Additionally, Pump it Up has a database #link("https://www.piucenter.com/")[piucenter.com] that classifies, for every Pump it Up chart, the different
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


