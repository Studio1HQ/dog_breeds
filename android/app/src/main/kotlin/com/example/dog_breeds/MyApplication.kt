package com.example.dog_breeds

import android.app.Application
import sh.measure.android.Measure
import sh.measure.android.config.MeasureConfig


class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        Measure.init(this, MeasureConfig())
    }
}