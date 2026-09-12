# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive & Type Adapters
-keep class io.hive.** { *; }
-keep @io.hive.HiveType class * { *; }
-keepclassmembers class * {
    @io.hive.HiveField *;
}

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Wakelock Plus
-keep class dev.fluttercommunity.plus.wakelock.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Prevent obfuscation of generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Desugaring
-dontwarn java.time.**

# Play Core Deferred Components
-dontwarn com.google.android.play.core.**
