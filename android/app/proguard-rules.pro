# Keep ML Kit Text Recognition classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep Google Play Services classes used by ML Kit
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
