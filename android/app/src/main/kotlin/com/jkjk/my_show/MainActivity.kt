package com.jkjk.my_show

import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

class MainActivity: FlutterActivity() {
  private var lastBackPress = 0L

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.jkjk.my_show").setMethodCallHandler { call, result ->
      if (call.method == "backToExit") {
        result.success(backToExit())
      } else {
        result.notImplemented()
      }
    }
  }

  private fun backToExit(): Boolean {
    val now = System.currentTimeMillis()
    val diff = now - lastBackPress
    lastBackPress = now
    if (diff > 2000L) {
      Toast.makeText(this, "Press again to exit", Toast.LENGTH_SHORT).show()
      return false
    } else {
      return true
    }
  }
}
