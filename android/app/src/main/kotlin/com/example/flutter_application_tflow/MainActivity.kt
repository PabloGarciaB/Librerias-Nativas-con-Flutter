package com.example.flutter_application_tflow
import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Bundle
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val channel = "com.example.app/native"
    private val CAMERA_PERMISSION_REQUEST_CODE = 100
    private val CAMERA_REQUEST_CODE = 1
    private var flutterEngine: FlutterEngine? = null
    private var pendingResult: MethodChannel.Result? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.flutterEngine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if(call.method == "takePhoto"){
                pendingResult = result
                takePhoto()
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
    
    private fun takePhoto() {
        // Check if camera permission is granted
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) 
            != PackageManager.PERMISSION_GRANTED) {
            // Request permission
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CAMERA),
                CAMERA_PERMISSION_REQUEST_CODE
            )
        } else {
            // Permission already granted, start camera
            startCameraIntent()
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, start camera
                startCameraIntent()
            } else {
                // Permission denied
                pendingResult?.error("PERMISSION_DENIED", "Camera permission was denied", null)
                pendingResult = null
            }
        }
    }
    
    private fun startCameraIntent() {
        val takePhoto = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if(takePhoto.resolveActivity(packageManager) != null){
            startActivityForResult(takePhoto, CAMERA_REQUEST_CODE)
        } else {
            pendingResult?.error("UNAVAILABLE", "No activity found to handle image capture", null)
            pendingResult = null
        }
    }

    private fun saveBitmapToFile(bitmap: Bitmap): String? {
        return try {
            // Get the cache directory
            val cacheDir = getExternalFilesDir(null) ?: cacheDir
            val imageFile = File(cacheDir, "captured_image_${System.currentTimeMillis()}.jpg")
            
            // Compress and save the bitmap
            val outputStream = FileOutputStream(imageFile)
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, outputStream)
            outputStream.flush()
            outputStream.close()
            
            // Return the absolute path
            imageFile.absolutePath
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == CAMERA_REQUEST_CODE) {
            if (pendingResult == null) {
                // Result was already handled, ignore
                return
            }
            
            if (resultCode == Activity.RESULT_OK && data != null) {
                val imageBitmap = data.extras?.get("data") as? Bitmap
                if (imageBitmap != null) {
                    val imagePath = saveBitmapToFile(imageBitmap)
                    if(imagePath != null){
                        pendingResult?.success(imagePath)
                    }
                } else {
                    pendingResult?.error("UNAVAILABLE", "Failed to capture image", null)
                }
            } else {
                pendingResult?.error("CANCELLED", "Photo capture was cancelled", null)
            }
            
            pendingResult = null
        }
    }
}