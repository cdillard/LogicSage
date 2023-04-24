#ifndef __CEREVOICE_AUD_H__
#define __CEREVOICE_AUD_H__

/* $Id:
 *=======================================================================
 *
 *                       Copyright (c) 2005-2019 CereProc Ltd.
 *                       All Rights Reserved.
 *
 *=======================================================================
 */

/* Matthew Aylett: 051205 */

/* API to cerevoice */

/** \file cerevoice_aud.h

Cross platform API to a PortAudio-based audio player. This API can be
used to play back audio on Windows, Linux and Mac OS X.  The user
creates an audio sound cue, which is passed to an audio player.
Multiple cues can be added to a player, allowing a sequence of audio
to be played.
*/

#ifdef __cplusplus
extern "C" {
#endif

/** Status of an audio sound cue

Users wanting to monitor the status of a cue must use the
CPRC_sc_audio_short() function to create the cues, and then delete the
cues themselves. CPRC_sc_audio_short_disposable() must not be used, as
the cues are automatically deleted after playback.
*/
enum CPRC_SC_STAT {
    /** Waiting to be played */
    CPRC_SC_WAITING = 0,
    /** In the middle of being played */
    CPRC_SC_PLAYING_MID = 1,
    /** About to finish playing */
    CPRC_SC_PLAYING_LAST_FRAME = 2,
    /** Playback complete */
    CPRC_SC_PLAYED = 3
};

/** Playback status of an audio sound cue

If it is successful (TRUE), it also says whether the stream had to be restarted
(a pause is likely before the sound cue if a restart has occurred).
*/
enum CPRCTHD_CUE {
    /** Playback failed */
    CPRC_CUE_ERROR = 0,
    /** Playback was successful */
    CPRC_CUE_OK = 1,
    /** Playback was successful, but the stream had to be restarted */
    CPRC_CUE_RESTART = 2
};

/** Channel type of an audio sound cue

Can be either Mono/Stereo, but default is Mono.
 */
enum CPRC_SC_CHANNEL {
    /** Channel type used is Mono */
    CPRC_SC_MONO = 0,
    /** Channel type used is Stereo */
    CPRC_SC_STEREO = 1
};

/** Audio sound cue

An audio sound cue is a segment of audio. It can be created and then
queued to play in the sound cue player.
 */
typedef struct CPRC_sc_audio CPRC_sc_audio;

/** Audio sound cue player

The player streams audio sound cues that have been cued onto it.  Only
one player should be playing at any one time, although the interaction
the player has with the OS will depend on how PortAudio is configured.
*/
typedef struct CPRC_sc_player CPRC_sc_player;

/** Used by SWIG to accept a python string of audio correctly */
#ifndef WAVEDATA_DEF
#define WAVEDATA_DEF
typedef char wavedata;
#endif

/** Create a new sound cue player

The player will play 16 bit audio. The sample rate must be set. If the
system does not support the sample rate, the player will not be
created.
*/
CPRC_sc_player *CPRC_sc_player_new(int sample_rate);

/** Clean up sound cue player

Clean up the player. If CPRC_sc_audio_short() has been used to create
the sound cues, the user must clean up the cues themselves.
*/
void CPRC_sc_player_delete(CPRC_sc_player *player);

/** Current stream time of a player

Used to know how much audio has been played on a busy stream. This is used
to synchronise played audio with other processes (such as word
highlighting). Note that the time will keep running when the stream is
paused, and that the origin is unspecified.
*/
double CPRC_sc_player_stream_time(CPRC_sc_player *player);

/** Total audio duration played through the player.

Returns excatly how much audio has been played on a busy stream. This is used
to synchronise played audio with other processes (such as word
highlighting). This duration is "pause-aware", i.e. the duration is not increased
while the system is paused.
*/
double CPRC_sc_player_stream_duration(CPRC_sc_player *player);

/** Current number of samples that have been sent through the player.

Returns exactly how much audio samples from the wav files have been
sent to portaudio. This is used to synchronise played audio with
other processes (such as word highlighting). The sample count is reset
when the player is stopped, is paused when the player is paused.
*/
long int CPRC_sc_player_samples_sent(CPRC_sc_player *player);

/** Current sample rate of the player.

Returns the current sample rate of the player.  The sample rate cannot
be adjusted dynamically, so this function can be used to check that
the player is appropriate for an input sample rate.
 */
int CPRC_sc_player_sample_rate(CPRC_sc_player *player);

/** Create an audio sound cue

Create and audio sound cue from a buffer of shorts.  The cues created
must be cleaned up by the user with the CPRC_sc_audio_delete()
function.  These cues can be monitored for their status and start
time etc.
*/
CPRC_sc_audio *CPRC_sc_audio_short(short *data, int len);

/** Create an audio sound cue with an offset

Create and audio sound cue from a buffer of shorts with an offset as
a starting point.  The cues created must be cleaned up by the user
with the CPRC_sc_audio_delete() function.  These cues can be monitored
for their status and start time etc.
*/

CPRC_sc_audio *CPRC_sc_audio_short_offset(short *data, int offset, int len);

/** Create a disposable audio sound cue

Create a disposable audio sound cue from a buffer of shorts. This
buffer is cleaned up automatically after it is played, so should not be
polled for cue status updates.
*/
CPRC_sc_audio *CPRC_sc_audio_short_disposable(short *data, int len);

/** Create an audio sound cue

Create an audio sound cue from a buffer of shorts, with control over
allocation.  Memory allocation is the default behaviour for
CPRC_sc_audio_short() and CPRC_sc_audio_short_disposable(). This
function cannot be used to create disposable cues.
*/
CPRC_sc_audio *CPRC_sc_audio_short_alloc(short *data, int offset, int len, int alloc);

/** Create a pure tone audio sound cue, freq is in hertz, len is in samples */
CPRC_sc_audio *CPRC_sc_audio_tone(int sample_rate, double freq, int len);

/** Create an audio sound cue from a Python string (SWIG wrapped) */
CPRC_sc_audio *CPRC_sc_audio_pythonstr(wavedata *data, int len);

/** Status of an audio sound cue

The sound cue should not be deleted until its status is set to played.
Do not use this function on disposable sound cues, as they are cleaned
up automatically after playback.
*/
enum CPRC_SC_STAT CPRC_sc_audio_status(CPRC_sc_audio *audio);

/** Type of channel used in an audio sound cue

Returns the current channel type of the audio sound cue. Defaults is
CPRC_SC_MONO.
 */
enum CPRC_SC_CHANNEL CPRC_sc_audio_channel_type(CPRC_sc_audio *audio);

/** Sets the type of channel used in an audio sound cue

Can be set to either Stereo/Mono. Default is Mono.
*/
void CPRC_sc_audio_channel(CPRC_sc_audio *audio, enum CPRC_SC_CHANNEL chan);

/** Start time of a playing (or played) audio cue

Do not use this function on disposable sound cues, as they are cleaned
up automatically after playback.
*/
double CPRC_sc_audio_start_time(CPRC_sc_audio *audio);

/** Clean up an sound cue

Audio cues created using CPRC_sc_audio_short() or
CPRC_sc_audio_short_alloc() must be cleaned up by the user. They are
reatined in memory after playing so that timing information can be
acessed.
 */
void CPRC_sc_audio_delete(CPRC_sc_audio *audio);

/** Reset and play an audio sound cue

This function resets the player and starts playing the cue supplied.
To cue up audio for playback in a stream, use CPRC_sc_audio_cue().
*/
int CPRC_sc_audio_play(CPRC_sc_player *player, CPRC_sc_audio *cue);

/** Queue up an audio sound cue

Adds the cue to the list of currently playing sounds.  The cue will be
played when previously cued audio has finished playing.  If no audion
is playing, behaviour is the same as CPRC_sc_audio_play().
*/
enum CPRCTHD_CUE CPRC_sc_audio_cue(CPRC_sc_player *player, CPRC_sc_audio *cue);

/** Insert an audio sound cue into the queue

Adds the cue to the list of currently playing sounds at the given index.
If this is beyond the range of the current queue then it will be
appened to the end. Otherwise the behviour is the same as
CPRC_sc_audio_cue(player, cue)
*/
enum CPRCTHD_CUE CPRC_sc_audio_cue_insert(CPRC_sc_player *player, CPRC_sc_audio *cue, int idx);

/** Sleep for this many milliseconds

Based on PortAudio internal cross platform sleep function,
used to help synchronise audio events.
*/
void CPRC_sc_sleep_msecs(int msecs);

/** TRUE if the player is playing audio */
int CPRC_sc_audio_busy(CPRC_sc_player *player);

/** Pause playback

Returns TRUE if player can be paused.
*/
int CPRC_sc_audio_pauseon(CPRC_sc_player *player);

/** Resume playback

Returns TRUE if player can be restarted.
*/
int CPRC_sc_audio_pauseoff(CPRC_sc_player *player);

int CPRC_sc_audio_paused(CPRC_sc_player *player);

/** Stop playback

Returns TRUE if the player can be halted
*/
int CPRC_sc_audio_stop(CPRC_sc_player *player);

/** Skip to the next sound cue

Skip to the next audio cue lined up in the player; either
skip to the start of the next cue or to the current position
of the cue currently playing. The second option is primarily
used interactive systems which need to change what is being
said. If the new cue is shorter and the current position is
beyond the end of the cue, then it will continue with the next
cue in the queue, and it will return FALSE. Returns TRUE if
it successfully skipped.
*/
int CPRC_sc_audio_skip(CPRC_sc_player *player, int tostart);

#ifdef __cplusplus
}
#endif

#endif /* __CEREVOICE_AUD_H__ */
