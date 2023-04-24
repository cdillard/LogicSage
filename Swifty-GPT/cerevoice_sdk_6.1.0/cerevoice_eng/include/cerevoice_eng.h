#if !(defined __CEREVOICE_ENG_H__)
#define __CEREVOICE_ENG_H__
/* $Id:
 *=======================================================================
 *
 *                       Copyright (c) 2010-2021 CereProc Ltd.
 *                       All Rights Reserved.
 *
 *=======================================================================
 */

/* Matthew Aylett: 100208 */
/* Chris Pidcock: 110314 */

/** \file cerevoice_eng.h

CereVoice Engine Text to Speech API
*/

/** \mainpage

The CereVoice Engine Text to Speech (TTS) API is an advanced TTS API
developed by CereProc Ltd.

Two header files are included, cerevoice_eng_simp.h is a simple API,
allowing TTS audio data or wave files to be generated with two
function calls.

The API described in cerevoice_eng.h is an extended version of the
simple API, allowing the use of multiple voices and channels,
low-latency synthesis via a callback API, control of memory footprint,
user lexicons, and access to marker events and phoneme timings.
*/

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned char byte;

/** Voice load configuration */
enum CPRC_VOICE_LOAD_TYPE {
    /** All data loaded to memory (fastest, requires most RAM) */
    CPRC_VOICE_LOAD = 0,
    /** Audio and index data is read from disk (slowest performance, requires
        the least RAM) */
    CPRC_VOICE_LOAD_EMB = 1,
    /** Audio data is read from disk (reasonably fast, relatively low RAM
        footprint) */
    CPRC_VOICE_LOAD_EMB_AUDIO = 2,
    /** Load using memmap, if supported on the platform */
    CPRC_VOICE_LOAD_MEMMAP = 3,
    /** Not used in engine processing */
    CPRC_VOICE_LOAD_TP = 4
};

/** Audio output file type */
#if !(defined __CPRCEN_ENGINE_H__)
enum CPRCEN_AUDIO_FORMAT {
    /** Raw linear PCM output */
    CPRCEN_RAW = 0,
    /** RIFF wave output */
    CPRCEN_RIFF = 1,
    /** AIFF output (commonly used on Mac OS X) */
    CPRCEN_AIFF = 2
};

/** Location of interrupt */
enum CPRCEN_INTERRUPT_BOUNDARY_TYPE {
    CPRCEN_INTERRUPT_BOUNDARY_PHONE = 0,   /** Interrupts at an appropriate */
    CPRCEN_INTERRUPT_BOUNDARY_WORD = 1,    /** Interrupts at a word boundary */
    CPRCEN_INTERRUPT_BOUNDARY_NATURAL = 2, /** Interrupts in a realistic position for most speakers */
    CPRCEN_INTERRUPT_BOUNDARY_DEFAULT = 2, /** Interrupts in a realistic position for most speakers */
    CPRCEN_INTERRUPT_BOUNDARY_LEGACY_SPURT = 3
};

/** How to handle speach in the interrupt */
enum CPRCEN_INTERRUPT_INTERRUPT_TYPE {
    CPRCEN_INTERRUPT_INTERRUPT_HALT = 0,    /** Goes to silence, no change */
    CPRCEN_INTERRUPT_INTERRUPT_OVERLAP = 1, /** Speaks over the other talker using Lombard like speech  */
    CPRCEN_INTERRUPT_INTERRUPT_POLITE = 2,  /** Brings to a stop by tailing off */
    CPRCEN_INTERRUPT_INTERRUPT_ANGRY = 3,   /** Brings to the interrupt point by moving to Lombard speech */
    CPRCEN_INTERRUPT_INTERRUPT_REPLAN = 3   /** Brings to the interrupt point by moving to Lombard speech */
};

#endif

/** Type of transcription entry

The transcription holds useful non-speech information about the audio output.
It can be used for a variety of purposes, such as lip syncing for animated
characters (using the phoneme transcriptions), or word highlighting in an
application (using the 'cptk' markers).  User-specified input markers are also
stored in the transcription structure.
*/

#ifndef CEREVOICE_GEN_INCLUDE_CPGEN_TYEPDEFS_H_
enum CPRC_ABUF_TRANS {
    /** Phone transcription (phones can also be referred to as 'phonemes') */
    CPRC_ABUF_TRANS_PHONE = 0,
    /** Word transcription - these are speech-based word transcriptions, hence
        '21' is two word events (twenty one).
    */
    CPRC_ABUF_TRANS_WORD = 1,
    /** Marker transcription, can be user generated or contain CereProc
        tokenisation markers.  CereProc token markers have the form
        'cptk_n1_n2_n3_n4', where n1 is the character offset, n2 is the
        byte offset, n3 is the number of characters in the word, and n4
        is the number of bytes in the word.
    */
    CPRC_ABUF_TRANS_MARK = 2,
    /** Error retrieving transcription */
    CPRC_ABUF_TRANS_ERROR = 3,
    /** Number of transcription types */
    CPRC_ABUF_TRANS_TYPES = 4
};

/** Audio data returned by a speak command */
typedef struct CPRC_abuf CPRC_abuf;

/** Structure to hold transcription data for the audio buffer */
typedef struct CPRC_abuf_trans CPRC_abuf_trans;

/** Syllabic position of the phoneme */
enum CPRC_SYLVAL { CPRC_UNDEF = 0, CPRC_NUC = 1, CPRC_ONSET = 2, CPRC_CODA = 3, CPRC_SYLB = -1 };

/** Structure to hold transcription data for the audio buffer

The transcription holds useful non-speech information about the audio output.
It can be used for a variety of purposes, such as lip syncing for animated
characters (using the phoneme transcriptions), or word highlighting in an
application (using the 'cptk' markers).  User-specified input markers are also
stored in the transcription structure.

All data is also accessible via helper functions.
*/
struct CPRC_abuf_trans {
    /** Text content of the transcription.
    - Phone transcription - text contains the CereProc phoneme string.
    - Word transcription - contains the text of the word being spoken.
    - Marker transcription
      - contains the text of the marker name, as supplied by the user via
        markup such as SSML (e.g. 'marker_test' for
        '<mark name="marker_test"\/>'
      - can also contain a CereProc tokenisation marker. CereProc token markers
        have the form 'cptk_n1_n2_n3_n4', where:
        - n1 - integer character offset of the token
        - n2 - integer byte offset of the token
        - n3 - integer characters length of the token
        - n4 - integer byte length of the token.
        */
    const char *name;
    /** Type of transcription */
    enum CPRC_ABUF_TRANS type;
    /** Start time, in seconds, of the transcription event */
    float start;
    /** Start sample of the transcription event in the wav */
    int start_sample;
    /** End time, in seconds, of the transcription event */
    float end;
    /** End sample of the transcription event in the wav */
    int end_sample;
    /** number of samples in the transcription event */
    int len;
    /** Extra field containing the full phone transcription, only valid for phone type */
    const char *phone;
    /** phone-only index, only valid for phone type */
    int pidx;
    /** If a phoneme this is the stress level */
    char stress;
    /** If this is a phoneme the SAPI viseme */
    int sapi_viseme;
    /** If this is a phoneme the Disney viseme */
    int disney_viseme;
    /** If this is a phoneme the SAPI phone id */
    int sapi_phoneid;
    /** If this is a phoneme the Mac phone id */
    int mac_phoneid;
    /** If this is a phoneme syllabic position */
    enum CPRC_SYLVAL sylval;
};

typedef struct CPTP_phonesetmap CPTP_phonesetmap;

/** Generic fixed buffer structure */
typedef struct CPTP_fixedbuf CPTP_fixedbuf;
struct CPTP_fixedbuf {
    /** Size of the buffer */
    int _size;
    /** Byte sequence */
    byte *_buffer;
};
#endif

/** CereVoice Engine structure

The engine is responsible for loading and maintaining voices.
*/
typedef struct CPRCEN_engine CPRCEN_engine;

/** Handle to a CereVoice Engine Channel

The channel is the main interface to synthesis.  A typical session
begins by creating an engine, loading a voice, then creating a
channel. Multiple channels can be used, as long as the channel handles
are correctly tracked.
*/
typedef int CPRCEN_channel_handle;

/** Channel callback function

Optionally, a user can set their own callback function. This allows
the user to process audio incrementally (phrase by phrase). The
user_data pointer is used to store user-configurable information.
 */
typedef void (*cprcen_channel_callback)(CPRC_abuf *abuf, void *user_data);

/** \name Engine Creation and I/O Functions */
/** @{ */

/** Create an empty engine

The engine is responsible for loading and unloading voices. This
function creates an empty engine, initially with no voices loaded.  The
CPRCEN_engine_load_voice() function must be used to load a voice into
the engine.

Alternatively create an engine using CPRCEN_engine_load() or
CPRCEN_engine_load_config() functions.
*/
CPRCEN_engine *CPRCEN_engine_new();

/** Create an engine and load a voice

Valid license and voice files must be supplied. Additional voices can
be loaded with CPRCEN_engine_load_voice().

Returns NULL if there has been an error.
*/
CPRCEN_engine *CPRCEN_engine_load(const char *voicef, const char *licensef, const char *root_certf, const char *certf,
                                  const char *certkey);

/** Create an engine and load a voice, with configuration

Valid license and voice files must be supplied, along with a configuration
file. Additional voices can be loaded with CPRCEN_engine_load_voice().

Returns NULL if there has been an error.
*/
CPRCEN_engine *CPRCEN_engine_load_config(const char *voicef, const char *voice_configf, const char *licensef,
                                         const char *root_certf, const char *certf, const char *certkey);

/** Load a voice into the engine

A voice file and either 1) valid license or 2) set of IoT credentials
(root CA X.509 certificate, client X.509 certificate and client private key)
to connect with the license server must be supplied. To use the default
configuration pass an empty string as the configf argument.  See the load type
documentation for information on the different load configurations.

Multiple voices can be loaded using this function.  The most recently loaded
voice becomes the default voice for CPRCEN_engine_open_default_channel().

Returns FALSE if there has been an error.
*/
int CPRCEN_engine_load_voice(CPRCEN_engine *eng, const char *voicef, const char *configf,
                             enum CPRC_VOICE_LOAD_TYPE load_type, const char *licensef, const char *root_certf,
                             const char *certf, const char *cert_key);

/** Load a voice into the engine with a license string

A voice file and valid license text and signature must be supplied.  To use the default
configuration pass an empty string as the configf argument.  See the load type
documentation for information on the different load configurations.

The license text must contain the upper part of a license key (key-value pairs e.g. VID=AAA).
The signature is the final 256 character checksum, and must not contain a newline at the end
of the string.

Multiple voices can be loaded using this function.  The most recently loaded
voice becomes the default voice for CPRCEN_engine_open_default_channel().

Returns FALSE if there has been an error.
*/
int CPRCEN_engine_load_voice_licensestr(CPRCEN_engine *eng, const char *license_text, const char *signature,
                                        const char *configf, const char *voicef, enum CPRC_VOICE_LOAD_TYPE load_type);
/** Unload a voice from the engine

Any open channels using the voice are closed automatically.

Note that it is not necessary to unload voices prior to calling
CPRCEN_engine_delete().  CPRCEN_engine_get_voice_count() and
CPRCEN_engine_get_voice_info() should be used to check the loaded
voices.

The index will be less than the number returned by
CPRCEN_engine_get_voice_count().

On success, returns the number of voices currently loaded.  Returns -1
if there has been an error.
*/
int CPRCEN_engine_unload_voice(CPRCEN_engine *eng, int voice_index);

/** Delete and clean up the engine

Deleting the engine cleans up any voices that have been loaded, as well as any
open channels.
 */
void CPRCEN_engine_delete(CPRCEN_engine *eng);

/** Load user lexicon

Simple entries are in the format:
hello h_\@0_l_ou1

The index will be less than the number returned by
CPRCEN_engine_get_voice_count().

Returns FALSE if there has been an error.
*/
int CPRCEN_engine_load_user_lexicon(CPRCEN_engine *eng, int voice_index, const char *fname);

/** Loads a user abbreviation file for the voice

Simple entries are in the format:
Dr	1	doctor
The first column is the abbreviation to match, the second one indicates whether
the following period -if any- should be removed, the third one the replacement.

The index will be less than the number returned by
CPRCEN_engine_get_voice_count().

Returns FALSE if there has been an error.
*/
int CPRCEN_engine_load_user_abbreviations(CPRCEN_engine *eng, int voice_index, const char *fname);

/** Load channel lexicon

Simple entries are in the format:
hello h_\@0_l_ou1

The channel handle must correspond to an open channel. The user
lexicon will be available only on the given channel, as long
as it stays open.

The fname parameter must point to a valid file.

The lname optional parameter allows the user to give a specific
name to the lexicon for use with the

ASCII lexicons as well as compressed lexicon in cerelex formats
are supported. PLS files are loaded with a seperate function.

Returns FALSE if there has been an error.
*/
int CPRCEN_engine_load_channel_lexicon(CPRCEN_engine *eng, CPRCEN_channel_handle chan, const char *fname,
                                       const char *lname);

int CPRCEN_engine_load_channel_pls(CPRCEN_engine *eng, CPRCEN_channel_handle chan, const char *fname,
                                   const char *lname);

int CPRCEN_engine_load_channel_abbreviation(CPRCEN_engine *eng, CPRCEN_channel_handle chan, const char *fname,
                                            const char *aname);

int CPRCEN_engine_load_channel_pbreak(CPRCEN_engine *eng, CPRCEN_channel_handle chan, const char *fname);
/** @} */

/** \name Engine Information Functions */
/** @{ */

/** Return the number of loaded voices */
int CPRCEN_engine_get_voice_count(CPRCEN_engine *eng);

/** Get voice information

Returns a char containing voice information.  The key is a string used to
look up the information about the voice. Useful keys:
- SAMPLE_RATE - sample rate, in hertz, of the voice (e.g. '22050')
- VOICE_NAME - name of the CereProc voice (e.g. 'Sarah')
- LANGUAGE_CODE_ISO - two-letter ISO language code (e.g. 'en')
- COUNTRY_CODE_ISO - two-letter ISO country code (e.g. 'GB')
- SEX - gender of the voice, ('male' or 'female')
- LANGUAGE_CODE_MICROSOFT - Language code used by MS SAPI (e.g. '809')
- COUNTRY - human-readable country description (e.g. 'Great Britain')
- REGION - human-readable region description (e.g. 'England')

The index will be less than the number returned by
CPRCEN_engine_get_voice_count().

Returns an empty string if the key is invalid or the voice does not
exist.
*/
const char *CPRCEN_engine_get_voice_info(CPRCEN_engine *eng, int voice_index, const char *key);

/** Get voice file information

Returns a char containing voice information without loading a voice
into the engine.  The key parameters can be found in the documentation
for CPRCEN_engine_get_voice_info(). The resulting char* will need to be
freed.

Returns an empty string if the key is invalid or the voice does not
exist.
*/
char *CPRCEN_engine_get_voice_file_info(const char *fname, const char *key);

/** Get the number of audio library items

Returns the number of pre-recorded audio items in the voice. In all CereProc
voices that are generally available these are the non-speech vocal gestures
(please see the Vocal Gestures section of the SDK documentation). For custom
voices the library may have additional items which would have been arranged
with CereProc prior to recording.

Returns 0 if the voice does not exist.
*/
int CPRCEN_engine_get_audio_library_size(CPRCEN_engine *eng, int voice_index);

/** Get the name of an audio library item

Returns the name of the library item, required in the 'spurt' tag, 'audio'
attribute to insert the audio into synthesis output. They are of the form
'g0001_004'. For CereProc voices that are generally available the list is
available in the documentation.

Returns an empty string if the index is invalid or the voice does not exist.
*/
const char *CPRCEN_engine_get_audio_library_name(CPRCEN_engine *eng, int voice_index, int library_index);

/** Get the description of an audio library item

Returns a description of the audio library item. For instance in CereProc voices
that are generally available these would include 'cough' and 'err'. Descriptions
are localised to the language of the voice. For CereProc voices that are
generally available the list is available in the SDK documentation.

Returns an empty string if the index is invalid or the voice does not exist.
*/
const char *CPRCEN_engine_get_audio_library_description(CPRCEN_engine *eng, int voice_index, int library_index);

/* NOTE: XML information is not yet implemented */
/** Return XML information on loaded voices */
/* const char * CPRCEN_engine_get_voice_info_xml(CPRCEN_engine * eng); */

/** @} */

/** \name Channel Creation Functions */
/** @{ */

/** Create a new channel handle

The engine is searched for the best match of voice name, ISO language / region
code, and sample rate. Any field can be ignored by using an empty string. The
channel will definately match the language or fail. Region, voice name, and
sample rate will be matched as best as possible.

Returns FALSE if unable to create channel.
*/
CPRCEN_channel_handle CPRCEN_engine_open_channel(CPRCEN_engine *eng, const char *iso_language_code,
                                                 const char *iso_region_code, const char *voice_name,
                                                 const char *srate);

/** Return a new channel handle with a known voice index

A channel is opened using a known voice index. CPRCEN_engine_open_channel is the
better choice when the voice only needs to be suitable. For example if only the
lanugage is important. CPRCEN_engine_open_channel_with_voice should be used when
the exact voice is important. This means that if the license has expired it will
fail to open a channel rather than using a similar voice.

Returns FALSE if unable to create channel.
*/
CPRCEN_channel_handle CPRCEN_engine_open_channel_with_voice(CPRCEN_engine *eng, int voice_index);

/** Return a new channel handle for the default voice

The default channel is useful when a single voice is loaded. When using
multiple voices, the CPRCEN_engine_open_channel() or CPRCEN_engine_open_channel_with_voice()
functions can select between the voices when opening a channel.

Returns FALSE if unable to create channel.
*/
CPRCEN_channel_handle CPRCEN_engine_open_default_channel(CPRCEN_engine *eng);

/** Reset a channel

This function is safe to call inside the callback function.  Future processing
is halted.  The channel is cleaned up by the engine for reuse. It does not
clear the callback - the CPRCEN_engine_clear_callback() should be used to clear
the callback data.

Returns FALSE if there is an error.
*/
int CPRCEN_engine_channel_reset(CPRCEN_engine *eng, CPRCEN_channel_handle chan);

/** Release and delete a channel

This function cannot be called within the callback function.

Returns FALSE if there is an error.
*/
int CPRCEN_engine_channel_close(CPRCEN_engine *eng, CPRCEN_channel_handle chan);

/** @} */

/** \name Channel Callback Functions */
/** @{ */

/** Set a callback function for processing audio incrementally

The callback is fired phrase-by-phrase to allow incremental, low latency,
processing of the speech output. The user_data pointer is used to store
user-configurable information.

After a user callback has been set, speak calls do not return an audio buffer.

Example callback:
\code
// A simple example callback function, appends audio to a file
void channel_callback(CPRC_abuf * abuf, void * userdata) {
   char * f = (char *) userdata;
   CPRC_riff_append(abuf, f);
}
// The callback would be initialised and set like this:
char * outfile = "out.wav";
CPRCEN_engine_set_callback(eng, chan, (void *)outfile, channel_callback);
\endcode

The tts_callback.c and tts_callback.py example programs contain
more extensive callback demonstration code.

Returns FALSE if unable to set the callback.
*/
int CPRCEN_engine_set_callback(CPRCEN_engine *eng, CPRCEN_channel_handle chan, void *userdata,
                               cprcen_channel_callback callback);

/** Clear the callback data

After a user callback has been cleared, speak calls return an audio buffer.

Returns FALSE if unable to clear the callback.
*/
int CPRCEN_engine_clear_callback(CPRCEN_engine *eng, CPRCEN_channel_handle chan);

/** Get the pointer to the user data on a channel

Returns NULL if the user data cannot be retrieved.
*/
void *CPRCEN_engine_get_channel_userdata(CPRCEN_engine *eng, CPRCEN_channel_handle chan);
/** @} */

/** \name Channel Text to Speech Functions */
/** @{ */
/** Speak input text or XML

If no callback is set, a default callback is used and output is appended to
the returned audio buffer.  To clear the output between requests, use the
CPRCEN_engine_clear_callback() function.

If a callback has been set, audio will be processed by the callback function.

If flush is TRUE, regard text as complete and flush the output buffer.

Returns NULL if there is an error (e.g if the channel is not open).
*/
CPRC_abuf *CPRCEN_engine_channel_speak(CPRCEN_engine *eng, CPRCEN_channel_handle chan, const char *text, int textlen,
                                       int flush);

/** @} */

/** @{ */
/** Create an interrupted version of a single spurt

This is used inside a callback for reactive synthesis, the last
spurt xml inside an audio buffer is available with
CPRCEN_engine_chan_get_last_spurt(eng, chan). This function
will then insert an interruption stratagy. It is guaranteed that
up to earliest_time the audio will be identical, however, the actual
interruption point may be later.

Returns NULL if there is an error (e.g if the channel is not open).
*/
CPRC_abuf *CPRCEN_engine_channel_interrupt(CPRCEN_engine *eng, CPRCEN_channel_handle chan, const char *spurtxml,
                                           int xmllen, float earliest_time, enum CPRCEN_INTERRUPT_BOUNDARY_TYPE btype,
                                           enum CPRCEN_INTERRUPT_INTERRUPT_TYPE itype);

/** @} */

/** \name Channel Information Functions */

/** @{ */
/** Get information about the voice

See the CPRCEN_engine_get_voice_info() section for information on the types of
information that are available, and example keys.

Returns an empty string if the key is invalid.
*/
const char *CPRCEN_channel_get_voice_info(CPRCEN_engine *eng, CPRCEN_channel_handle chan, const char *key);

/* NOTE: XML information is not yet implemented */
/** Get XML describing channel attributes */
/* const char * CPRCEN_engine_get_channel_info_xml(CPRCEN_engine * eng, */
/*						CPRCEN_channel_handle chan); */

/** @} */

/** \name Channel Configuration Functions */

/** @{ */
#if !(defined __CPRCEN_ENGINE_H__)
/** Write audio generated on the channel to a file

If the file exists, it is overwritten.  Subsequent
CPRCEN_engine_channel_speak() calls append to the file. If the
CPRCEN_engine_clear_callback() function is called, the output file
will be overwritten again on a speak.  To continually append to a
file, use the CPRCEN_engine_channel_append_to_file() function.

Returns FALSE if there is an error.
*/
int CPRCEN_engine_channel_to_file(CPRCEN_engine *eng, CPRCEN_channel_handle chan, char *fname,
                                  enum CPRCEN_AUDIO_FORMAT format);

/** Append audio generated on the channel to a file

If the file does not exist, it will be created.
If the file name changes then it will start clear the file
Audio continues to be appended to the file after calling CPRCEN_engine_clear_callback().

Returns FALSE if there is an error.
*/
int CPRCEN_engine_channel_append_to_file(CPRCEN_engine *eng, CPRCEN_channel_handle chan, char *fname,
                                         enum CPRCEN_AUDIO_FORMAT format);

/** Append audio generated on the channel to a file

If the file does not exist, it will be created.
Even if the file name is different it will append to the file.
Audio continues to be appended to the file after calling CPRCEN_engine_clear_callback().

Returns FALSE if there is an error.
*/
int CPRCEN_engine_channel_force_append_to_file(CPRCEN_engine *eng, CPRCEN_channel_handle chan, char *fname,
                                               enum CPRCEN_AUDIO_FORMAT format);

/** Stop audio generated on the channel being appended to a file

Returns FALSE if there is an error.
*/
int CPRCEN_engine_channel_no_file(CPRCEN_engine *eng, CPRCEN_channel_handle chan);
#endif

/** Determine if a channel is using a unit selection voice

Returns FALSE if the voice is parameteric or if there is an error.
*/
int CPRCEN_channel_synth_type_usel(CPRCEN_engine *eng, CPRCEN_channel_handle chan);

/** Set the number of phones before audio is generated

Set the minimum and maximum number of phones to process before audio
output is generated. In normal operation, all the phones in a phrase
are processed before the channel callback is fired.  On slower CPUs a
long phrase may introduce unacceptable latency.  This mode can be used
to enable ultra-low latency speech output by setting a range of phones
within which the system must return speech.  For example, setting
min=10 and max=20 will ensure speech output is returned between phones
10 and 20 of the output.

When this mode is enabled, the channel callback will potentially fire
multiple times for each spurt.  The user must only process the data
between the 'wav_mk' and 'wav_done' audio buffer parameters (see
CPRC_abuf_wav_mk() and CPRC_abuf_wav_done()).

This mode only words with unit selection voices.

To reset to the default, call the function with min=0 and max=0.

Returns FALSE if there is an error.
*/
int CPRCEN_channel_set_phone_min_max(CPRCEN_engine *eng, CPRCEN_channel_handle chan, int min, int max);

/** Set the number of samples before audio is generated

Set the approximate amount of samples that are generated before
the channel callback is fired. The callback will still only
fire at phoneme boundaries, so more samples may be present.
It will also still always fire at the end of a phrase.

When this mode is enabled, the channel callback will potentially fire
multiple times for each spurt.  The user must only process the data
between the 'wav_mk' and 'wav_done' audio buffer parameters (see
CPRC_abuf_wav_mk() and CPRC_abuf_wav_done()).

This mode is turned on by default for DNN voices.  To disable it, set
pipelen=0.  Any override must be set for each channel as it is opened.

This mode only works with parametric voices.

Returns FALSE if there is an error.
*/
int CPRCEN_channel_set_pipe_length(CPRCEN_engine *eng, CPRCEN_channel_handle chan, int pipelen);

/** @} */

/** \name Audio Output Buffer Transcription Functions */
/** @{ */

/** Return a pointer to the transcription structure at index i

Returns NULL if the index i is out of bounds.
*/
extern const CPRC_abuf_trans *CPRC_abuf_get_trans(CPRC_abuf *ab, int i);

/** Return the size of the transcription data */
extern int CPRC_abuf_trans_sz(CPRC_abuf *ab);

/** Return the name of the transcription element

Returns an empty string if there has been an error.
*/
extern const char *CPRC_abuf_trans_name(const CPRC_abuf_trans *t);

/** Return the type of the transcription element

Returns CPRC_ABUF_TRANS_ERROR if there has been an error.
 */
extern enum CPRC_ABUF_TRANS CPRC_abuf_trans_type(const CPRC_abuf_trans *t);

/** Return start time (in seconds) of a transcription element

Returns -1.0 if there has been an error.
*/
extern float CPRC_abuf_trans_start(const CPRC_abuf_trans *t);
extern float CPRC_abuf_trans_end(const CPRC_abuf_trans *t);

/** Return first sample of a transcription element
 *

Returns -1 if there has been an error.
*/
extern int CPRC_abuf_trans_start_sample(const CPRC_abuf_trans *t);
extern int CPRC_abuf_trans_end_sample(const CPRC_abuf_trans *t);

/** Return the stress level or tone of transcription element

Returns -1 if the element is not a phone or there has been an error
*/
int CPRC_abuf_trans_phone_stress(const CPRC_abuf_trans *t);

/** Return the SAPI viseme of a transcription element

Returns -1 if the element is not a phone or there has been an error
*/
extern int CPRC_abuf_trans_sapi_viseme(const CPRC_abuf_trans *t);

/** Return the Disney viseme of a transcription element

Returns -1 if the element is not a phone or there has been an error
*/
extern int CPRC_abuf_trans_disney_viseme(const CPRC_abuf_trans *t);

/** Return the SAPI phoneid of a transcription element

Returns -1 if the element is not a phone or there has been an error
*/
extern int CPRC_abuf_trans_sapi_phoneid(const CPRC_abuf_trans *t);

/** Return the Mac phoneid of a transcription element

Returns -1 if the element is not a phone or there has been an error
*/
extern int CPRC_abuf_trans_mac_phoneid(const CPRC_abuf_trans *t);

/** \name Audio Output Buffer Access and Information Functions */
/** @{ */

/** Get length of the audio data in an audio buffer */
extern int CPRC_abuf_wav_sz(CPRC_abuf *ab);

/** Get a single sample from the audio data

Returns 0 if the index i is out of bounds */
extern short CPRC_abuf_wav(CPRC_abuf *ab, int i);

/** Get a pointer to the raw audio data */
extern short *CPRC_abuf_wav_data(CPRC_abuf *ab);

/** Get a pointer to the start of the newly added raw audio data */
extern short *CPRC_abuf_wav_mk_data(CPRC_abuf *ab);

/** Get the start index of safe data to process */
extern int CPRC_abuf_wav_mk(CPRC_abuf *ab);

/** Get the end index of safe data to process (inclusive) */
extern int CPRC_abuf_wav_done(CPRC_abuf *ab);

/** Amount of samples added to the abuf in this callback */
extern int CPRC_abuf_added_wav_sz(CPRC_abuf *ab);

/** Get the start index of safe trans events to process  */
extern int CPRC_abuf_trans_mk(CPRC_abuf *ab);

/** Get the end index of safe trans events to process (inclusive) */
extern int CPRC_abuf_trans_done(CPRC_abuf *ab);

/** Get the sample rate of the audio buffer

The CPRCEN_engine_get_voice_info() and CPRCEN_channel_get_voice_info()
functions should normally be used to access voice-related sample rate
information, as the audio buffer sample rate is changed to match the voice
(if necessary) at synthesis time.
*/
extern int CPRC_abuf_wav_srate(CPRC_abuf *ab);

/** @} */

/** \name Audio Output Buffer Save Functions */
/** @{ */

/** Save the audio data as a RIFF wave file

Returns FALSE if there has been an error.
*/
int CPRC_riff_save(CPRC_abuf *wav, const char *fname);

/** Append the audio data to a RIFF wave file

Returns FALSE if there has been an error.
*/
int CPRC_riff_append(CPRC_abuf *wav, const char *fname);

/** Save the transcription section of the audio buffer

Returns FALSE if there has been an error.
*/
int CPRC_riff_save_trans(CPRC_abuf *wav, const char *fname);

/** @} */

/** \name Advanced Audio Output Buffer Functions */

/** @{ */

/** Copy audio to a RIFF buffer

Copy the audio to a fixed in-memory buffer containing a RIFF header
and the audio data.  This can be useful for playing back in-memory
audio in some applications, avoiding the need to write audio to disk.
*/
CPTP_fixedbuf *CPRC_riff_buffer(CPRC_abuf *wav);

/** Delete a fixed buffer

Delete a buffer as returned by CPRC_riff_buffer().
*/
void CPTP_fixedbuf_delete(CPTP_fixedbuf *fb);

/**  Make a copy of an audio buffer

Make a copy of an audio buffer.  Useful if the user wishes to process
audio on a separate thread and allow the callback to continue. Must be
cleaned up after use.
*/
extern CPRC_abuf *CPRC_abuf_copy(CPRC_abuf *ab);

/** Extract a portion of an audio buffer

When pipelining, this function allows the user to create a new abuf
containing the a subset of the audio data in an existing abuf, normally
used to create a copy of newly added audio. Must be cleaned up after use
with 'CPRC_abuf_delete'.

Sample call:
\code
CPRC_abuf * abuf_copy = CPRC_abuf_extract(
    ab, CPRC_abuf_wav_mk(ab), CPRC_abuf_added_wav_sz(ab)
);
\endcode
*/
extern CPRC_abuf *CPRC_abuf_extract(CPRC_abuf *ab, int offset, int sz);

/** Delete an audio buffer

Clean up an audio buffer.  If a user creates a buffer with
CPRC_abuf_copy() or CPRC_abuf_extract(), they should delete it with
this function when finished processing.
*/
extern void CPRC_abuf_delete(CPRC_abuf *ab);

/** Append an audio buffer after another */
extern CPRC_abuf *CPRC_abuf_append(CPRC_abuf *ab_out, CPRC_abuf *ab_in);

extern int CPRCEN_major_version();
extern int CPRCEN_minor_version();
extern int CPRCEN_revision_number();

/** @} */

#ifdef __cplusplus
}
#endif

#endif /* __CEREVOICE_ENG_H__ */
