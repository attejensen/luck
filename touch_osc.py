#!/usr/bin/python2
import datetime, os, time, sys, re, threading, liblo
from midi import *
from globals import *
from clip import *
from timer import *

class touch_osc(object):
    # singleton
    _instance = None

    running = True
    
    clips = []
    threads =[]

    blink_time = .2
    press_stop_time = .1
    stop = 0
    
    touch_osc_out_port = 9000
    touch_osc_in_port = 8000
    osc_sleep_time = .008
    osc_sleep_time = 0


    current_part = 0
    next_part = -1
    latch_mute = False
    
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(touch_osc, cls).__new__(
                                cls, *args, **kwargs)
        return cls._instance

    def __init__(self, touch_osc_host):
        self.touch_osc_host = touch_osc_host
        self.touch_osc = liblo.Address(self.touch_osc_host, self.touch_osc_out_port)

        self.send_part_names()
        self.send_slider_names()
        self.send_channel_names()
        self.send_parts()
        self.send_sliders()
        self.send_channels()
        self.send_mutes()
        self.clear_beats()

        
        try:
            self.osc_server = liblo.Server(self.touch_osc_in_port)
        except liblo.ServerError, err:
            print str(err)
        self.osc_server.add_method(None, None, self.osc_handler)


        #l = multiprocessing.Process(target=self.osc_listen)
        l = threading.Thread(target=self.osc_listen)
        l.start()
        self.threads.append(l)
        
        p = threading.Thread(target=self.part_switcher)
        p.start()
        self.threads.append(p)

        b = threading.Thread(target=self.blinker)
        b.start()
        self.threads.append(b)

        beat = threading.Thread(target=self.beater)
        beat.start()
        self.threads.append(beat)

        s = threading.Thread(target=self.stop_listener)
        s.start()
        self.threads.append(s)
        

        t.start()        
        self.run_part(g.start_part)
        #m = midi(self.midi_port_name)

    
    def run_part(self, part):
        try:
            part_name = g.part_names[part]
        except:
            return
        if part_name == '':
            return
        part_re = re.compile('.*-'+part_name+'\.py')
        for one_file in os.listdir(g.project_folder):
            if part_re.match(one_file) and g.file_name_in_channels(one_file):
                c = clip(g.project_folder + one_file)
                c.start()
                self.clips.append(c)



    def send(self, target, message, sleep_time = 0):
        liblo.send(self.touch_osc, target, message)
        time.sleep(sleep_time)

    def send_part_names(self):
        for i in range(g.nb_parts):
            if i<len(g.part_names):
                self.send('/page1/labelPart'+str(i),g.part_names[i])
            else:
                self.send('/page1/labelPart'+str(i),'')

    def send_slider_names(self):
        for i in range(g.nb_sliders):
            if i<len(g.slider_names):
                self.send('/page1/labelGl'+str(i),g.slider_names[i])
            else:
                self.send('/page1/labelGl'+str(i),'')


    def send_channel_names(self):
        for i in range(g.nb_channels):
            if i<len(g.channel_names):
                self.send('/page1/labelTr'+str(i),g.channel_names[i],sleep_time=.005)
            else:
                self.send('/page1/labelTr'+str(i),'',sleep_time=.005)


    def send_parts(self):
        for i in range(g.nb_parts):
            if self.current_part == i:
                self.send('/page1/part'+str(i),1)
            else:
                self.send('/page1/part'+str(i),0)

    def send_sliders(self):
        for i in range(g.nb_sliders):
            self.send('/page1/global'+str(i),g.sliders[i])

    def send_channels(self):
        for i in range(g.nb_channels):
            self.send('/page1/fader'+str(i),g.faders[i])

    def send_mutes(self):
        for i in range(g.nb_channels):
            self.send('/page1/mute'+str(i),g.mutes[i])
        self.send('/page1/allMuteWait', float(self.latch_mute))

    def clear_beats(self):
        for i in range(g.nb_beaters):
            self.send('/page1/pulse'+str(i),0)



    def osc_handler(self, path, args, types, src):
        #print "got message '%s' from '%s'" % (path, src.url)
        #for a, t in zip(args, types):
        #    print "argument of type '%s': %s" % (t, a)

        if path[:12] == '/page1/fader':
            fader = path[12:]
            print 'handling fader: ' + fader
        elif path[:13] == '/page1/global':
            slider = path[13:]
            print 'handling slider: ' + slider
        elif path[:11] == '/page1/mute':
            mute = path[11:]
            print 'handling mute: ' + mute
        elif path[:11] == '/page1/part':
            part = int(path[11:])
            if part < len(g.part_names) and g.part_names[part]:
                self.next_part = part
            self.send_parts()
        elif path[:10] == '/page1/all':
            all_action = path[10:]
            print 'handling all_action: ' + all_action
        elif path[:11] == '/page1/stop':
            self.stop = int(args[0])
        else:
            print 'unhandled path: ' + path

        
    

    def osc_listen(self):
        while self.running:
            self.osc_server.recv(1)

    def part_switcher(self):
        while self.running:
            t.wait(g.part_sync)
            if self.next_part != -1:
                for clip in self.clips:
                    clip.quit()
                self.clips = []
                self.current_part = self.next_part
                self.run_part(self.current_part)
                self.next_part = -1
                self.send_parts()

    def blinker(self):
        blink = self.running
        while self.running:
            if self.next_part != -1:
                self.send('/page1/part'+str(self.next_part),int(blink))
            blink = not blink
            time.sleep(self.blink_time)

    def beater(self):
        current_pulse = 0
        last_pulse = -1
        while self.running:
            self.send('/page1/pulse'+str(last_pulse),0)
            self.send('/page1/pulse'+str(current_pulse),1)
            t.wait(1)
            last_pulse = current_pulse
            current_pulse = (current_pulse + 1)%g.beats_per_bar
            
    def stop_listener(self):
        last = 0
        current = 0
        while self.running:
            last = current
            current = self.stop
            if last == 1 and current == 1:
                self.quit()
                return
            time.sleep(self.press_stop_time)

    def quit(self):
        for clip in self.clips:
            clip.quit()
        self.running = False



