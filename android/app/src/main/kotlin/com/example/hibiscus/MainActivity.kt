package com.example.hibiscus

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
  private val channelName = "hibiscus/export"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
      when (call.method) {
        "saveVideoToGallery" -> {
          val args = call.arguments as? Map<*, *>
          val path = args?.get("path") as? String
          val name = args?.get("name") as? String
          if (path.isNullOrBlank()) {
            result.error("BAD_ARGS", "Missing path", null)
            return@setMethodCallHandler
          }
          try {
            saveVideoToGallery(path, name ?: File(path).name)
            result.success(null)
          } catch (e: Exception) {
            result.error("SAVE_FAILED", e.message, null)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun mimeTypeForName(name: String): String {
    val lower = name.lowercase()
    return when {
      lower.endsWith(".mp4") -> "video/mp4"
      lower.endsWith(".mov") -> "video/quicktime"
      lower.endsWith(".mkv") -> "video/x-matroska"
      else -> "video/*"
    }
  }

  private fun saveVideoToGallery(path: String, displayName: String) {
    val src = File(path)
    if (!src.exists()) throw IllegalArgumentException("File not found")
    val resolver = applicationContext.contentResolver
    val values = ContentValues().apply {
      put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
      put(MediaStore.MediaColumns.MIME_TYPE, mimeTypeForName(displayName))
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/Hibiscus")
        put(MediaStore.MediaColumns.IS_PENDING, 1)
      }
    }
    val collection = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
    val uri = resolver.insert(collection, values) ?: throw RuntimeException("MediaStore insert failed")

    resolver.openOutputStream(uri)?.use { out ->
      FileInputStream(src).use { input ->
        input.copyTo(out)
      }
    } ?: throw RuntimeException("OpenOutputStream failed")

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      values.clear()
      values.put(MediaStore.MediaColumns.IS_PENDING, 0)
      resolver.update(uri, values, null, null)
    }
  }
}
