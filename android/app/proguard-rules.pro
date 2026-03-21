# Flutter + Hive + flutter_local_notifications ProGuard rules

# Keep flutter_local_notifications receivers
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep Hive generated code
-keep class ** extends ** { *; }

# Prevent stripping Kotlin coroutines internals
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
