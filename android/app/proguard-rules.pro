# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# PayU ProGuard Rules
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-keep class com.payu.** { *; }
-keep class in.payu.** { *; }
-keep class com.payubiz.** { *; }

# Suppress missing optional classes for R8
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-dontwarn com.payu.**
-dontwarn in.payu.**
-dontwarn **
