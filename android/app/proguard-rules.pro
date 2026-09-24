# Keep uCrop classes (used by image_cropper plugin).
# R8 strips these in release builds, causing NoClassDefFoundError crashes.
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
