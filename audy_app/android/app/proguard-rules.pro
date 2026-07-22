# TensorFlow Lite GPU Delegate
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.** { *; }

# Keep all TensorFlow Lite class members
-keepclassmembers class org.tensorflow.lite.** { *; }

# Keep native methods for TensorFlow Lite
-keepclasseswithmembernames class * {
    native <methods>;
}
