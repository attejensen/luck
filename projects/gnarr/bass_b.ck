Global.path2track(me.path()) => string ch;


[5,8,10] @=> int notes[];
[.5, .25, -2, .25, .25, .5, -4.5,-3] @=> float lengths[];
2 => int octave;

int i;
while(true){
    notes[Time.sub(16)%notes.size()] + 12*octave => int note;
    lengths[i%lengths.size()] => float length;
    if(length >= 0){
        Midi.note(note, ch, Time.beat(length));
        Time.wait(length);
    }
    else {
        Midi.note_off(ch);
        Time.wait(-1*length * Math.round((.2 + (1-Global.get_fader(ch))) * 3));
    }
    i++;
}