package com.jkjk.my_show.widget

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.bumptech.glide.Glide
import com.jkjk.my_show.MyApp
import com.jkjk.my_show.R
import java.lang.Exception


class TvWidgetRemoteFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {

    override fun onCreate() {
    }

    override fun onDataSetChanged() {
        TvWidget.getTv(context)
    }

    override fun onDestroy() {
    }

    override fun getCount(): Int {
        return (context.applicationContext as MyApp).data.size
    }

    override fun getViewAt(i: Int): RemoteViews {
        if (i >= (context.applicationContext as MyApp).data.size) {
            val remoteViews = RemoteViews(context.packageName, R.layout.tv_widget_loading)
            remoteViews.setTextViewText(R.id.text, context.getString(R.string.error_text))
            return remoteViews
        }

        val tv = (context.applicationContext as MyApp).data[i]
        val remoteViews = RemoteViews(context.packageName, R.layout.tv_widget_item)
        remoteViews.setTextViewText(R.id.txtName, tv.name ?: tv.originalName)
        val progress = tv.progress
        if (progress != null) {
            remoteViews.setTextViewText(R.id.txtProgress, "S${progress.seasonNo} E${progress.episodeNo} (${progress.totalEpisode})")
        }

        remoteViews.setImageViewResource(R.id.imgPoster, R.drawable.poster_placeholder)


        if (tv.posterPath?.isNotBlank() == true) {

            val builder = Glide.with(context)
                    .asBitmap()
                    .load(LOW_IMAGE_PREFIX + tv.posterPath)
                    .centerCrop()
            val futureTarget = builder.into(120, 180)
            try {
                remoteViews.setImageViewBitmap(R.id.imgPoster, futureTarget.get() as Bitmap)
            } catch (e: Exception) {
                e.printStackTrace()
            }


//            Glide.with(context).asBitmap().load(LOW_IMAGE_PREFIX + tv.posterPath).into(object : SimpleTarget<Bitmap>() {
//                override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
//                    remoteViews.setImageViewBitmap(R.id.imgPoster, resource)
//                }
//            })
        }

        val addIntent = Intent()
        addIntent.putExtra(EXTRA_TV_ID, tv.id)
        remoteViews.setOnClickFillInIntent(R.id.btnAdd, addIntent)

        val reduceIntent = Intent()
        reduceIntent.putExtra(EXTRA_TV_ID, tv.id)
        remoteViews.setOnClickFillInIntent(R.id.btnReduce, reduceIntent)

        return remoteViews
    }

    override fun getLoadingView(): RemoteViews {
        return RemoteViews(context.packageName, R.layout.tv_widget_loading)
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(i: Int): Long {
        return (context.applicationContext as MyApp).data[i].id?.toLong() ?: 0
    }

    override fun hasStableIds(): Boolean {
        return true
    }

    companion object {
        private const val LOW_IMAGE_PREFIX = "https://image.tmdb.org/t/p/w185";
        const val EXTRA_TV_ID = "tv_id"
    }

    class TaskListWidgetRemoteService : RemoteViewsService() {
        override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
            return TvWidgetRemoteFactory(applicationContext)
        }
    }
}
