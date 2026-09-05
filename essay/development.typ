
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

== Data

This section describes the datasets and data processing methodology of this work.

The final goal of this project is to implement a training program that takes 
Pump it Up chart and audio files, and outputs a trained model, and to implement
an inference program that, using the trained model, receives an audio file as input, 
and outputs a Pump it Up chart that is coherent with the input music.

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

After this preamble, the file presents information about each chart. 
The most important chart attributes are difficulty, offset, BPMs and notes.

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
#footnote [
  In music theory, the amount of beats in a measure may vary depending on the song.
  This is defined by what is known as the time signature of the song, but most songs
  are in the 4 4 time signature, which consists of 4 beats per measure.
  In the .ssc format used in this project, all charts follow this time signature,
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

The first task in this project is to process the .ssc files, into a more detailed format
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

// - gimmicks, stops, speed, warps
// - conversão de beats em segundos
// - lista de bpms
// - mirroring horizontal/vertical


// audio processing:
// we use the same audio representation methodology of DDC and DDCL
// assume 44.1khz stereo PCM data, segment into short windows, run fft on windows,
// grab 80 frequencies intervals using the mel scale, then log to match human perception
// this is done with 3 windows, 23ms, 46ms and 93ms, advancing the windows
// by 10ms each time (the windows have intersections).
//
// this whole processing is done using the ESSENTIA library.
// the final tensor for the song is N x 80 x 3 where N is the length of the song
// in centiseconds (10ms), 80 is the number of frequencies, and 3 is the number of channels.





