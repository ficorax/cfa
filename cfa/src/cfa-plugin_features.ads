--  MIT License
--
--  Copyright (c) 2021 Alexandre BIQUE
--  Copyright (c) 2025 Marek Kuziel
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in all
--  copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--  SOFTWARE.

----------------------------------------------------------------------------------------------------
--  This package provides a set of standard plugin features meant to be used
--  within CLAP_Plugin_Descriptor.Features.
--
--  For practical reasons we'll avoid spaces and use `-` instead to facilitate
--  scripts that generate the feature array.
--
--  Non-standard features should be formated as follow: "$namespace:$feature"

package CfA.Plugin_Features is

   -------------------
   --  Plugin category

   CLAP_Plugin_Feature_Instrument    : constant String := "instrument";
   --  Add this feature if your plugin can process note events and then produce audio

   CLAP_Plugin_Feature_Audio_Effect  : constant String := "audio-effect";
   --  Add this feature if your plugin is an audio effect

   CLAP_Plugin_Feature_Note_Effect   : constant String := "note-effect";
   --  Add this feature if your plugin is a note effect or a note generator/sequencer

   CLAP_Plugin_Feature_Note_Detector : constant String := "note-detector";
   --  Add this feature if your plugin converts audio to notes

   CLAP_Plugin_Feature_Analyzer      : constant String := "analyzer";
   --  Add this feature if your plugin is an analyzer

   -----------------------
   --  Plugin sub-category

   CLAP_Plugin_Feature_Synthesizer       : constant String := "synthesizer";
   CLAP_Plugin_Feature_Sampler           : constant String := "sampler";
   CLAP_Plugin_Feature_Drum              : constant String := "drum"; -- For single drum
   CLAP_Plugin_Feature_Drum_Machine      : constant String := "drum-machine";

   CLAP_Plugin_Feature_Filter            : constant String := "filter";
   CLAP_Plugin_Feature_Phaser            : constant String := "phaser";
   CLAP_Plugin_Feature_Equalizer         : constant String := "equalizer";
   CLAP_Plugin_Feature_Deesser           : constant String := "de-esser";
   CLAP_Plugin_Feature_Phase_Vocoder     : constant String := "phase-vocoder";
   CLAP_Plugin_Feature_Granular          : constant String := "granular";
   CLAP_Plugin_Feature_Frequency_Shifter : constant String := "frequency-shifter";
   CLAP_Plugin_Feature_Pitch_Shifter     : constant String := "pitch-shifter";

   CLAP_Plugin_Feature_Distortion        : constant String := "distortion";
   CLAP_Plugin_Feature_Transient_Shaper  : constant String := "transient-shaper";
   CLAP_Plugin_Feature_Compressor        : constant String := "compressor";
   CLAP_Plugin_Feature_Expander          : constant String := "expander";
   CLAP_Plugin_Feature_Gate              : constant String := "gate";
   CLAP_Plugin_Feature_Limiter           : constant String := "limiter";

   CLAP_Plugin_Feature_Flanger           : constant String := "flanger";
   CLAP_Plugin_Feature_Chorus            : constant String := "chorus";
   CLAP_Plugin_Feature_Delay             : constant String := "delay";
   CLAP_Plugin_Feature_Reverb            : constant String := "reverb";

   CLAP_Plugin_Feature_Tremolo           : constant String := "tremolo";
   CLAP_Plugin_Feature_Glitch            : constant String := "glitch";

   CLAP_Plugin_Feature_Utility           : constant String := "utility";
   CLAP_Plugin_Feature_Pitch_Correction  : constant String := "pitch-correction";
   CLAP_Plugin_Feature_Restoration       : constant String := "restoration"; -- repair the sound

   CLAP_Plugin_Feature_Multi_Effects     : constant String := "multi-effects";

   CLAP_Plugin_Feature_Mixing            : constant String := "mixing";
   CLAP_Plugin_Feature_Mastering         : constant String := "mastering";

   ----------------------
   --  Audio Capabilities

   CLAP_Plugin_Feature_Mono      : constant String := "mono";
   CLAP_Plugin_Feature_Stereo    : constant String := "stereo";
   CLAP_Plugin_Feature_Surround  : constant String := "surround";
   CLAP_Plugin_Feature_Ambisonic : constant String := "ambisonic";

end CfA.Plugin_Features;
