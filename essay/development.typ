
/*
# Desenvolvimento
- Objetivo: replicar DDC, DDCL, expandir
- Implementar gerador de cahrts (incluir PIUCENTER)

## Data
- Dataset: phoenix, resistance simfiles
- mirroring horizontal/vertical

## Métodologia: Extração de steps e áudio
- parsing: msdparser
- essentia
- stft - 3 janelas /canais: Nx80x3

## Métodologia: Implementação de DDC
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
*/


The final goal of this project is to implement a training program that takes 
Pump it Up chart and audio files, and outputs a trained model, and to implement
an inference program that, using the trained model, receives an audio file as input, 
and outputs a Pump it Up chart that is coherent with the input music.
This chapter outlines the data processing, network architecture,
and training methodology used in this work.

== Data

This section describes the dataset used in this work.

In this work, we use the Pump it Up Phoenix (2024) as the primary subject dataset,
provided by the Resistance Simfiles project. The statistics mentioned in this work
for this dataset is after chart filtering is applied, therefore it
only considers Single charts, and excludes charts
in the following Pump it Up chart categories: UCS, Remix, Short Cut and Full Song.

Considering the charts used in this dataset, it contains 623 charts in 132 songs, from 100 different artists,
over the genres ORIGINAL, "WORLD MUSIC" and K-POP. The vast majority of steps (75%)
consist of a single step arrow.

// TODO: add caption thingy
#table(
  columns: (1fr, 1fr),
  align: center + horizon,
  inset: 10pt,
  table.header(
    [*Statistic*], [*Phoenix Dataset*]
  ),

  [Number of song artists], [100],
  [Number of step authors], [14],
  [Song count], [132],
  [Chart count], [623],
  [Genres], [ORIGINAL, WORLD MUSIC, K-POP],
  [Total step count], [300811],
  [Normal step rate], [75.87 %],
  [Jump step rate], [8.63 %],
  [Hold step rate], [15.48 %],
)

== Data Processing Methodology

The first task in this project is to process the `.ssc` files, into a more detailed format
suitable to data analysis and training.
First, parsing is done in python to retrieve relevant stepfile attributes, and filter unecessary charts.
Then, we process the stepfile into what is known as a refined stepfile,
containing additional information extracted from the charts,
such as the relative time (in beats) of each note,
and the absolute time (in seconds) of each note.
These refined stepfiles are then stored in a `data/parsed` directory, later used
in analysis and training.
An auxiliary testing utility was developed to play the song alongside the
chart steps from the refined files. // so that one can verify if the song align with the steps

An important type of charting filtering implemented by the processing program,
is removing charts that contain certain types of gimmicks. Gimmicks, are visual
quirks added to charts, in order to make the gameplay more interesting or challenging.
They include slowing down and speeding up arrows,
stopping arrows in the middle of the screen,
arrows that disappear when approaching the receptors,
and teleporting arrows. In this work, charts containing most kinds of
gimmicks are filtered out, and the only gimmicks allowed are the scroll and speed gimmicks.
That is not a problem in our instance, because the most recent Pump it Up editions
(Phoenix) have very few instances of the filtered out gimmicks, with only a couple of charts being left out by this.
// TODO: (how many?)

The conversion of beat time to second time used in the refined stepfiles is
done using an algorithm based on the one used in DDC. It first computes the
duration of the BPM sections of the BPMs list of from the chart, and then
uses those intervals to find the amount of time in seconds before the each note.
This is equivalent to computing the harmonic mean of the BPMs list of the song weighted by the durations of the segments,
and diving the current note's beat by that value to obtain the absolute time of the note.

Additionally, in the chart processing phase, we also enhance the dataset by adding
mirrored versions of the charts. In the original DDC, paper, mirroring is applied
both vertically and horizontally. In this work, we only apply horizontal mirroring, because
the coherence of charts changes significantly at higher difficulties if vertical
mirroring is applied, because the bottom and up arrows don't have the same chart
semantics, (for instance, they involve different muscles to be pressed).
// TODO: apply vertical mirroring at low level charts.

Regarding audio processing, we use the same audio representation methodology of DDC and DDCL.

The audio processing pipeline takes in audio files in a sampling rate of 44.1kHz,
and stereo format (left and right channels).
The stereo channels are averaged into a single audio channel (mono) before proecessing.
The audio is segmented into short windows, and a Fast Fourier Transform is applied to each window,
in order to figure out the most prevalent frequencies in each instant of the song. This is known
as Short-time Fourier transform, and the result of this operation is known a spectrogram.
For each window, 80 frequencies are sampled from the resulting fourier transform, distributed
according to the mel scale.
This is done three times, with three different window sizes of 23ms, 46ms and 93ms, advanced by a stride of 10ms.
The justification for using multiple window sizes is that frequency analysis on different timescales
can better represent different kinds of musical features. @Hamel2012

This whole processing is done using the ESSENTIA @essentia library, and the final
result for a song is a $N times 80 times 3$ tensor, where $N$ is the length of the song
in tens of milliseconds, 80 is the number of frequencies used, and 3 is the number of channels / window sizes.


