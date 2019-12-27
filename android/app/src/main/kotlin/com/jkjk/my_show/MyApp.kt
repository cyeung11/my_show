package com.jkjk.my_show

import com.jkjk.my_show.model.TvDetails
import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MyApp : FlutterApplication(), MethodChannel.MethodCallHandler {

    lateinit var flutterEngine: FlutterEngine

    val data = arrayListOf<TvDetails>()

    override fun onCreate() {
        super.onCreate()
        flutterEngine = FlutterEngine(this)

        flutterEngine.dartExecutor.executeDartEntrypoint(DartEntrypoint.createDefault())

        FlutterEngineCache.getInstance().put("my_show_id", flutterEngine);


        val shimPluginRegistry = ShimPluginRegistry(flutterEngine)
        GeneratedPluginRegistrant.registerWith(shimPluginRegistry)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "backToExit") {
            val currentAct = currentActivity as? MainActivity
            result.success(currentAct?.backToExit() ?: true)
        } else {
            result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "com.jkjk.my_show"
        const val CHANNEL_TO_FLUTTER = "com.jkjk.my_show.to_flutter"
    }
}