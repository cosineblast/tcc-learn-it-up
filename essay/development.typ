
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
and outputs a Pump it Up chart that is coherent with this input.

// TODO: link to stepmania.com
//
In desktop systems, Pump it Up levels are typically organized in the format 
utilized by the open source program Stepmania. This format consists of, 
for each music, a directory containing the music audio file
(in a compressed format such as `.mp3` or `.ogg`) and the chart information file,
in the stepmania `.ssc` text format.

An `.ssc` file consists of an ordered list of key-value pairs containing information about
the song and the charts. The first attributes contain information about the song
itself, such as music path, background video path,
banner image, artist, song name and game edition.

Then, the file provides information about each chart. 
Pump it Up has three primary difficulty categories, Single, Double and Co-op.
Singles is the standard gameplay mode, whereas in Double charts, 
the user plays using two dacing pads at once. Co-op is similar to Double, but in Co-op, two
players play simultaneously, with the arrows containing visual indications 
for the player meant to press them.
In this work, we will only address the problem of generating Single charts.
The difficulty of each single chart is an integer rating number ranging from S1 to S25 where "S" stands for "Single".
Additionaly, we exclude charts in the following Pump it Up categories: 
UCS, Remix, Short Cut and Full Song.

// TODO: should this be in the introduction?

The most important chart attributes are difficulty, offset, BPMs and notes.

// ssc = lista ordenada pares info musica charts
// preambulo = info musica, (caminho audio, video background, imagem, artista, nome), edição
// info charts = dificuldade, offset, bpms, notes.
//
// dificuldade = S1...S15, Double, Coop
//
// nós excluímos UCS, Remix, Short Cut, usamos apenas single
//
// offset = tempo em segundos entre o começo do chart chart e o começo da música
//
// - notas musicais não são posicionadas absolutamente
// - tempo da música segmentado em batidas, notas posicionadas de acordo com batidas
// - valor que descreve o tamanho dessa unidade é o BPM da música
// - BPM tradicional = 120BPM
// - músicas diferentes tem BPMs diferentes, musicas podem mudar de BPM conforme sua 
// velocidades mudam
// - uma measure é outra unidade, sendo em música ocidental, e nos arquivos .ssc, 4 batidas.
// - footnote[Em teoria musical, uma música pode ter measures com outras quantidades
// de batidas, o nome desse conceito é time signature, mas a maioria das músicas são
// organizadas na time signature 4 4, e o formato .ssc usado neste projeto segue essa
// time signature, então seguiremos a convenção de 1 measure = 4 beats]
// - atributo BPMs define, para cada batida da música, qual o BPM da música a partir
// de cada batida da música
//
// notes contém informações das setas na música
// as setas são informadas measure por measure
// as measures são separadas por vírgula
// as setas de cada measure são representadas por linhas com 5 dígitos,
// cada dígito representado uma das posições do pad, na ordem bl, ul, c, ur, dr,
// incluindo step vazio 00000.
// 
// no formato ssc, a posição os steps em uma measure depende do número de 
// steps especificados na measure.
// se a measure tem 4 steps, cada step acontece no começo uma beat, também conhecido
// como uma quarter note.
// se a measure tem 8 steps, cada step acontece no começo de metade de uma beat.
// no caso, isso se chama uma eight note.
//
// o stepmania aceita steps colocados com precisão até 196th notes, ou 48th de beat.


