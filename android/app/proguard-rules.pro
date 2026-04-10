# AudioPlayers - Reglas ProGuard
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }
-keep class com.google.android.exoplayer2.mediacodec.** { *; }

-keep class com.google.android.exoplayer2.ext.** { *; }
-keep interface com.google.android.exoplayer2.ext.** { *; }

# AudioPlayers library
-keep class xyz.luan.audioplayers.** { *; }
-keep interface xyz.luan.audioplayers.** { *; }

# MediaPlayer
-keep class android.media.MediaPlayer { *; }
-keep class android.media.AudioManager { *; }
-keep class android.media.SoundPool { *; }

# Android Media Framework
-keep class android.media.** { *; }
-keep interface android.media.** { *; }

# Reflection para Android
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Evitar que se eliminen métodos importantes
-keepclassmembers class * {
    public <init>(...);
    public <clinit>();
}

# Mantener métodos nativos
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flame Audio
-keep class org.flame_engine.** { *; }
-keep interface org.flame_engine.** { *; }

# Shared Preferences
-keep class android.content.SharedPreferences { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }

# Optimización: Remover logs de DEBUG y INFO
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
