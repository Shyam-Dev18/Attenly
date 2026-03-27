# Flutter + Hive + flutter_local_notifications ProGuard rules

# Keep flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep Hive adapters and models
-keep class com.example.attenly_app.** { *; }
-keep class ** extends io.objectbox.converter.PropertyConverter { *; }
-keep class ** implements java.io.Serializable { *; }

# Keep Go Router
-keep class com.google.gson.** { *; }

# Keep Kotlin/Flutter internals
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile
-keepattributes LineNumberTable

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimization settings
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Remove unused resources
-dontnote android.net.http.**
-dontnote sun.misc.Unsafe
-dontnote com.google.common.**
-dontwarn com.google.android.play.core.**
-dontwarn javax.lang.model.element.Modifier
