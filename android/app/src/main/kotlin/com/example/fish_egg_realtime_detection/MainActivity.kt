import android.graphics.Rect
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.core.Mat
import org.opencv.core.Rect
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import ai.onnxruntime.OnnxRuntime
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession

class MainActivity : FlutterActivity() {
    private val CHANNEL = "onnx_runtime"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "runInference" -> {
                    val planes = call.argument<List<ByteArray>>("planes")!!
                    val width = call.argument<Int>("width")!!
                    val height = call.argument<Int>("height")!!
                    val boxes = runModel(planes, width, height)
                    result.success(boxes.map { box -> box.toFloatArray() })
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun runModel(planes: List<ByteArray>, width: Int, height: Int): List<Rect> {
        // Implement model loading and inference here
        val environment = OrtEnvironment.getEnvironment()
        val session = environment.createSession("assets/model.onnx")
        val inputTensor = OrtTensor.createTensor(environment, planes)
        val results = session.run(Collections.singletonMap("input", inputTensor))
        // Process results and convert to bounding boxes
        // Return list of Rects
    }
}
