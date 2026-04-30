#########################
# FIREBASE & GOOGLE PLAY (CRÍTICO PARA AUTENTICACIÓN)
#########################

# Firebase Auth - DEBE mantenerse intacto
-keep class com.google.firebase.auth.** { *; }
-keep interface com.google.firebase.auth.** { *; }
-keep class com.google.firebase.auth.internal.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep interface com.google.android.gms.auth.** { *; }

# Firebase Database/Realtime DB
-keep class com.google.firebase.database.** { *; }
-keep interface com.google.firebase.database.** { *; }
-keep class com.google.firebase.database.core.** { *; }

# Google Play Services - Necesario para autenticación
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.auth.api.** { *; }
-keep class com.google.android.gms.auth.api.identity.** { *; }

# Google Services Configuration (google-services.json)
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep interface com.google.android.gms.tasks.** { *; }

# Firebase - General
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-keep class com.google.firebase.common.** { *; }
-keep class com.google.firebase.analytics.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep interface com.google.android.gms.auth.api.signin.** { *; }

# Kotlin Metadata - Crítico para Kotlin/Java interop
-keep class kotlin.Metadata { *; }
-keep class kotlin.reflect.** { *; }
-keepattributes RuntimeVisibleAnnotations,RuntimeVisibleParameterAnnotations

# Reflection attributes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile
-keepattributes LineNumberTable

# Constructores y métodos estáticos (necesarios para reflexión)
-keepclassmembers class * {
    public <init>(...);
    public <clinit>();
    public static ** create(...);
}

# Métodos nativos
-keepclasseswithmembernames class * {
    native <methods>;
}

#########################
# AUDIOPLAYERS
#########################

# AudioPlayers - ExoPlayer v2
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }
-keep class com.google.android.exoplayer2.mediacodec.** { *; }
-keep class com.google.android.exoplayer2.ext.** { *; }
-keep interface com.google.android.exoplayer2.ext.** { *; }
-keep class com.google.android.exoplayer2.database.** { *; }

# Audioplayers Android (xyz.luan.audioplayers)
-keep class xyz.luan.audioplayers.** { *; }
-keep interface xyz.luan.audioplayers.** { *; }
-keep class xyz.luan.audioplayers.source.** { *; }

# MediaPlayer
-keep class android.media.MediaPlayer { *; }
-keep class android.media.AudioManager { *; }
-keep class android.media.SoundPool { *; }
-keep class android.media.MediaMetadataRetriever { *; }

# Audio Focus y Session Management
-keep class android.media.AudioAttributes { *; }
-keep class android.media.AudioAttributes$* { *; }
-keep class android.media.AudioFocusRequest { *; }

# Android Media Framework
-keep class android.media.** { *; }
-keep interface android.media.** { *; }

# Flame Audio
-keep class org.flame_engine.** { *; }
-keep interface org.flame_engine.** { *; }

#########################
# AUDIOPLAYERS
#########################

# AudioPlayers - ExoPlayer v2
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }
-keep class com.google.android.exoplayer2.mediacodec.** { *; }
-keep class com.google.android.exoplayer2.ext.** { *; }
-keep interface com.google.android.exoplayer2.ext.** { *; }
-keep class com.google.android.exoplayer2.database.** { *; }

# Audioplayers Android (xyz.luan.audioplayers)
-keep class xyz.luan.audioplayers.** { *; }
-keep interface xyz.luan.audioplayers.** { *; }
-keep class xyz.luan.audioplayers.source.** { *; }

# MediaPlayer
-keep class android.media.MediaPlayer { *; }
-keep class android.media.AudioManager { *; }
-keep class android.media.SoundPool { *; }
-keep class android.media.MediaMetadataRetriever { *; }

# Audio Focus y Session Management
-keep class android.media.AudioAttributes { *; }
-keep class android.media.AudioAttributes$* { *; }
-keep class android.media.AudioFocusRequest { *; }

# Android Media Framework
-keep class android.media.** { *; }
-keep interface android.media.** { *; }

# Flame Audio
-keep class org.flame_engine.** { *; }
-keep interface org.flame_engine.** { *; }

# Shared Preferences
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$* { *; }

# Google Play Services (para AdMob)
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }

# Google Play Core (Play Store features - optional)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep interface com.google.android.gms.ads.** { *; }

# Flutter embedder
-keep class io.flutter.** { *; }
-keep interface io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Kotlin standard library (importante para Android KTX)
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Proteger métodos callback
-keepclassmembers class * extends android.content.** {
    public void on*(...);
    protected void on*(...);
}

# Asset loading
-keep class android.content.res.AssetManager { *; }
-keep class android.content.res.AssetFileDescriptor { *; }

# Optimización: Remover logs de DEBUG y INFO solamente en release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
