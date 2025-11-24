package com.example.flutter_application_tflow
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity : FlutterActivity() {
    private val channel = "com.example.app/native"
    private var flutterEngine: FlutterEngine? = null
    private var pendingResult: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.flutterEngine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if(call.method == "takePhoto"){
                pendingResult = result
                takePhoto(result)
            } else if(call.method == "getBatteryLevel"){
                var batteryLevel = getBatteryLevel()
                if(batteryLevel != -1){
                    result.success("Battery level: $batteryLevel")
                } else {
                    result.error("UNAVAILABLE", "Couldn't obtain battery level", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as android.os.BatteryManager
        return batteryManager.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }
    private fun takePhoto(result: MethodChannel.Result) {
        val takePhoto = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if(takePhoto.resolveActivity(packageManager) != null){
            startActivityForResult(takePhoto, 1)
        } else {
            result.error("UNAVAILABLE", "No activity found to handle image capture", null)
        }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(requestCode == 1 && resultCode == Activity.RESULT_OK && data != null){
            val imageBitmap = data.extras?.get("data") as? android.graphics.Bitmap
            if (imageBitmap != null && pendingResult != null) {
                // Convert bitmap to base64 or save to file and return path
                // For now, just return success message
                pendingResult?.success("Photo captured successfully")
            } else {
                pendingResult?.error("UNAVAILABLE", "Failed to capture image", null)
            }
        } else {
            pendingResult?.error("CANCELLED", "Photo capture was cancelled", null)
        }
        pendingResult = null
    }
}