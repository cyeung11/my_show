package com.jkjk.my_show

import android.content.Context
import android.os.Bundle
import android.os.PersistableBundle
import android.widget.Toast
import com.jkjk.my_show.MyApp.Companion.CHANNEL
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
  private var lastBackPress = 0L

  override fun provideFlutterEngine(context: Context): FlutterEngine? {
    return (application as MyApp).flutterEngine
  }

  override fun onResume() {
    super.onResume()
    (application as MyApp).currentActivity = this
  }

  override fun onPause() {
    (application as MyApp).currentActivity = null
    super.onPause()
  }

  fun backToExit(): Boolean {
    val now = System.currentTimeMillis()
    val diff = now - lastBackPress
    lastBackPress = now
    if (diff > BACK_TIME_OUT) {
      Toast.makeText(this, "Press again to exit", Toast.LENGTH_SHORT).show()
      return false
    } else {
      return true
    }
  }

  companion object {
    const val BACK_TIME_OUT = 2000L
  }
}
