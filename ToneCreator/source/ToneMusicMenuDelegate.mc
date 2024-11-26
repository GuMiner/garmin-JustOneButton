import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ToneMusicMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    var E3 = 165;
    var G3 = 196;
    var B3 = 247;
    var C4 = 262; // Middle C
    var D4 = 294; // D
    var Eb4 = 311;
    var E4 = 330;
    var Gb4 = 370; // F#
    var G4 = 392; // G
    var A4 = 440; // A
    var B4 = 494;
    var C5 = 523;

    var eighthNote = 175;

    var NO_TONE = 0;
    var SPACER = 30;

    function onMenuItem(item as Symbol) as Void {
        var notes = new [0];
        var lengths = new [0];
        if (item == :song1) 
        {   
            // Merry Christmas
            notes = [
                D4, 
                G4, G4, A4, G4, Gb4,
                E4, E4, E4,
                A4, A4, B4, A4, G4,
                Gb4, D4, D4,
                B4, B4, C5, B4, A4,
                G4, E4, D4, D4,
                E4, A4, Gb4,
                G4];
            lengths = [
                4, 
                4, 8, 8, 8, 8,
                4, 4, 4,
                4, 8, 8, 8, 8,
                4, 4, 4,
                4, 8, 8, 8, 8,
                4, 4, 8, 8,
                4, 4, 4,
                2];
        } else if (item == :song2) {
            // Imperial Suite
            notes = [
                G3, E3, G3,
                B3, B3, B3, B3,
                C4, G4, Gb4, D4,
                Eb4, D4, C4
                ];
            lengths = [
                2, 2.67, 8,
                1.33, 8, 8, 8,
                4, 4, 2.67, 8,
                8, 8, 1.33
                ];
        }

        
        var toneProfile = new [notes.size() * 2];
        for (var i = 0; i < notes.size(); i++) {
            toneProfile[i * 2] = new Attention.ToneProfile(notes[i], eighthNote * 8 / lengths[i]);
            toneProfile[i * 2 + 1] = new Attention.ToneProfile(NO_TONE, SPACER);
        }
        Attention.playTone({:toneProfile=>toneProfile});
    }

}