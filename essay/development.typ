
/*
# Desenvolvimento
- Objetivo: replicar DDC, DDCL, expandir
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
*/


The final goal of this project is to implement a training program that takes 
Pump it Up chart and audio files, and outputs a trained model, and to implement
an inference program that, using the trained model, receives an audio file as input, 
and outputs a Pump it Up chart that is coherent with the input music.
This chapter outlines the data processing, network architecture,
and training methodology used in this work.

== Data

This section describes the datasets and data processing methodology of this work.

// TODO: link to stepmania.com
In desktop systems, Pump it Up levels are typically organized in the format 
utilized by the open source program Stepmania 5. This format consists of, 
for each music, a directory containing the music audio file
(in a compressed format such as `.mp3` or `.ogg`) and the chart information file,
in the stepmania `.ssc` text format.

An `.ssc` file consists of an ordered list of key-value pairs containing
information about the song and the charts. The first attributes contain
information about the song itself, such as music path, background video path,
banner image, artist, song name and game edition.
After this preamble, the file presents information about each chart,
the most important chart attributes being difficulty, offset, BPMs and notes.

Regarding difficulty, we will only address the problem of generating Single
charts in this work. Additionaly, we exclude charts in the following Pump it
Up chart categories: UCS, Remix, Short Cut and Full Song.

The offset attribute consits of a decimal number indicating the amount of seconds
between the start of the chart steps and the beggining of the audio.
This number is usually negative, since the audio typically starts before the
chart steps.

The BPMs and notes attribute contain the main information about the chart steps.
In Pump it Up charts, just like in music sheets, the musical notes are not placed
using absolute time information. Instead, time is segmented into short intervals
named beats, and the notes are placed according to these beats.
The relationship between seconds and beats in a song is expressed by the BPM,
or beats per minute of that song. A typical BPM value for western songs is 120
beats per minute, or 2 beats per second, but songs may have other BPMs,
and some songs also change their BPM during faster or slower sections.
Additionally, another common musical time unit is the measure, which typically
consists of 4 beats.
#footnote[
  In music theory, the amount of beats in a measure may vary depending on the song.
  This is defined by what is known as the time signature of the song, but most songs
  are in the four-four time signature, which consists of 4 beats per measure.
  In the `.ssc` format used by this project, all charts follow this time signature,
  so we will adopt the convention of 1 measure = 4 beats.
]
The BPMs attribute consists of a key-value pair list, informing for each beat in the song,
what is the BPM of the song from that beat onward, until the next entry in the BPMs list.

The notes attribute contains the step placement information.
It consists of a list of the arrow step placements for each measure.
The steps are represented by a string of 5 digits, each representing an arrow position
in the pad: bottom left, up left, center, up right and down right, in order.
The digits range from 0 to 3, where 0 represents no arrow, 1 represents a regular step arrow,
2 represents the start of a hold arrow, and 3 represents an end of hold.

For each measure in the notes attribute, the step codes are placed sequentially,
and their offset to the start of the measure is defined by the number of step
codes in the measure.
For example, if a measure has four stepcodes, then each stepcode happens at the
start of a beat.
In musical terminology, we would say those steps occur at quarter notes, since
each beat is a quarter of a measure.
If a measure has eight stepcodes instead, then the stepcodes are placed every half beat in the measure,
known as eight notes.
Stepmania supports a precision of 196th notes, equivalent to 1/48th of a beat.

The first task in this project is to process the `.ssc` files, into a more detailed format
suitable to data analysis and training.
First, parsing is done in python to retrieve relevant stepfile attributes, and filter unecessary charts.
Then, we process the stepfile into what is known as refined stepfile,
containing additional information extracted from the charts,
such as the relative time (in beats) of each note,
and the absolute time (in seconds) of each note.
These refined stepfiles are then stored in a `data/parsed` directory, later used
in analysis and training.
An auxiliary testing utility was developed to play the song alongside the
chart steps from the refined files.

An important type of charting filtering implemented by the processing program,
is removing charts that contain certain types of gimmicks. Gimmicks, are visual
quirks added to charts, in order to make the gameplay more interesting or challenging.
They include slowing down and speeding up arrows,
stopping arrows in the middle of the screen,
arrows that disappear when approaching the receptors,
and teleporting arrows. In this work, charts containing most kinds of
gimmicks are filtered out, and the only gimmicks allowed are the scroll and speed gimmicks.
That is not a problem in our instance, because the most recent Pump it Up editions
(Phoenix) have very few instances of the filtered out gimmicks, with only a few charts being left out by this.
// TODO: (how many?)

The conversion of beat time to second time used in the refined stepfiles is
done using an algorithm based on the one used in DDC. It first computes the
duration of the BPM sections of the BPMs list of from the chart, and then
uses those intervals to find the amount of time in seconds before the each note.
This is equivalent to computing the harmic mean of the BPMs list of the song weighted by the durations of the segments,
and diving the current note's beat by that value to obtain the absolute time of the note.

Additionally, in the chart processing phase, we also enhance the dataset by adding
mirred versions of the charts. In the original DDC, paper, mirroring is applied
both vertically and horizontally. In this work, we only apply horizontal mirroring, because
the coherence of charts changes significantly at higher difficulties if vertical
mirroring is applied, because the bottom and up arrows don't have the same chart
semantics, (for instance, they involve different muscles to be pressed).
// TODO: apply vertical mirroring at low level charts.

Regarding audio processing, we use the same audio representation methodology of DDC and DDCL.

The audio processing pipeline takes in audio files in a sampling rate of 44.1kHz,
and stereo format (left and right channels).
The stereo channels are averaged into a single audio channel (mono) before proecessing.
The audio is segmented into short windows, and a fast fourier transform is applied to each window,
in order to figure out the most prevalent frequencies in each instant of the song. This is known
as Short-time Fourier transform, and the result of this operation is known a spectogram.
For each window, 80 frequencies are sampled from the resulting fourier transform, distributed
according to the mel scale.
This is done three times, with three different window sizes, 23ms, 46ms and 93ms.
The justification for this is that different timescales may better
represent different musical features.
All the windows are advanced by a stride of 10ms.

This whole processing is done using the ESSENTIA library, and the final
result for a song is a $N times 80 times 3$ tensor, where $N$ is the length of the song
in tens of milliseconds, 80 is the number of frequencies used, and 3 is the number of channels used, related to the window sizes.
// TODO: link to essentia
// TODO: link to representations paper

In this work, we use the Pump it Up Phoenix as the primary subject dataset.
// TODO: include song statistics





