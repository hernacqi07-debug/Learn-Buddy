package com.learnbuddy.app.learn_buddy

import com.google.ar.core.ArCoreApk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, "learn_buddy/ar_check").setMethodCallHandler { call, result ->
            if (call.method == "checkArAvailability") {
                val availability = ArCoreApk.getInstance().checkAvailability(this)
                result.success(availability.name)
            } else {
                result.notImplemented()
            }
        }

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "learn_buddy/ar_view",
            LearnBuddyArViewFactory(this, messenger)
        )
    }
}
