package com.jkjk.my_show.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.jkjk.my_show.MainActivity
import com.jkjk.my_show.MyApp
import com.jkjk.my_show.R
import com.jkjk.my_show.model.TvDetails
import io.flutter.plugin.common.MethodChannel

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class TvWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager?, appWidgetIds: IntArray) {
        getTv(context)
        AppWidgetJobIntentService.enqueueWidget(context, appWidgetIds)
    }

    companion object {
        const val TV_WIDGET_START_APP_REQUEST_CODE = 12

        fun updateWidget(context: Context, ids: IntArray){
            val startAppIntent = Intent(context, MainActivity::class.java)

            val startAppPendingIntent = PendingIntent.getActivity(context,
                    TV_WIDGET_START_APP_REQUEST_CODE, startAppIntent, PendingIntent.FLAG_UPDATE_CURRENT)

            val view = RemoteViews(context.packageName, R.layout.tv_widget)
            view.setOnClickPendingIntent(R.id.app_bar, startAppPendingIntent)

            val widgetAdapterIntent = Intent(context, TvWidgetRemoteFactory.TaskListWidgetRemoteService::class.java)

            view.setRemoteAdapter(R.id.container, widgetAdapterIntent)

            val addIntent = Intent(context.getString(R.string.action_add_progress))
            val addPendingIntent = PendingIntent.getBroadcast(context,
                    AppWidgetJobIntentService.REQUEST_CODE_PROGRESS_ADD_JOB, addIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            view.setPendingIntentTemplate(R.id.btnAdd, addPendingIntent)

            val reduceIntent = Intent(context.getString(R.string.action_reduce_progress))
            val reducePendingIntent = PendingIntent.getBroadcast(context,
                    AppWidgetJobIntentService.REQUEST_CODE_PROGRESS_REDUCE_JOB, reduceIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            view.setPendingIntentTemplate(R.id.btnReduce, reducePendingIntent)

            val widgetMan = AppWidgetManager.getInstance(context)
            for (id in ids) {
                widgetMan.updateAppWidget(id, view)
            }
        }

        fun getTv(context: Context){
            Handler(Looper.getMainLooper()).post{
                MethodChannel((context.applicationContext as MyApp).flutterEngine.dartExecutor.binaryMessenger, MyApp.CHANNEL_TO_FLUTTER)
                        .invokeMethod("getSavedTv", null, object : MethodChannel.Result{
                            override fun notImplemented() {
                                Log.e("getTv Fail:","notImplemented")
                            }

                            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                                Log.e("getTv Fail:", errorMessage ?: "not msg")
                            }

                            override fun success(result: Any?) {
                                Log.d("ress", result?.toString() ?: "")
                                if (result is String) {
                                    try {
                                        val tvs = Gson().fromJson<List<TvDetails>>(result, object : TypeToken<List<TvDetails>>(){}.type)
                                        if (tvs?.isNotEmpty() == true) {
                                            (context.applicationContext as MyApp).data.clear()
                                            (context.applicationContext as MyApp).data.addAll(tvs)


                                        }
                                    } catch (e: Exception) {
                                        e.printStackTrace()
                                    }
                                }
                            }
                        })
            }
        }
    }

}