package com.jkjk.my_show.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_ID
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.JobIntentService
import com.jkjk.my_show.MyApp
import com.jkjk.my_show.R
import io.flutter.plugin.common.MethodChannel

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class AppWidgetJobIntentService : JobIntentService() {

    override fun onHandleWork(intent: Intent) {
        if (intent.action?.isNotBlank() == true) {
            val id = intent.getIntExtra(TvWidgetRemoteFactory.EXTRA_TV_ID, -1)
            if (id != -1) {
                MethodChannel((application as MyApp).flutterEngine.dartExecutor.binaryMessenger, MyApp.CHANNEL_TO_FLUTTER).invokeMethod(
                        if (intent.action == getString(R.string.action_add_progress)) "progressIncrement" else "progressDecrement", id, object : MethodChannel.Result{
                    override fun notImplemented() {
                    }

                    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                    }

                    override fun success(result: Any?) {
                        val widgetMan = AppWidgetManager.getInstance(this@AppWidgetJobIntentService)
                        val ids = widgetMan.getAppWidgetIds(ComponentName(this@AppWidgetJobIntentService, TvWidget::class.java))
                        if (ids?.isNotEmpty() == true) {
                            TvWidget.updateWidget(this@AppWidgetJobIntentService, ids)
                        }
                    }
                })
            }
        } else {
            handleIntent(this, intent)
        }
    }

    companion object {
        const val REQUEST_CODE_PROGRESS_ADD_JOB = 45546
        const val REQUEST_CODE_PROGRESS_REDUCE_JOB = 45545

        fun enqueueWidget(context: Context, widgetIds: IntArray) {
            val intent = Intent().putExtra(EXTRA_APPWIDGET_ID, widgetIds)
            enqueueWork(context, AppWidgetJobIntentService::class.java, 1, intent)
        }

        fun handleIntent(context: Context, intent: Intent) {
            val appWidgetIds = intent.getIntArrayExtra(EXTRA_APPWIDGET_ID) ?: intArrayOf()

            if (appWidgetIds.isNotEmpty()) {
                TvWidget.updateWidget(context, appWidgetIds)
            }
        }
    }


}