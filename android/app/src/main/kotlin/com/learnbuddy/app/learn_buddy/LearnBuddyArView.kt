package com.learnbuddy.app.learn_buddy

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Typeface
import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.GLUtils
import android.opengl.Matrix
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Surface
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import com.google.ar.core.ArCoreApk
import com.google.ar.core.AugmentedImage
import com.google.ar.core.AugmentedImageDatabase
import com.google.ar.core.Config
import com.google.ar.core.Coordinates2d
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlin.math.sin

class LearnBuddyArViewFactory(
    private val activity: Activity,
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return LearnBuddyArView(activity, context, messenger)
    }
}

private data class BlockPalette(val r: Float, val g: Float, val b: Float, val hexBg: Int)

private data class ArBlock3D(
    val id: Long,
    var label: String,
    var palette: BlockPalette,
    var x: Float,
    var y: Float,
    var z: Float,
    var targetX: Float,
    var targetY: Float,
    var targetZ: Float,
    var sx: Float = 0.064f,
    var sy: Float = 0.024f,
    var sz: Float = 0.050f,
    var alpha: Float = 0.2f,
    var targetAlpha: Float = 1.0f,
    var removing: Boolean = false,
    var textureId: Int = 0,
    var needsTexture: Boolean = true
)

class LearnBuddyArView(
    private val activity: Activity,
    private val context: Context,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler, GLSurfaceView.Renderer {

    private val channel = MethodChannel(messenger, "learn_buddy/ar_channel")
    private val mainHandler = Handler(Looper.getMainLooper())
    private val container = FrameLayout(context)
    private val glSurfaceView = GLSurfaceView(context)

    private var arSession: Session? = null
    private var cameraTextureId = -1
    private var viewportWidth = 1
    private var viewportHeight = 1
    private var viewportChanged = false
    private var hasTransformedCoords = false
    private var isDisposed = false
    private var isResumed = false

    // OpenGL camera background renderer
    private var quadProgram = 0
    private var quadPositionAttr = 0
    private var quadTexCoordAttr = 0
    private lateinit var quadVertices: FloatBuffer
    private lateinit var quadTexCoords: FloatBuffer
    private lateinit var transformedTexCoords: FloatBuffer

    // OpenGL 3D Cube renderer
    private var boxProgram = 0
    private var boxPosAttr = 0
    private var boxTexAttr = 0
    private var boxMvpUniform = 0
    private var boxColorUniform = 0
    private var boxUseTexUniform = 0
    private var boxTexUniform = 0
    private lateinit var cubeFaceBuffers: List<FloatBuffer>
    private lateinit var faceTexBuffer: FloatBuffer

    // ARCore tracking & Multi-Topic 3D Scene state
    private val lock = Any()
    private val maxCapacity = 5
    private var colorCounter = 0
    private val blocks = mutableListOf<ArBlock3D>()
    private var highlightBlockId: Long? = null
    private var shakeFrames = 0
    private var frameTick = 0
    private var encapValue = "100"
    private var loopIndex = 0
    private var seededType: String? = null

    private var markerDetected = false
    private var activeObjectType: String? = null
    private var lastSentStatus = ""
    private var dbErrorMessage: String? = null

    private val anchorMatrix = FloatArray(16)
    private val projMatrix = FloatArray(16)
    private val viewMatrix = FloatArray(16)
    private val vpMatrix = FloatArray(16)
    private val modelMatrix = FloatArray(16)
    private val mvpMatrix = FloatArray(16)

    private val markerRegistry = listOf(
        "stack" to "marker_stack.png",
        "queue" to "marker_queue.png",
        "linked_list" to "marker_linked_list.png",
        "java_class" to "marker_java_oop.png",
        "java_encap" to "marker_java_encap.png",
        "java_inherit" to "marker_java_inherit.png",
        "py_list_tuple" to "marker_py_list_tuple.png",
        "py_dict" to "marker_py_dict.png",
        "py_loop" to "marker_py_loop.png"
    )

    private val palettes = listOf(
        BlockPalette(0.39f, 0.40f, 0.95f, Color.rgb(79, 70, 229)),   // Indigo
        BlockPalette(0.06f, 0.73f, 0.51f, Color.rgb(5, 150, 105)),   // Emerald
        BlockPalette(0.96f, 0.62f, 0.04f, Color.rgb(217, 119, 6)),   // Amber
        BlockPalette(0.93f, 0.28f, 0.60f, Color.rgb(219, 39, 119)),  // Pink
        BlockPalette(0.05f, 0.65f, 0.91f, Color.rgb(2, 132, 199)),   // Sky
        BlockPalette(0.49f, 0.23f, 0.93f, Color.rgb(124, 58, 237))   // Violet
    )

    init {
        channel.setMethodCallHandler(this)

        glSurfaceView.preserveEGLContextOnPause = true
        glSurfaceView.setEGLContextClientVersion(2)
        glSurfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        glSurfaceView.setRenderer(this)
        glSurfaceView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY

        container.addView(
            glSurfaceView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        initSessionIfReady()
    }

    private fun initSessionIfReady() {
        try {
            val availability = ArCoreApk.getInstance().checkAvailability(activity)
            if (!availability.isSupported) {
                emitMarkerStatus(false, null, "ARCore: ${availability.name}")
                return
            }
            if (arSession == null) {
                val session = Session(activity)
                val config = Config(session)
                config.focusMode = Config.FocusMode.AUTO
                config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                config.planeFindingMode = Config.PlaneFindingMode.DISABLED

                try {
                    val db = AugmentedImageDatabase(session)
                    var loadedCount = 0
                    for ((typeKey, assetFile) in markerRegistry) {
                        context.assets.open(assetFile).use { stream ->
                            val bitmap = BitmapFactory.decodeStream(stream)
                            if (bitmap != null) {
                                db.addImage(typeKey, bitmap, 0.12f)
                                bitmap.recycle()
                                loadedCount++
                            }
                        }
                    }
                    config.augmentedImageDatabase = db
                    dbErrorMessage = null
                    Log.i("LearnBuddyArView", "Loaded $loadedCount AR markers into AugmentedImageDatabase")
                } catch (e: Exception) {
                    dbErrorMessage = "DB Error: ${e.javaClass.simpleName}"
                    Log.e("LearnBuddyArView", "Failed to load AR markers", e)
                }

                session.configure(config)
                arSession = session
            }
            resumeSession()
        } catch (e: Exception) {
            dbErrorMessage = "Session Error: ${e.javaClass.simpleName}"
            Log.e("LearnBuddyArView", "initSessionIfReady failed", e)
            emitMarkerStatus(false, null, dbErrorMessage!!)
        }
    }

    private fun emitMarkerStatus(detected: Boolean, objectType: String?, status: String) {
        if (detected == markerDetected && objectType == activeObjectType && status == lastSentStatus) return
        markerDetected = detected
        activeObjectType = objectType
        lastSentStatus = status
        val activeLabels = synchronized(lock) { blocks.filter { !it.removing }.map { it.label } }
        mainHandler.post {
            channel.invokeMethod(
                "onMarkerStatus",
                mapOf(
                    "detected" to detected,
                    "objectType" to objectType,
                    "status" to status,
                    "items" to activeLabels
                )
            )
        }
    }

    private fun seedInitialSceneFor(type: String) {
        clearAllBlocksLocked()
        colorCounter = 0
        highlightBlockId = null
        encapValue = "100"
        loopIndex = 0
        seededType = type

        when (type) {
            "stack" -> {
                addBlockLocked("Data 1", 0f, 0.10f, 0f, 0f, 0.020f, 0f)
            }
            "queue" -> {
                addBlockLocked("Antre 1", 0.08f, 0.020f, 0f, -0.054f, 0.020f, 0f, sx = 0.032f, sz = 0.036f)
                addBlockLocked("Antre 2", 0.09f, 0.020f, 0f, -0.018f, 0.020f, 0f, sx = 0.032f, sz = 0.036f)
            }
            "linked_list" -> {
                addBlockLocked("Head:10", 0f, 0.06f, 0f, -0.044f, 0.022f, 0f, sx = 0.036f, sz = 0.034f)
                addBlockLocked("Node:20", 0f, 0.06f, 0f, 0.004f, 0.022f, 0f, sx = 0.036f, sz = 0.034f)
            }
            "java_class" -> {
                addBlockLocked("Obj 1", 0f, 0.08f, 0.022f, -0.036f, 0.020f, 0.022f, sx = 0.036f, sz = 0.032f)
            }
            "java_encap" -> {
                addBlockLocked("private:100", 0f, 0.05f, 0f, 0f, 0.028f, 0f, sx = 0.060f, sy = 0.028f, sz = 0.046f)
            }
            "java_inherit" -> {
                addBlockLocked("Kucing", 0f, 0.05f, 0.01f, -0.038f, 0.020f, 0.01f, sx = 0.040f, sz = 0.034f)
                addBlockLocked("Burung", 0f, 0.05f, 0.01f, 0.038f, 0.020f, 0.01f, sx = 0.040f, sz = 0.034f)
            }
            "py_list_tuple" -> {
                addBlockLocked("List[0]:A", -0.042f, 0.08f, 0f, -0.042f, 0.020f, 0f, sx = 0.046f, sz = 0.036f)
            }
            "py_dict" -> {
                addBlockLocked("nama:Budi", 0f, 0.08f, 0f, -0.038f, 0.022f, 0f, sx = 0.054f, sz = 0.036f)
            }
            "py_loop" -> {
                for (i in 0..4) {
                    val x = -0.064f + i * 0.032f
                    addBlockLocked("i=$i", x, 0.05f, 0f, x, 0.020f, 0f, sx = 0.026f, sy = 0.022f, sz = 0.028f)
                }
                highlightBlockId = blocks.firstOrNull()?.id
            }
        }
    }

    private fun clearAllBlocksLocked() {
        for (b in blocks) {
            b.removing = true
            b.targetAlpha = 0f
        }
    }

    private fun addBlockLocked(
        label: String,
        x: Float, y: Float, z: Float,
        tx: Float, ty: Float, tz: Float,
        sx: Float = 0.064f, sy: Float = 0.024f, sz: Float = 0.050f
    ): ArBlock3D {
        val pal = palettes[colorCounter % palettes.size]
        colorCounter++
        val block = ArBlock3D(
            id = System.nanoTime() + colorCounter,
            label = label,
            palette = pal,
            x = x, y = y, z = z,
            targetX = tx, targetY = ty, targetZ = tz,
            sx = sx, sy = sy, sz = sz
        )
        blocks.add(block)
        return block
    }

    private fun relayoutActiveLocked(type: String) {
        val active = blocks.filter { !it.removing }
        when (type) {
            "stack" -> active.forEachIndexed { idx, b ->
                b.targetX = 0f; b.targetY = 0.020f + idx * 0.028f; b.targetZ = 0f
            }
            "queue" -> active.forEachIndexed { idx, b ->
                b.targetX = -0.072f + idx * 0.036f; b.targetY = 0.020f; b.targetZ = 0f
            }
            "linked_list" -> active.forEachIndexed { idx, b ->
                b.targetX = -0.066f + idx * 0.044f; b.targetY = 0.022f; b.targetZ = 0f
            }
            "java_class" -> active.forEachIndexed { idx, b ->
                b.targetX = -0.054f + idx * 0.038f; b.targetY = 0.020f; b.targetZ = 0.022f
            }
            "java_inherit" -> active.forEachIndexed { idx, b ->
                val spacing = 0.044f
                val startX = -((active.size - 1) * spacing) / 2f
                b.targetX = startX + idx * spacing; b.targetY = 0.020f; b.targetZ = 0.01f
            }
            "py_list_tuple" -> active.forEachIndexed { idx, b ->
                b.targetX = -0.042f; b.targetY = 0.020f + idx * 0.026f; b.targetZ = 0f
            }
            "py_dict" -> active.forEachIndexed { idx, b ->
                b.targetX = 0f; b.targetY = 0.020f + idx * 0.028f; b.targetZ = 0f
            }
        }
    }

    private fun resumeSession() {
        if (isDisposed || isResumed) return
        val session = arSession ?: return
        try {
            session.resume()
            glSurfaceView.onResume()
            isResumed = true
        } catch (_: CameraNotAvailableException) {
            arSession = null
        } catch (_: Exception) {
        }
    }

    private fun pauseSession() {
        if (!isResumed) return
        try {
            glSurfaceView.onPause()
            arSession?.pause()
        } catch (_: Exception) {
        } finally {
            isResumed = false
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        isDisposed = true
        channel.setMethodCallHandler(null)
        pauseSession()
        try {
            arSession?.close()
        } catch (_: Exception) {
        }
        arSession = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "resumeAr" -> {
                if (arSession == null) initSessionIfReady() else resumeSession()
                result.success(arSession != null)
            }
            "pauseAr" -> {
                pauseSession()
                result.success(true)
            }
            "action" -> {
                val action = call.argument<String>("action") ?: ""
                val label = call.argument<String>("label")?.trim().orEmpty()
                val type = activeObjectType ?: "stack"
                result.success(handleTopicAction(type, action, label))
            }
            "reset" -> {
                val type = activeObjectType ?: "stack"
                synchronized(lock) {
                    seedInitialSceneFor(type)
                }
                result.success(buildStateMap("reset", null, "Scene 3D direset."))
            }
            else -> result.notImplemented()
        }
    }

    private fun handleTopicAction(type: String, action: String, label: String): Map<String, Any?> {
        synchronized(lock) {
            val active = blocks.filter { !it.removing }

            return when (type) {
                "stack" -> when (action) {
                    "push" -> {
                        if (active.size >= maxCapacity) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "Stack Overflow! Kapasitas maksimal 5.")
                        } else {
                            val text = label.ifEmpty { "Data ${active.size + 1}" }
                            val ty = 0.020f + active.size * 0.028f
                            addBlockLocked(text, 0f, ty + 0.10f, 0f, 0f, ty, 0f)
                            highlightBlockId = null
                            buildStateMap("ok", text, "PUSH \"$text\" ditaruh di puncak TOP (LIFO).")
                        }
                    }
                    "pop" -> {
                        if (active.isEmpty()) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Stack Underflow! Tumpukan kosong.")
                        } else {
                            val top = active.last()
                            top.removing = true; top.targetY = top.y + 0.11f; top.targetAlpha = 0f
                            highlightBlockId = null
                            buildStateMap("ok", top.label, "POP \"${top.label}\" keluar dari TOP.")
                        }
                    }
                    "peek" -> {
                        if (active.isEmpty()) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Stack kosong, tidak ada elemen TOP.")
                        } else {
                            highlightBlockId = active.last().id
                            buildStateMap("peek", active.last().label, "PEEK: Elemen TOP adalah \"${active.last().label}\".")
                        }
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "queue" -> when (action) {
                    "enqueue" -> {
                        if (active.size >= maxCapacity) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "Queue Overflow! Antrean penuh (5/5).")
                        } else {
                            val text = label.ifEmpty { "Antre ${active.size + 1}" }
                            addBlockLocked(text, 0.11f, 0.020f, 0f, 0f, 0.020f, 0f, sx = 0.032f, sz = 0.036f)
                            relayoutActiveLocked("queue")
                            highlightBlockId = null
                            buildStateMap("ok", text, "ENQUEUE \"$text\" masuk di ujung REAR.")
                        }
                    }
                    "dequeue" -> {
                        if (active.isEmpty()) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Queue Underflow! Antrean kosong.")
                        } else {
                            val front = active.first()
                            front.removing = true; front.targetX = front.x - 0.08f; front.targetAlpha = 0f
                            relayoutActiveLocked("queue")
                            highlightBlockId = null
                            buildStateMap("ok", front.label, "DEQUEUE \"${front.label}\" keluar dari FRONT (FIFO).")
                        }
                    }
                    "peek" -> {
                        if (active.isEmpty()) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Antrean kosong.")
                        } else {
                            highlightBlockId = active.first().id
                            buildStateMap("peek", active.first().label, "PEEK: Elemen terdepan (FRONT) adalah \"${active.first().label}\".")
                        }
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "linked_list" -> when (action) {
                    "insert_head" -> {
                        if (active.size >= 4) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "Maksimal 4 Node agar pointer tetap jelas.")
                        } else {
                            val text = label.ifEmpty { "N:${(active.size + 1) * 10}" }
                            val nb = addBlockLocked(text, -0.09f, 0.08f, 0f, 0f, 0.022f, 0f, sx = 0.036f, sz = 0.034f)
                            blocks.remove(nb)
                            blocks.add(0, nb)
                            relayoutActiveLocked("linked_list")
                            highlightBlockId = nb.id
                            buildStateMap("ok", text, "INSERT HEAD \"$text\" menjadi pointer HEAD baru.")
                        }
                    }
                    "insert_tail" -> {
                        if (active.size >= 4) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "Maksimal 4 Node.")
                        } else {
                            val text = label.ifEmpty { "N:${(active.size + 1) * 10}" }
                            val nb = addBlockLocked(text, 0.09f, 0.08f, 0f, 0f, 0.022f, 0f, sx = 0.036f, sz = 0.034f)
                            relayoutActiveLocked("linked_list")
                            highlightBlockId = nb.id
                            buildStateMap("ok", text, "INSERT TAIL \"$text\" disambung ke pointer next terakhir.")
                        }
                    }
                    "delete_head" -> {
                        if (active.isEmpty()) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Linked List kosong.")
                        } else {
                            val head = active.first()
                            head.removing = true; head.targetY = 0.10f; head.targetAlpha = 0f
                            relayoutActiveLocked("linked_list")
                            highlightBlockId = null
                            buildStateMap("ok", head.label, "DELETE HEAD \"${head.label}\" — HEAD pindah ke node berikutnya.")
                        }
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "java_class" -> when (action) {
                    "new_object" -> {
                        if (active.size >= 4) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "Maksimal 4 instance objek dari Class.")
                        } else {
                            val text = label.ifEmpty { "Obj ${active.size + 1}" }
                            val nb = addBlockLocked(text, 0f, 0.08f, -0.03f, 0f, 0.020f, 0.022f, sx = 0.036f, sz = 0.032f)
                            relayoutActiveLocked("java_class")
                            highlightBlockId = nb.id
                            buildStateMap("ok", text, "new Mobil() menciptakan instance \"$text\" terpisah di memori.")
                        }
                    }
                    "mutate_obj" -> {
                        if (active.isEmpty()) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Belum ada objek. Tekan NEW OBJECT dulu.")
                        } else {
                            val first = active.first()
                            val newLbl = label.ifEmpty { "${first.label}*" }
                            first.label = newLbl
                            first.needsTexture = true
                            highlightBlockId = first.id
                            buildStateMap("ok", newLbl, "Mengubah atribut objek pertama tidak mengubah objek lain!")
                        }
                    }
                    "inspect" -> {
                        buildStateMap("peek", null, "1 Blueprint Class dapat mencetak banyak Objek independen.")
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "java_encap" -> when (action) {
                    "setter" -> {
                        val newVal = label.ifEmpty { "250" }
                        encapValue = newVal
                        active.firstOrNull()?.let {
                            it.label = "private:$newVal"
                            it.needsTexture = true
                            highlightBlockId = it.id
                        }
                        buildStateMap("ok", newVal, "setSaldo($newVal) lolos validasi dan memperbarui data private.")
                    }
                    "getter" -> {
                        active.firstOrNull()?.let { highlightBlockId = it.id }
                        buildStateMap("peek", encapValue, "getSaldo() mengembalikan nilai terenkapsulasi: $encapValue.")
                    }
                    "direct_hack" -> {
                        shakeFrames = 22
                        highlightBlockId = null
                        buildStateMap("overflow", null, "DITOLAK! Atribut private tidak bisa diubah langsung dari luar class.")
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "java_inherit" -> when (action) {
                    "add_child" -> {
                        if (active.size >= 4) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "Maksimal 4 Subclass pada visualisasi 3D.")
                        } else {
                            val text = label.ifEmpty { "Anak ${active.size + 1}" }
                            val nb = addBlockLocked(text, 0f, 0.07f, 0.01f, 0f, 0.020f, 0.01f, sx = 0.040f, sz = 0.034f)
                            relayoutActiveLocked("java_inherit")
                            highlightBlockId = nb.id
                            buildStateMap("ok", text, "class $text extends Hewan otomatis mewarisi method Superclass.")
                        }
                    }
                    "override_method" -> {
                        val last = active.lastOrNull()
                        if (last == null) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Tambahkan Subclass dulu.")
                        } else {
                            last.label = "@Override"
                            last.needsTexture = true
                            highlightBlockId = last.id
                            buildStateMap("ok", last.label, "Subclass meng-override method suara() tanpa mengubah Superclass.")
                        }
                    }
                    "inspect" -> {
                        buildStateMap("peek", null, "Superclass Hewan berada di atas; semua Subclass mewarisi atributnya.")
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "py_list_tuple" -> when (action) {
                    "list_append" -> {
                        if (active.size >= 4) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "List penuh (maks 4 elemen di AR).")
                        } else {
                            val text = label.ifEmpty { "Item ${active.size}" }
                            val ty = 0.020f + active.size * 0.026f
                            addBlockLocked("L[${active.size}]:$text", -0.042f, ty + 0.08f, 0f, -0.042f, ty, 0f, sx = 0.046f, sz = 0.036f)
                            highlightBlockId = null
                            buildStateMap("ok", text, "list.append(\"$text\") berhasil karena List bersifat MUTABLE.")
                        }
                    }
                    "list_pop" -> {
                        if (active.isEmpty()) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "List kosong.")
                        } else {
                            val top = active.last()
                            top.removing = true; top.targetY = top.y + 0.09f; top.targetAlpha = 0f
                            buildStateMap("ok", top.label, "list.pop() menghapus elemen terakhir dari List.")
                        }
                    }
                    "try_edit_tuple" -> {
                        shakeFrames = 22
                        buildStateMap("overflow", null, "TypeError! Tuple (kanan) bersifat IMMUTABLE — tidak bisa diubah!")
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "py_dict" -> when (action) {
                    "set_pair" -> {
                        val raw = label.ifEmpty { "k${active.size + 1}:val" }
                        val existingKey = raw.substringBefore(":")
                        val existing = active.firstOrNull { it.label.startsWith("$existingKey:") }
                        if (existing != null) {
                            existing.label = raw
                            existing.needsTexture = true
                            highlightBlockId = existing.id
                            buildStateMap("ok", raw, "Key \"$existingKey\" sudah ada → nilai lama ditimpa menjadi \"$raw\".")
                        } else if (active.size >= 4) {
                            shakeFrames = 18
                            buildStateMap("overflow", null, "Dictionary penuh (maks 4 pasang key:value).")
                        } else {
                            val ty = 0.020f + active.size * 0.028f
                            val nb = addBlockLocked(raw, 0f, ty + 0.08f, 0f, 0f, ty, 0f, sx = 0.068f, sz = 0.038f)
                            highlightBlockId = nb.id
                            buildStateMap("ok", raw, "Menambahkan pasangan unik \"$raw\" ke Dictionary.")
                        }
                    }
                    "lookup" -> {
                        val target = active.lastOrNull()
                        if (target == null) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Dictionary kosong.")
                        } else {
                            highlightBlockId = target.id
                            buildStateMap("peek", target.label, "Lookup O(1) langsung lewat key → \"${target.label}\".")
                        }
                    }
                    "del_pair" -> {
                        val target = active.lastOrNull()
                        if (target == null) {
                            shakeFrames = 18
                            buildStateMap("underflow", null, "Dictionary kosong.")
                        } else {
                            target.removing = true; target.targetY = target.y + 0.09f; target.targetAlpha = 0f
                            highlightBlockId = null
                            buildStateMap("ok", target.label, "del dict[\"${target.label.substringBefore(":")}\"] menghapus pasangan.")
                        }
                    }
                    else -> buildStateMap("ok", null, "")
                }

                "py_loop" -> when (action) {
                    "next_iter" -> {
                        if (active.isNotEmpty()) {
                            loopIndex = (loopIndex + 1) % active.size
                            val current = active[loopIndex]
                            highlightBlockId = current.id
                            buildStateMap("peek", current.label, "Iterasi for i in range(5) aktif pada ${current.label} (berhenti sebelum 5).")
                        } else {
                            buildStateMap("ok", null, "")
                        }
                    }
                    "call_func" -> {
                        val current = active.getOrNull(loopIndex)
                        highlightBlockId = current?.id
                        buildStateMap("ok", "return ${loopIndex * 2}", "def hitung(i=$loopIndex) → return ${loopIndex * 2} (nilai dikembalikan ke pemanggil).")
                    }
                    else -> buildStateMap("ok", null, "")
                }

                else -> buildStateMap("ok", null, "")
            }
        }
    }

    private fun buildStateMap(event: String, affectedItem: String?, message: String): Map<String, Any?> {
        val activeLabels = blocks.filter { !it.removing }.map { it.label }
        return mapOf(
            "items" to activeLabels,
            "capacity" to maxCapacity,
            "event" to event,
            "affectedItem" to affectedItem,
            "message" to message,
            "objectType" to activeObjectType
        )
    }

    // --- OpenGL ES 2.0 Setup ---
    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0.06f, 0.09f, 0.16f, 1.0f)
        setupCameraBackgroundRenderer()
        setup3DBoxRenderer()
    }

    private fun setupCameraBackgroundRenderer() {
        val textures = IntArray(1)
        GLES20.glGenTextures(1, textures, 0)
        cameraTextureId = textures[0]
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, cameraTextureId)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)

        val coords = floatArrayOf(-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f)
        val tex = floatArrayOf(0f, 1f, 1f, 1f, 0f, 0f, 1f, 0f)
        quadVertices = toFloatBuffer(coords)
        quadTexCoords = toFloatBuffer(tex)
        transformedTexCoords = toFloatBuffer(tex)

        val vs = loadShader(GLES20.GL_VERTEX_SHADER, """
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() { gl_Position = a_Position; v_TexCoord = a_TexCoord; }
        """.trimIndent())
        val fs = loadShader(GLES20.GL_FRAGMENT_SHADER, """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            varying vec2 v_TexCoord;
            uniform samplerExternalOES s_Texture;
            void main() { gl_FragColor = texture2D(s_Texture, v_TexCoord); }
        """.trimIndent())
        quadProgram = GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, vs); GLES20.glAttachShader(it, fs); GLES20.glLinkProgram(it)
        }
        quadPositionAttr = GLES20.glGetAttribLocation(quadProgram, "a_Position")
        quadTexCoordAttr = GLES20.glGetAttribLocation(quadProgram, "a_TexCoord")
    }

    private fun setup3DBoxRenderer() {
        val vs = loadShader(GLES20.GL_VERTEX_SHADER, """
            uniform mat4 u_MvpMatrix;
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() { gl_Position = u_MvpMatrix * a_Position; v_TexCoord = a_TexCoord; }
        """.trimIndent())
        val fs = loadShader(GLES20.GL_FRAGMENT_SHADER, """
            precision mediump float;
            uniform vec4 u_Color;
            uniform float u_UseTexture;
            uniform sampler2D u_Texture;
            varying vec2 v_TexCoord;
            void main() {
                if (u_UseTexture > 0.5) {
                    vec4 tex = texture2D(u_Texture, v_TexCoord);
                    gl_FragColor = vec4(tex.rgb, tex.a * u_Color.a);
                } else {
                    gl_FragColor = u_Color;
                }
            }
        """.trimIndent())
        boxProgram = GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, vs); GLES20.glAttachShader(it, fs); GLES20.glLinkProgram(it)
        }
        boxPosAttr = GLES20.glGetAttribLocation(boxProgram, "a_Position")
        boxTexAttr = GLES20.glGetAttribLocation(boxProgram, "a_TexCoord")
        boxMvpUniform = GLES20.glGetUniformLocation(boxProgram, "u_MvpMatrix")
        boxColorUniform = GLES20.glGetUniformLocation(boxProgram, "u_Color")
        boxUseTexUniform = GLES20.glGetUniformLocation(boxProgram, "u_UseTexture")
        boxTexUniform = GLES20.glGetUniformLocation(boxProgram, "u_Texture")

        cubeFaceBuffers = listOf(
            toFloatBuffer(floatArrayOf(-0.5f, 0.5f, 0.5f, -0.5f, -0.5f, 0.5f, 0.5f, -0.5f, 0.5f, 0.5f, 0.5f, 0.5f)),
            toFloatBuffer(floatArrayOf(0.5f, 0.5f, -0.5f, 0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, 0.5f, -0.5f)),
            toFloatBuffer(floatArrayOf(-0.5f, 0.5f, -0.5f, -0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, -0.5f)),
            toFloatBuffer(floatArrayOf(-0.5f, -0.5f, 0.5f, -0.5f, -0.5f, -0.5f, 0.5f, -0.5f, -0.5f, 0.5f, -0.5f, 0.5f)),
            toFloatBuffer(floatArrayOf(0.5f, 0.5f, 0.5f, 0.5f, -0.5f, 0.5f, 0.5f, -0.5f, -0.5f, 0.5f, 0.5f, -0.5f)),
            toFloatBuffer(floatArrayOf(-0.5f, 0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, 0.5f, -0.5f, 0.5f, 0.5f))
        )
        faceTexBuffer = toFloatBuffer(floatArrayOf(0f, 0f, 0f, 1f, 1f, 1f, 1f, 0f))
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, height)
        viewportWidth = width
        viewportHeight = height
        viewportChanged = true
        hasTransformedCoords = false
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        val session = arSession ?: return

        if (viewportChanged) {
            val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            @Suppress("DEPRECATION")
            val rotation = wm.defaultDisplay?.rotation ?: Surface.ROTATION_0
            session.setDisplayGeometry(rotation, viewportWidth, viewportHeight)
            viewportChanged = false
            hasTransformedCoords = false
        }

        try {
            session.setCameraTextureName(cameraTextureId)
            val frame = session.update()
            frameTick++

            drawCameraBackground(frame)

            val camState = frame.camera.trackingState
            val images = session.getAllTrackables(AugmentedImage::class.java)
            var foundTracking = false
            var detectedType: String? = null
            var methodLabel = ""

            // Prefer FULL_TRACKING image when multiple markers have been seen
            for (img in images) {
                if (img.trackingState == TrackingState.TRACKING &&
                    img.trackingMethod == AugmentedImage.TrackingMethod.FULL_TRACKING
                ) {
                    img.centerPose.toMatrix(anchorMatrix, 0)
                    foundTracking = true
                    detectedType = img.name
                    methodLabel = img.trackingMethod.name
                    break
                }
            }
            if (!foundTracking) {
                for (img in images) {
                    if (img.trackingState == TrackingState.TRACKING) {
                        img.centerPose.toMatrix(anchorMatrix, 0)
                        foundTracking = true
                        detectedType = img.name
                        methodLabel = img.trackingMethod.name
                        break
                    }
                }
            }

            if (foundTracking && detectedType != null && seededType != detectedType) {
                synchronized(lock) {
                    seedInitialSceneFor(detectedType)
                }
            }

            val statusText = when {
                dbErrorMessage != null -> dbErrorMessage!!
                foundTracking -> "3D Aktif ($methodLabel)"
                camState != TrackingState.TRACKING -> "Kamera: ${frame.camera.trackingFailureReason.name}"
                else -> "Arahkan kamera ke Marker AR..."
            }
            emitMarkerStatus(foundTracking, detectedType, statusText)

            if (foundTracking && detectedType != null) {
                frame.camera.getProjectionMatrix(projMatrix, 0, 0.05f, 20.0f)
                frame.camera.getViewMatrix(viewMatrix, 0)
                Matrix.multiplyMM(vpMatrix, 0, projMatrix, 0, viewMatrix, 0)
                drawScene3D(detectedType)
            } else {
                synchronized(lock) { stepAnimationsAndCleanupGl() }
            }
        } catch (e: Exception) {
            Log.e("LearnBuddyArView", "onDrawFrame error", e)
        }
    }

    private fun drawCameraBackground(frame: com.google.ar.core.Frame) {
        if (!hasTransformedCoords || frame.hasDisplayGeometryChanged()) {
            quadVertices.position(0)
            transformedTexCoords.position(0)
            frame.transformCoordinates2d(
                Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
                quadVertices,
                Coordinates2d.TEXTURE_NORMALIZED,
                transformedTexCoords
            )
            hasTransformedCoords = true
        }
        transformedTexCoords.position(0)
        quadVertices.position(0)

        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(false)
        GLES20.glUseProgram(quadProgram)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, cameraTextureId)

        GLES20.glVertexAttribPointer(quadPositionAttr, 2, GLES20.GL_FLOAT, false, 0, quadVertices)
        GLES20.glVertexAttribPointer(quadTexCoordAttr, 2, GLES20.GL_FLOAT, false, 0, transformedTexCoords)
        GLES20.glEnableVertexAttribArray(quadPositionAttr)
        GLES20.glEnableVertexAttribArray(quadTexCoordAttr)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        GLES20.glDisableVertexAttribArray(quadPositionAttr)
        GLES20.glDisableVertexAttribArray(quadTexCoordAttr)
        GLES20.glDepthMask(true)
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
    }

    private fun stepAnimationsAndCleanupGl() {
        val iter = blocks.iterator()
        while (iter.hasNext()) {
            val b = iter.next()
            b.x += (b.targetX - b.x) * 0.18f
            b.y += (b.targetY - b.y) * 0.18f
            b.z += (b.targetZ - b.z) * 0.18f
            b.alpha += (b.targetAlpha - b.alpha) * 0.20f
            if (b.removing && b.alpha <= 0.04f) {
                if (b.textureId != 0) {
                    GLES20.glDeleteTextures(1, intArrayOf(b.textureId), 0)
                    b.textureId = 0
                }
                iter.remove()
            }
        }
    }

    private fun drawScene3D(type: String) {
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(true)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glUseProgram(boxProgram)

        val shakeX: Float
        val snapshot: List<ArBlock3D>
        val currentHighlight: Long?

        synchronized(lock) {
            if (shakeFrames > 0) {
                shakeFrames--
                shakeX = sin(shakeFrames * 1.4f) * 0.006f
            } else {
                shakeX = 0f
            }
            stepAnimationsAndCleanupGl()
            for (b in blocks) {
                if (b.needsTexture) {
                    if (b.textureId != 0) {
                        GLES20.glDeleteTextures(1, intArrayOf(b.textureId), 0)
                    }
                    b.textureId = createLabelTexture(b.label, b.palette.hexBg)
                    b.needsTexture = false
                }
            }
            snapshot = blocks.toList()
            currentHighlight = highlightBlockId
        }

        // Base platform tailored to scene layout
        val baseW = if (type in listOf("queue", "linked_list", "java_class", "java_inherit", "py_list_tuple", "py_loop")) 0.16f else 0.09f
        drawBox(shakeX, 0.004f, 0f, baseW, 0.007f, 0.078f, 0.24f, 0.32f, 0.62f, 0.94f, 0)

        // Topic-specific static 3D structural elements
        when (type) {
            "linked_list" -> {
                val active = snapshot.filter { !it.removing }
                for (i in 0 until active.size - 1) {
                    val midX = (active[i].x + active[i + 1].x) / 2f
                    drawBox(midX + shakeX, 0.022f, 0f, 0.016f, 0.005f, 0.005f, 0.98f, 0.80f, 0.08f, 1.0f, 0)
                }
            }
            "java_class" -> {
                // Blueprint Class slab behind spawned objects
                drawBox(shakeX, 0.036f, -0.026f, 0.12f, 0.014f, 0.024f, 0.12f, 0.18f, 0.42f, 0.95f, 0)
            }
            "java_inherit" -> {
                // Superclass cube floating above children + vertical trunk
                drawBox(shakeX, 0.068f, 0f, 0.072f, 0.024f, 0.044f, 0.92f, 0.45f, 0.08f, 0.98f, 0)
                drawBox(shakeX, 0.044f, 0f, 0.006f, 0.024f, 0.006f, 0.95f, 0.95f, 0.95f, 0.90f, 0)
            }
            "py_list_tuple" -> {
                // Right-side immutable Tuple crystal blocks (locked gold/amber)
                drawBox(0.042f + shakeX, 0.020f, 0f, 0.046f, 0.022f, 0.036f, 0.85f, 0.55f, 0.05f, 0.92f, 0)
                drawBox(0.042f + shakeX, 0.046f, 0f, 0.046f, 0.022f, 0.036f, 0.78f, 0.48f, 0.04f, 0.92f, 0)
            }
            "py_loop" -> {
                // Reusable Function block floating above loop pipeline
                drawBox(shakeX, 0.058f, -0.012f, 0.076f, 0.018f, 0.030f, 0.86f, 0.15f, 0.47f, 0.95f, 0)
            }
        }

        // Draw all dynamic 3D data blocks
        for (block in snapshot) {
            val isHi = block.id == currentHighlight && !block.removing
            val pulse = if (isHi) 1.07f + 0.025f * sin(frameTick * 0.22f) else 1.0f
            val r = if (isHi) 0.98f else block.palette.r
            val g = if (isHi) 0.80f else block.palette.g
            val b = if (isHi) 0.08f else block.palette.b

            drawBox(
                x = block.x + shakeX,
                y = block.y,
                z = block.z,
                sx = block.sx * pulse,
                sy = block.sy * pulse,
                sz = block.sz * pulse,
                r = r, g = g, b = b,
                alpha = block.alpha,
                frontTexId = block.textureId
            )
        }

        // Translucent Encapsulation protective shield drawn last
        if (type == "java_encap") {
            GLES20.glDepthMask(false)
            val shieldR = if (shakeFrames > 0) 0.95f else 0.10f
            val shieldG = if (shakeFrames > 0) 0.20f else 0.78f
            val shieldB = if (shakeFrames > 0) 0.20f else 0.92f
            drawBox(shakeX, 0.030f, 0f, 0.088f, 0.048f, 0.068f, shieldR, shieldG, shieldB, 0.30f, 0)
            GLES20.glDepthMask(true)
        }

        GLES20.glDisable(GLES20.GL_BLEND)
    }

    private fun drawBox(
        x: Float, y: Float, z: Float,
        sx: Float, sy: Float, sz: Float,
        r: Float, g: Float, b: Float, alpha: Float,
        frontTexId: Int
    ) {
        System.arraycopy(anchorMatrix, 0, modelMatrix, 0, 16)
        Matrix.translateM(modelMatrix, 0, x, y, z)
        Matrix.scaleM(modelMatrix, 0, sx, sy, sz)
        Matrix.multiplyMM(mvpMatrix, 0, vpMatrix, 0, modelMatrix, 0)

        GLES20.glUniformMatrix4fv(boxMvpUniform, 1, false, mvpMatrix, 0)
        GLES20.glEnableVertexAttribArray(boxPosAttr)
        GLES20.glEnableVertexAttribArray(boxTexAttr)
        faceTexBuffer.position(0)
        GLES20.glVertexAttribPointer(boxTexAttr, 2, GLES20.GL_FLOAT, false, 0, faceTexBuffer)

        val shades = floatArrayOf(0.92f, 0.65f, 1.0f, 0.55f, 0.82f, 0.72f)
        for (faceIdx in 0..5) {
            val buf = cubeFaceBuffers[faceIdx]
            buf.position(0)
            GLES20.glVertexAttribPointer(boxPosAttr, 3, GLES20.GL_FLOAT, false, 0, buf)

            if (faceIdx == 0 && frontTexId != 0) {
                GLES20.glUniform1f(boxUseTexUniform, 1.0f)
                GLES20.glUniform4f(boxColorUniform, 1f, 1f, 1f, alpha)
                GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, frontTexId)
                GLES20.glUniform1i(boxTexUniform, 0)
            } else {
                val shade = shades[faceIdx]
                GLES20.glUniform1f(boxUseTexUniform, 0.0f)
                GLES20.glUniform4f(boxColorUniform, r * shade, g * shade, b * shade, alpha)
            }
            GLES20.glDrawArrays(GLES20.GL_TRIANGLE_FAN, 0, 4)
        }

        GLES20.glDisableVertexAttribArray(boxPosAttr)
        GLES20.glDisableVertexAttribArray(boxTexAttr)
    }

    private fun createLabelTexture(label: String, bgColor: Int): Int {
        val bmp = Bitmap.createBitmap(256, 128, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        canvas.drawColor(bgColor)

        val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(95, 255, 255, 255)
            style = Paint.Style.STROKE
            strokeWidth = 6f
        }
        canvas.drawRect(3f, 3f, 253f, 125f, borderPaint)

        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = if (label.length > 9) 28f else if (label.length > 6) 34f else 42f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val bounds = Rect()
        textPaint.getTextBounds(label, 0, label.length, bounds)
        val textY = 64f - (bounds.top + bounds.bottom) / 2f
        canvas.drawText(label, 128f, textY, textPaint)

        val texIds = IntArray(1)
        GLES20.glGenTextures(1, texIds, 0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texIds[0])
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bmp, 0)
        bmp.recycle()
        return texIds[0]
    }

    private fun toFloatBuffer(arr: FloatArray): FloatBuffer {
        return ByteBuffer.allocateDirect(arr.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .apply { put(arr); position(0) }
    }

    private fun loadShader(type: Int, shaderCode: String): Int {
        return GLES20.glCreateShader(type).also { shader ->
            GLES20.glShaderSource(shader, shaderCode)
            GLES20.glCompileShader(shader)
        }
    }
}
