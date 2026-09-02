package com.seismoalert.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.seismoalert.App
import com.seismoalert.platform.AndroidContext

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // Platform context'i ayarla
        AndroidContext.appContext = applicationContext

        setContent {
            App()
        }
    }
}
