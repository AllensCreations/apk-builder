package com.allenscreations.autorelease

import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val webView = WebView(this)
        webView.settings.javaScriptEnabled = true
        webView.webViewClient = WebViewClient()
        // Loads index.html directly from root assets
        webView.loadUrl("file:///android_asset/index.html")
        setContentView(webView)
    }
}
