package com.knife_clicker


import io.flutter.embedding.android.FlutterActivity
import android.media.AudioManager
import android.os.Build

class MainActivity : FlutterActivity() {
    override fun onPostResume() {
        super.onPostResume()
        // Configurar el stream de volumen a MUSIC para que los botones de volumen controlen el audio
        volumeControlStream = AudioManager.STREAM_MUSIC
        debugPrintln("[MainActivity] ✓ Volume control stream set to STREAM_MUSIC")
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Asegurar que el AudioManager está configurado correctamente
        val audioManager = getSystemService(android.content.Context.AUDIO_SERVICE) as AudioManager
        // Inicializar con volumen de música visible (no silencioso)
        audioManager.requestAudioFocus(
            null,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN
        )
        debugPrintln("[MainActivity] ✓ Audio focus requested for STREAM_MUSIC")
    }

    private fun debugPrintln(message: String) {
        System.err.println(message)
    }
}
