# Copyright (C) 2015  Olga Yakovleva <yakovleva.o.v@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

form Parameters
word Input_file recording.wav
word First_output_file recording.wav
word Second_output_file recording.raw
integer Sample_rate 16000
boolean Invert 0
endform
min_sil_dur=0.3
Read from file... 'input_file$'
snd=Extract one channel... 1
src_sample_rate=Get sampling frequency
num_samples=Get number of samples
first_sample=1
i=1
repeat
val=Get value at sample number... 1 i
if val!=0
first_sample=i
i=num_samples
endif
i+=1
until i>num_samples
last_sample=num_samples
i=num_samples
repeat
val=Get value at sample number... 1 i
if val!=0
last_sample=i
i=1
endif
i-=1
until i<1
if first_sample!=1 or last_sample!=num_samples
start_of_sound=Get time from sample number... first_sample
end_of_sound=Get time from sample number... last_sample
snd=Extract part... start_of_sound end_of_sound rectangular 1 no
endif
To Intensity: 100, 0, "yes"
avg=Get quantile: 0, 0, 0.5
mx=Get maximum: 0, 0, "Parabolic"
thr=avg-mx-20
To TextGrid (silences)... thr min_sil_dur 0.05 silent sounding
num_intervals=Get number of intervals... 1
start=0
label$=Get label of interval... 1 1
if label$=="silent"
start_of_speech=Get end point... 1 1
start=start_of_speech-min_sil_dur
endif
end=Get end point... 1 num_intervals
label$=Get label of interval... 1 num_intervals
if label$=="silent"
end_of_speech=Get start point... 1 num_intervals
end=end_of_speech+min_sil_dur
endif
select snd
speech=Extract part... start end rectangular 1 no
if invert!=0
speech=Multiply: -1
endif
if sample_rate!=src_sample_rate
Resample: sample_rate, 70
endif
Scale intensity... 70
peak=Get absolute extremum... 0 0 Sinc70
if peak>0.99
Scale peak... 0.99
endif
Save as raw 16-bit little-endian file... 'second_output_file$'
if sample_rate!=16000
select speech
Resample: 16000, 70
Scale intensity... 70
peak=Get absolute extremum... 0 0 Sinc70
if peak>0.99
Scale peak... 0.99
endif
endif
Save as WAV file... 'first_output_file$'
