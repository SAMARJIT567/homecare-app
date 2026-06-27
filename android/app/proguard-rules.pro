# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# ✅ Fix for Google Play Core missing classes
-dontwarn com.google.android.play.core.**

# Keep your application classes
-keep class com.example.homecare_app.** { *; }

# ✅ KEEP MODELS (Critical for Release Build)
# This prevents R8 from renaming fields that map to JSON keys
-keep class com.example.homecare_app.models.** { *; }
-keep class com.example.homecare_app.admin.models.** { *; }
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Connectivity Plus rules
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Dio and OkHttp rules
-keep class com.dio.** { *; }
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# General rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Diagnostic: Disable obfuscation to ensure the UI data shows up correctly
-dontobfuscate
-dontoptimize
