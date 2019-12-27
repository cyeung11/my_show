package com.jkjk.my_show.model

import com.google.gson.annotations.SerializedName

data class TvDetails(
        var id: Int?,
        var name: String?,
        @SerializedName("original_name")
        var originalName: String?,
        @SerializedName("poster_path")
        var posterPath: String?,
        var progress: WatchProgress?
)