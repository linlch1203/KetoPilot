package com.example.metabolicapp

import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
	private val channelName = "com.example.metabolicapp/share"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"shareToInstagram" -> shareToPackage("com.instagram.android", call, result)
					"shareToFacebook" -> shareToPackage("com.facebook.katana", call, result)
					else -> result.notImplemented()
				}
			}
	}

	private fun shareToPackage(
		packageName: String,
		call: MethodCall,
		result: MethodChannel.Result
	) {
		val imagePath = call.argument<String>("imagePath")
		val text = call.argument<String>("text") ?: ""

		if (imagePath.isNullOrBlank()) {
			result.error("NO_PATH", "imagePath is required", null)
			return
		}

		val file = File(imagePath)
		if (!file.exists()) {
			result.error("FILE_MISSING", "Image file not found", null)
			return
		}

		// Check if target app is installed
		val pm = applicationContext.packageManager
		try {
			pm.getPackageInfo(packageName, 0)
		} catch (e: PackageManager.NameNotFoundException) {
			result.error("NOT_INSTALLED", "Target app not installed", null)
			return
		}

		val authority = "${applicationContext.packageName}.fileprovider"
		val uri = FileProvider.getUriForFile(this, authority, file)

		val intent = Intent(Intent.ACTION_SEND).apply {
			type = "image/png"
			putExtra(Intent.EXTRA_STREAM, uri)
			if (text.isNotEmpty()) {
				putExtra(Intent.EXTRA_TEXT, text)
			}
			setPackage(packageName)
			addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
		}

		try {
			// Launch directly into the target app's share flow (no chooser)
			startActivity(intent)
			result.success(true)
		} catch (e: Exception) {
			result.error("INTENT_FAILED", e.message, null)
		}
	}
}
