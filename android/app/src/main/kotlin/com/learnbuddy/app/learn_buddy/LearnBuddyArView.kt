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

private data class StackBlock3D(
    val id: Long,
    val label: String,
    val palette: BlockPalette,
    var y: Float,
    var targetY: Float,
    var alpha: Float,
    var targetAlpha: Float,
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

    // ARCore tracking & 3D Stack state
    private val lock = Any()
    private val maxCapacity = 5
    private var colorCounter = 0
    private val stackBlocks = mutableListOf<StackBlock3D>()
    private var peekBlockId: Long? = null
    private var shakeFrames = 0
    private var frameTick = 0

    private var markerDetected = false
    private var activeObjectType: String? = null
    private var lastSentStatus = ""
    private var dbErrorMessage: String? = null
    private var hasAutoSeeded = false
    private val anchorMatrix = FloatArray(16)
    private val projMatrix = FloatArray(16)
    private val viewMatrix = FloatArray(16)
    private val vpMatrix = FloatArray(16)
    private val modelMatrix = FloatArray(16)
    private val mvpMatrix = FloatArray(16)

    private val palettes = listOf(
        BlockPalette(0.39f, 0.40f, 0.95f, Color.rgb(79, 70, 229)),   // Indigo
        BlockPalette(0.06f, 0.73f, 0.51f, Color.rgb(5, 150, 105)),   // Emerald
        BlockPalette(0.96f, 0.62f, 0.04f, Color.rgb(217, 119, 6)),   // Amber
        BlockPalette(0.93f, 0.28f, 0.60f, Color.rgb(219, 39, 119)),  // Pink
        BlockPalette(0.05f, 0.65f, 0.91f, Color.rgb(2, 132, 199))    // Sky
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
                    context.assets.open("marker_stack.png").use { stream ->
                        val bitmap = BitmapFactory.decodeStream(stream)
                            ?: throw IllegalStateException("Bitmap decode returned null")
                        val db = AugmentedImageDatabase(session)
                        db.addImage("stack_marker", bitmap, 0.12f)
                        config.augmentedImageDatabase = db
                        bitmap.recycle()
                        dbErrorMessage = null
                        Log.i("LearnBuddyArView", "Loaded marker_stack.png into AugmentedImageDatabase (${db.numImages} imgs)")
                    }
                } catch (e: Exception) {
                    dbErrorMessage = "DB Error: ${e.javaClass.simpleName}"
                    Log.e("LearnBuddyArView", "Failed to load marker_stack.png", e)
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
        val activeLabels = synchronized(lock) { stackBlocks.filter { !it.removing }.map { it.label } }
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
            "push" -> {
                val label = call.argument<String>("label")?.trim().orEmpty()
                if (label.isEmpty()) {
                    result.success(buildStateMap("empty_input", null))
                    return
                }
                synchronized(lock) {
                    val active = stackBlocks.filter { !it.removing }
                    if (active.size >= maxCapacity) {
                        shakeFrames = 18
                        result.success(buildStateMap("overflow", null))
                    } else {
                        val idx = active.size
                        val targetY = 0.020f + idx * 0.028f
                        val palette = palettes[colorCounter % palettes.size]
                        colorCounter++
                        stackBlocks.add(
                            StackBlock3D(
                                id = System.nanoTime(),
                                label = label,
                                palette = palette,
                                y = targetY + 0.11f,
                                targetY = targetY,
                                alpha = 0.15f,
                                targetAlpha = 1.0f
                            )
                        )
                        peekBlockId = null
                        result.success(buildStateMap("ok", label))
                    }
                }
            }
            "pop" -> {
                synchronized(lock) {
                    val active = stackBlocks.filter { !it.removing }
                    if (active.isEmpty()) {
                        shakeFrames = 18
                        result.success(buildStateMap("underflow", null))
                    } else {
                        val top = active.last()
                        top.removing = true
                        top.targetY = top.y + 0.12f
                        top.targetAlpha = 0f
                        peekBlockId = null
                        result.success(buildStateMap("ok", top.label))
                    }
                }
            }
            "peek" -> {
                synchronized(lock) {
                    val active = stackBlocks.filter { !it.removing }
                    if (active.isEmpty()) {
                        shakeFrames = 18
                        result.success(buildStateMap("underflow", null))
                    } else {
                        val top = active.last()
                        peekBlockId = top.id
                        result.success(buildStateMap("peek", top.label))
                    }
                }
            }
            "reset" -> {
                synchronized(lock) {
                    for (b in stackBlocks) {
                        b.removing = true
                        b.targetAlpha = 0f
                    }
                    peekBlockId = null
                    colorCounter = 0
                }
                result.success(buildStateMap("reset", null))
            }
            else -> result.notImplemented()
        }
    }

    private fun buildStateMap(event: String, affectedItem: String?): Map<String, Any?> {
        val activeLabels = stackBlocks.filter { !it.removing }.map { it.label }
        return mapOf(
            "items" to activeLabels,
            "capacity" to maxCapacity,
            "event" to event,
            "affectedItem" to affectedItem,
            "markerDetected" to markerDetected
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

        val vs = loadShader(
            GLES20.GL_VERTEX_SHADER,
            """
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() {
                gl_Position = a_Position;
                v_TexCoord = a_TexCoord;
            }
            """.trimIndent()
        )
        val fs = loadShader(
            GLES20.GL_FRAGMENT_SHADER,
            """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            varying vec2 v_TexCoord;
            uniform samplerExternalOES s_Texture;
            void main() {
                gl_FragColor = texture2D(s_Texture, v_TexCoord);
            }
            """.trimIndent()
        )
        quadProgram = GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, vs)
            GLES20.glAttachShader(it, fs)
            GLES20.glLinkProgram(it)
        }
        quadPositionAttr = GLES20.glGetAttribLocation(quadProgram, "a_Position")
        quadTexCoordAttr = GLES20.glGetAttribLocation(quadProgram, "a_TexCoord")
    }

    private fun setup3DBoxRenderer() {
        val vs = loadShader(
            GLES20.GL_VERTEX_SHADER,
            """
            uniform mat4 u_MvpMatrix;
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() {
                gl_Position = u_MvpMatrix * a_Position;
                v_TexCoord = a_TexCoord;
            }
            """.trimIndent()
        )
        val fs = loadShader(
            GLES20.GL_FRAGMENT_SHADER,
            """
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
            """.trimIndent()
        )
        boxProgram = GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, vs)
            GLES20.glAttachShader(it, fs)
            GLES20.glLinkProgram(it)
        }
        boxPosAttr = GLES20.glGetAttribLocation(boxProgram, "a_Position")
        boxTexAttr = GLES20.glGetAttribLocation(boxProgram, "a_TexCoord")
        boxMvpUniform = GLES20.glGetUniformLocation(boxProgram, "u_MvpMatrix")
        boxColorUniform = GLES20.glGetUniformLocation(boxProgram, "u_Color")
        boxUseTexUniform = GLES20.glGetUniformLocation(boxProgram, "u_UseTexture")
        boxTexUniform = GLES20.glGetUniformLocation(boxProgram, "u_Texture")

        // 6 faces of unit cube (-0.5..0.5), each as a 4-vertex triangle fan
        cubeFaceBuffers = listOf(
            // 0: Front (+Z) — top-left, bottom-left, bottom-right, top-right
            toFloatBuffer(floatArrayOf(-0.5f, 0.5f, 0.5f, -0.5f, -0.5f, 0.5f, 0.5f, -0.5f, 0.5f, 0.5f, 0.5f, 0.5f)),
            // 1: Back (-Z)
            toFloatBuffer(floatArrayOf(0.5f, 0.5f, -0.5f, 0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, 0.5f, -0.5f)),
            // 2: Top (+Y)
            toFloatBuffer(floatArrayOf(-0.5f, 0.5f, -0.5f, -0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, -0.5f)),
            // 3: Bottom (-Y)
            toFloatBuffer(floatArrayOf(-0.5f, -0.5f, 0.5f, -0.5f, -0.5f, -0.5f, 0.5f, -0.5f, -0.5f, 0.5f, -0.5f, 0.5f)),
            // 4: Right (+X)
            toFloatBuffer(floatArrayOf(0.5f, 0.5f, 0.5f, 0.5f, -0.5f, 0.5f, 0.5f, -0.5f, -0.5f, 0.5f, 0.5f, -0.5f)),
            // 5: Left (-X)
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

            // 1. Draw Camera Background
            drawCameraBackground(frame)

            // 2. Track Marker (AugmentedImage) & resolve 3D object type
            val camState = frame.camera.trackingState
            val images = session.getAllTrackables(AugmentedImage::class.java)
            var foundTracking = false
            var detectedType: String? = null
            var methodLabel = ""
            for (img in images) {
                if (img.trackingState == TrackingState.TRACKING) {
                    val mappedType = when (img.name) {
                        "stack_marker" -> "stack"
                        // Future markers (e.g. "queue_marker" -> "queue") map here
                        else -> null
                    }
                    if (mappedType != null) {
                        img.centerPose.toMatrix(anchorMatrix, 0)
                        foundTracking = true
                        detectedType = mappedType
                        methodLabel = img.trackingMethod.name
                        break
                    }
                }
            }

            if (foundTracking && detectedType == "stack" && !hasAutoSeeded) {
                synchronized(lock) {
                    if (stackBlocks.none { !it.removing }) {
                        val palette = palettes[colorCounter % palettes.size]
                        colorCounter++
                        stackBlocks.add(
                            StackBlock3D(
                                id = System.nanoTime(),
                                label = "Data 1",
                                palette = palette,
                                y = 0.020f + 0.10f,
                                targetY = 0.020f,
                                alpha = 0.2f,
                                targetAlpha = 1.0f
                            )
                        )
                    }
                    hasAutoSeeded = true
                }
            }

            val statusText = when {
                dbErrorMessage != null -> dbErrorMessage!!
                foundTracking -> "3D Aktif ($methodLabel)"
                camState != TrackingState.TRACKING -> "Kamera: ${frame.camera.trackingFailureReason.name}"
                else -> "Mencari Marker..."
            }
            emitMarkerStatus(foundTracking, detectedType, statusText)

            // 3. Draw 3D Stack if marker is detected
            if (foundTracking) {
                frame.camera.getProjectionMatrix(projMatrix, 0, 0.05f, 20.0f)
                frame.camera.getViewMatrix(viewMatrix, 0)
                Matrix.multiplyMM(vpMatrix, 0, projMatrix, 0, viewMatrix, 0)

                drawStack3D()
            } else {
                // Still advance/clean up animations while marker is off-screen
                synchronized(lock) {
                    stepAnimationsAndCleanupGl()
                }
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
        val iter = stackBlocks.iterator()
        while (iter.hasNext()) {
            val b = iter.next()
            b.y += (b.targetY - b.y) * 0.18f
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

    private fun drawStack3D() {
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(true)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glUseProgram(boxProgram)

        val shakeX: Float
        val snapshot: List<StackBlock3D>
        val currentPeekId: Long?

        synchronized(lock) {
            if (shakeFrames > 0) {
                shakeFrames--
                shakeX = sin(shakeFrames * 1.4f) * 0.006f
            } else {
                shakeX = 0f
            }
            stepAnimationsAndCleanupGl()
            for (b in stackBlocks) {
                if (b.needsTexture) {
                    b.textureId = createLabelTexture(b.label, b.palette.hexBg)
                    b.needsTexture = false
                }
            }
            snapshot = stackBlocks.toList()
            currentPeekId = peekBlockId
        }

        // Draw bright indigo-tinted base tray on the marker
        drawBox(
            x = shakeX,
            y = 0.004f,
            z = 0f,
            sx = 0.082f,
            sy = 0.008f,
            sz = 0.068f,
            r = 0.28f,
            g = 0.36f,
            b = 0.68f,
            alpha = 0.96f,
            frontTexId = 0
        )

        // Draw each Stack block
        for (block in snapshot) {
            val isPeek = block.id == currentPeekId && !block.removing
            val pulse = if (isPeek) 1.06f + 0.02f * sin(frameTick * 0.2f) else 1.0f
            val r = if (isPeek) 0.98f else block.palette.r
            val g = if (isPeek) 0.80f else block.palette.g
            val b = if (isPeek) 0.08f else block.palette.b

            drawBox(
                x = shakeX,
                y = block.y,
                z = 0f,
                sx = 0.066f * pulse,
                sy = 0.024f * pulse,
                sz = 0.052f * pulse,
                r = r,
                g = g,
                b = b,
                alpha = block.alpha,
                frontTexId = block.textureId
            )
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
            color = Color.argb(90, 255, 255, 255)
            style = Paint.Style.STROKE
            strokeWidth = 6f
        }
        canvas.drawRect(3f, 3f, 253f, 125f, borderPaint)

        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = if (label.length > 8) 32f else 42f
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
            .apply {
                put(arr)
                position(0)
            }
    }

    private fun loadShader(type: Int, shaderCode: String): Int {
        return GLES20.glCreateShader(type).also { shader ->
            GLES20.glShaderSource(shader, shaderCode)
            GLES20.glCompileShader(shader)
        }
    }
}
