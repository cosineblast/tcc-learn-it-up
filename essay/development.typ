
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
- Explicação da estrutura do modelo, CNN, CNN+LSTM
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

== Model Description

We follow the standard methodology of DDC and DDCL and divide chart generation into
two separate tasks. The _step placement_ task consists of identifying the instants
of the music in which the occurance of a step is suitable.
Models implementing this task receive the audio representation of a portion of the
song, alongside intended difficulty information, and return information about
the times to place steps with regard to the given segment.
In this work, step placement models are also known as _onset models_.

After step placement has been executed, the _step selection_ task consists of
determining the sequence of arrows to be assigned to each step placed for the song.
Models implementing this task have access to the previously generated steps,
and time-related information of the current step regarding adjacent ones.


// TODO: change this if DDCL is implemented


== StepFile Parsing 

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
That is not a huge problem in our instance, because the most recent Pump it Up editions
(Phoenix) have very few instances of the filtered out gimmicks, with only around
3.69% of charts being left out by this. 

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
mirroring is applied, since the bottom and up arrows don't have the same chart
semantics, (for instance, they involve different muscles to be pressed).
// TODO: apply vertical mirroring at low level charts.

== Audio Representation

Regarding audio processing, we use the same audio representation methodology of DDC and DDCL.

The audio processing pipeline takes in audio files in a sampling rate of 44.1kHz,
and stereo format (left and right channels).
The stereo channels are averaged into a single audio channel (mono) before processing.
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

== Step Placement

Previous work on chart generation for rhythm games uses one of two
distinct strategies for step placement. Frame step placement consists of analyzing
the context around each 10ms frame of the song in order to determine whether a step
should happen at that frame. Beat step placement consists of segmenting the song into beats and
analyzing each beat, to determine the step placement offsets regarding the target beat.
The DDC paper uses frame step placement, but later work such as DDCL and Yi2023 @yi2023
report better results with beat step placement.

From the perspective of a rhythm game player, it makes more sense to use beat step placement, since in traditional manual charting, arrows are not placed absolutely by the charter, but instead placed at specific fractions of the chart beats (i.e 4th notes, 8th notes, 16th notes), and which are adjusted to match the song beats and BPM, so the arrows cannot be narrowly misaligned. #footnote[Ideally.]
Frame step placement allows for the model to miss the right times for steps by a few tens of milliseconds, which reduces the precision of the chart and makes gameplay more frustrating.

In order to use beat step placement, it is necessary to have accurate BPM information of the song to be charted. Although the dataset used in this work contains correct alignment timing of the arrows, it does not provide accurate BPM information of Pump it Up songs. The vast majority of songs have BPMs information in their charts that
does not accurately reflect the actual BPMs of the songs, with reported BPMs often 3 to 4 times lower than the real BPMs.
Therefore, in this work, we use per frame step placement, like in the original DDC paper.
// TODO: maybe document my ideas for workarounds for this?

The step placement models receive as input the target frame, along with a context of 7 frames before and after it, as a $(15 times 80 times 3)$ tensor. It also receives a one-hot encoded vector of the intended chart difficulty, which ranges from $1$ to $25$. The model outputs a single sigmoid unit value determining its confidence that there should be a step in the target frame.
The features of out of bound context frames are set to their minimum values across the
entire song.

Two different step placement model architectures were developed, a pure CNN network and
a CNN-LSTM network.

The CNN network starts with a convolutional layer with 10 kernels of $7 times 3$ (time, frequency) and ReLu activation, max pooling with a $1 times 3$ window, another convolutional layer with 20 kernels of $3 times 3$ and ReLu activation, and then
max pooling with a $1 times 3$ window.
It then passes this output alongside the one-hot difficulty vector into a multi layer perceptron, consisting of a linear layer with 256 units, ReLu activation, dropout of 50%, another linear layer with 128 units, ReLu activation, dropout of 50%, then
a linear layer with 1 output unit, followed by the sigmoid unit.

// TODO: link to relu paper
// TODO: picture

//
// CNN-LSTM:
// - Conv same as before
// - Linear into 200
// - LSTM Input = Hidden = 200, 2 layers, dropout
// - Linear same as before
//

// Training methodology for this
// - shuffling do dataset
// - binary search
// - fast convergence of results
// - peak picking
