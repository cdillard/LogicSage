#if !(defined __CEREVOICE_ENG_SIMP_H__)
#define __CEREVOICE_ENG_SIMP_H__
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

/* Simple API to the CereVoice Engine */

/** \file cerevoice_eng_simp.h

Simple CereVoice Engine Text to Speech API
*/

#ifdef __cplusplus
extern "C" {
#endif

#if !(defined __CEREVOICE_ENG_H__)
/** CereVoice Engine structure

The engine is responsible for loading a voice.  Simple API calls
perform synthesis using the engine.  Output is to an audio buffer or
wave file.

To manipulate multiple voices, process audio incrementally, access
transcriptions, and add custom lexicons, use the cerevoice_eng.h API.
*/
typedef struct CPRCEN_engine CPRCEN_engine;
#endif

/** Simplified CereVoice Engine audio container */
typedef struct CPRCEN_wav CPRCEN_wav;

/** Simplified CereVoice Engine audio container */
struct CPRCEN_wav {
    /** Linear PCM short data pointer */
    short *wavdata;
    /** Size of the wavdata */
    int size;
    /** Sample rate of the output audio */
    int sample_rate;
};

/** \name Simple API I/O Functions
 */
/** @{ */

/** Create an engine and load a voice

Valid license and voice files must be supplied.

Returns NULL if there has been an error.
*/
CPRCEN_engine *CPRCEN_engine_load(const char *voicef, const char *licensef, const char *root_certf, const char *certf,
                                  const char *certkey);

/** Create an engine and load a voice with a configuration file

Valid license and voice files must be supplied, along with a configuration
file.

Returns NULL if there has been an error.
*/
CPRCEN_engine *CPRCEN_engine_load_config(const char *voicef, const char *voice_configf, const char *licensef,
                                         const char *root_certf, const char *certf, const char *certkey);

/** Delete and clean up the engine

Deleting the engine cleans up any voices that have been loaded.
 */
void CPRCEN_engine_delete(CPRCEN_engine *eng);

/** @} */

/** \name Simple API Text to Speech Functions */
/* @{ */

/** Speak text using the engine

Speaks the supplied text or XML.  A voice must first be loaded into the engine.
Returns a CPRCEN_wav audio data structure that can be manipulated by the user.

If called multiple times, audio is appended to the output. The
CPRCEN_engine_clear() function can be used to clear the output buffer.

Returns NULL if there has been an error.
*/
CPRCEN_wav *CPRCEN_engine_speak(CPRCEN_engine *eng, const char *text);

/** Speak text to a wave file using the engine

Speaks the supplied text or XML and writes the output to a wave file. A voice
must first be loaded into the engine.

If the output file exists, it will be overwritten.  Subsequent calls to the
function then append audio to the file.

If CPRCEN_engine_clear() is called, the next call to the function overwrites
an existing file, and subsequent calls append audio.

Returns FALSE if there has been an error.
*/
int CPRCEN_engine_speak_to_file(CPRCEN_engine *eng, const char *text, const char *fname);

/** Clear the output data

Clears the output CPRCEN_wav data.

Returns FALSE if there has been an error.
*/
int CPRCEN_engine_clear(CPRCEN_engine *eng);

/* @} */

#ifdef __cplusplus
}
#endif

#endif /* __CEREVOICE_ENG_SIMP_H__ */
