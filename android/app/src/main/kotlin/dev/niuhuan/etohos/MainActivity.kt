package dev.niuhuan.etohos

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class MainActivity: FlutterActivity() {
    private val CHANNEL = "methods"
    private var networkHistory = mutableListOf<Map<String, Any>>()
    private var lastTotalRx: Long = 0
    private var lastTotalTx: Long = 0
    private var isConnected = false
    private var runningInst = ""
    private val handler = Handler(Looper.getMainLooper())
    private var networkUpdateRunnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "data_dir" -> {
                    // 返回应用的数据目录
                    result.success(applicationContext.filesDir.absolutePath)
                }
                
                "get_system_language" -> {
                    // 获取系统语言
                    val locale = resources.configuration.locales[0]
                    val languageCode = locale.language
                    result.success(languageCode)
                }
                
                "set_app_language" -> {
                    // Android上语言切换由Flutter层控制
                    // 这里只返回成功，实际语言已经通过Flutter的国际化处理
                    result.success(true)
                }
                
                "get_app_language" -> {
                    // 返回默认值，实际语言由Flutter端管理
                    result.success("auto")
                }
                
                "prepare_vpn" -> {
                    // Android上直接返回成功
                    result.success("")
                }
                
                "connect_vpn" -> {
                    // 模拟连接VPN
                    try {
                        val args = call.arguments as? Map<*, *>
                        val argsMap = args?.get("args") as? Map<*, *>
                        val instanceId = argsMap?.get("instanceId") as? String ?: ""
                        
                        isConnected = true
                        runningInst = instanceId
                        
                        // 启动网络状态模拟
                        startNetworkMonitoring()
                        
                        result.success("")
                    } catch (e: Exception) {
                        result.error("-1", "Connection failed: ${e.message}", null)
                    }
                }
                
                "disconnect_vpn" -> {
                    // 模拟断开VPN
                    isConnected = false
                    runningInst = ""
                    stopNetworkMonitoring()
                    networkHistory.clear()
                    lastTotalRx = 0
                    lastTotalTx = 0
                    result.success("")
                }
                
                "connect_state" -> {
                    // 返回连接状态
                    val state = mapOf(
                        "isConnected" to isConnected,
                        "runningInst" to runningInst
                    )
                    result.success(state)
                }
                
                "collect_network_infos" -> {
                    // 返回空的网络信息
                    result.success(emptyList<Any>())
                }
                
                "get_network_history" -> {
                    // 返回网络历史数据
                    result.success(networkHistory)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startNetworkMonitoring() {
        // 模拟网络数据生成
        networkUpdateRunnable = object : Runnable {
            override fun run() {
                if (isConnected) {
                    // 生成模拟的网络数据
                    val currentTime = System.currentTimeMillis()
                    val rxBytes = (Math.random() * 1024 * 100).toLong() // 0-100KB/s
                    val txBytes = (Math.random() * 1024 * 50).toLong()  // 0-50KB/s
                    
                    val networkData = mapOf(
                        "timestamp" to currentTime,
                        "rxBytes" to rxBytes,
                        "txBytes" to txBytes,
                        "ip" to "192.168.1.100",
                        "hostname" to "android-device"
                    )
                    
                    networkHistory.add(networkData)
                    
                    // 保持最近20条记录
                    if (networkHistory.size > 20) {
                        networkHistory.removeAt(0)
                    }
                    
                    // 每3秒更新一次
                    handler.postDelayed(this, 3000)
                }
            }
        }
        
        // 延迟1秒后开始第一次更新
        handler.postDelayed(networkUpdateRunnable!!, 1000)
    }

    private fun stopNetworkMonitoring() {
        networkUpdateRunnable?.let {
            handler.removeCallbacks(it)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopNetworkMonitoring()
    }
}
