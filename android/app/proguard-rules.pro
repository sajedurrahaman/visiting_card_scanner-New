# ML Kit text recognition (optional language packs not bundled)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# TensorFlow Lite (ML Kit OCR)
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
