package fr.nolabjfjdj.minecraftlegacymobile

import android.app.Activity
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

class MainActivity : Activity() {
    private lateinit var gameView: LegacyGameView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        gameView = LegacyGameView(this)
        setContentView(gameView)
    }

    override fun onPause() {
        super.onPause()
        if (::gameView.isInitialized) gameView.onPause()
    }

    override fun onResume() {
        super.onResume()
        if (::gameView.isInitialized) gameView.onResume()
    }
}

private class LegacyGameView(activity: Activity) : GLSurfaceView(activity) {
    private val gameRenderer = VoxelRenderer()

    init {
        setEGLContextClientVersion(2)
        setRenderer(gameRenderer)
        renderMode = RENDERMODE_CONTINUOUSLY
        setOnTouchListener(object : View.OnTouchListener {
            private var lastX = 0f
            private var lastY = 0f
            private var active = false

            override fun onTouch(view: View, event: MotionEvent): Boolean {
                val x = event.x
                val y = event.y
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> {
                        lastX = x
                        lastY = y
                        active = true
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        if (!active) return true
                        val dx = x - lastX
                        val dy = y - lastY
                        if (lastX < width * 0.38f) {
                            gameRenderer.move(dx / max(width * 0.12f, 1f), -dy / max(height * 0.12f, 1f))
                        } else {
                            gameRenderer.look(dx * 0.006f, -dy * 0.006f)
                        }
                        lastX = x
                        lastY = y
                        return true
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        active = false
                        gameRenderer.stopMoving()
                        return true
                    }
                }
                return true
            }
        })
    }
}

private class VoxelRenderer : GLSurfaceView.Renderer {
    private var program = 0
    private var vertexBuffer: FloatBuffer? = null
    private var vertexCount = 0
    private var positionHandle = 0
    private var colorHandle = 0
    private var matrixHandle = 0
    private val projection = FloatArray(16)
    private val viewMatrix = FloatArray(16)
    private val mvp = FloatArray(16)
    private var cameraX = 12.0f
    private var cameraZ = 18.0f
    private var yaw = 0.0f
    private var pitch = -0.18f
    @Volatile private var moveX = 0f
    @Volatile private var moveForward = 0f
    private var lastTime = 0L

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0.47f, 0.70f, 0.91f, 1f)
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
        val vertexShader = compileShader(GLES20.GL_VERTEX_SHADER, """
            attribute vec3 aPosition;
            attribute vec3 aColor;
            uniform mat4 uMVP;
            varying vec3 vColor;
            void main() {
                gl_Position = uMVP * vec4(aPosition, 1.0);
                vColor = aColor;
            }
        """.trimIndent())
        val fragmentShader = compileShader(GLES20.GL_FRAGMENT_SHADER, """
            precision mediump float;
            varying vec3 vColor;
            void main() { gl_FragColor = vec4(vColor, 1.0); }
        """.trimIndent())
        program = GLES20.glCreateProgram()
        GLES20.glAttachShader(program, vertexShader)
        GLES20.glAttachShader(program, fragmentShader)
        GLES20.glLinkProgram(program)
        positionHandle = GLES20.glGetAttribLocation(program, "aPosition")
        colorHandle = GLES20.glGetAttribLocation(program, "aColor")
        matrixHandle = GLES20.glGetUniformLocation(program, "uMVP")
        val vertices = buildTerrain()
        vertexCount = vertices.size / 6
        vertexBuffer = ByteBuffer.allocateDirect(vertices.size * 4)
            .order(ByteOrder.nativeOrder()).asFloatBuffer().apply {
                put(vertices)
                position(0)
            }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, max(height, 1))
        Matrix.perspectiveM(projection, 0, 70f, width.toFloat() / max(height, 1), 0.1f, 120f)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        val now = System.nanoTime()
        val dt = if (lastTime == 0L) 0f else min((now - lastTime) / 1_000_000_000f, 0.05f)
        lastTime = now
        val forwardX = sin(yaw)
        val forwardZ = -cos(yaw)
        val rightX = cos(yaw)
        val rightZ = sin(yaw)
        cameraX += (forwardX * moveForward + rightX * moveX) * 4.2f * dt
        cameraZ += (forwardZ * moveForward + rightZ * moveX) * 4.2f * dt
        cameraX = cameraX.coerceIn(1f, 22f)
        cameraZ = cameraZ.coerceIn(1f, 22f)
        val eyeY = terrainHeight(cameraX.toInt(), cameraZ.toInt()) + 1.7f
        val targetX = cameraX + sin(yaw) * cos(pitch)
        val targetY = eyeY + sin(pitch)
        val targetZ = cameraZ - cos(yaw) * cos(pitch)
        Matrix.setLookAtM(viewMatrix, 0, cameraX, eyeY, cameraZ, targetX, targetY, targetZ, 0f, 1f, 0f)
        Matrix.multiplyMM(mvp, 0, projection, 0, viewMatrix, 0)

        GLES20.glUseProgram(program)
        GLES20.glUniformMatrix4fv(matrixHandle, 1, false, mvp, 0)
        val buffer = vertexBuffer ?: return
        buffer.position(0)
        GLES20.glEnableVertexAttribArray(positionHandle)
        GLES20.glVertexAttribPointer(positionHandle, 3, GLES20.GL_FLOAT, false, 24, buffer)
        buffer.position(3)
        GLES20.glEnableVertexAttribArray(colorHandle)
        GLES20.glVertexAttribPointer(colorHandle, 3, GLES20.GL_FLOAT, false, 24, buffer)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, vertexCount)
        GLES20.glDisableVertexAttribArray(positionHandle)
        GLES20.glDisableVertexAttribArray(colorHandle)
    }

    fun look(dx: Float, dy: Float) {
        yaw += dx
        pitch = (pitch + dy).coerceIn(-1.15f, 0.85f)
    }

    fun move(x: Float, forward: Float) {
        moveX = x.coerceIn(-1f, 1f)
        moveForward = forward.coerceIn(-1f, 1f)
    }

    fun stopMoving() {
        moveX = 0f
        moveForward = 0f
    }

    private fun compileShader(type: Int, source: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, source)
        GLES20.glCompileShader(shader)
        val status = IntArray(1)
        GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, status, 0)
        if (status[0] == 0) {
            val error = GLES20.glGetShaderInfoLog(shader)
            GLES20.glDeleteShader(shader)
            throw IllegalStateException("Shader compilation failed: $error")
        }
        return shader
    }

    private fun terrainHeight(x: Int, z: Int): Float {
        val broad = ((x / 4 * 17 + z / 4 * 31 + 13) % 5) - 2
        val detail = ((x * 7 + z * 11 + x * z) % 3) - 1
        return (3 + broad + detail).coerceAtLeast(1).toFloat()
    }

    private fun buildTerrain(): FloatArray {
        val data = ArrayList<Float>()
        fun tri(a: FloatArray, b: FloatArray, c: FloatArray, color: FloatArray) {
            for (p in listOf(a, b, c)) {
                data.add(p[0]); data.add(p[1]); data.add(p[2])
                data.add(color[0]); data.add(color[1]); data.add(color[2])
            }
        }
        fun quad(a: FloatArray, b: FloatArray, c: FloatArray, d: FloatArray, color: FloatArray) {
            tri(a, b, c, color)
            tri(a, c, d, color)
        }
        val grass = floatArrayOf(0.27f, 0.62f, 0.20f)
        val dirt = floatArrayOf(0.42f, 0.28f, 0.16f)
        val stone = floatArrayOf(0.43f, 0.45f, 0.47f)
        for (x in 0 until 24) {
            for (z in 0 until 24) {
                val h = terrainHeight(x, z)
                quad(floatArrayOf(x.toFloat(), h, z.toFloat()), floatArrayOf(x + 1f, h, z.toFloat()),
                    floatArrayOf(x + 1f, h, z + 1f), floatArrayOf(x.toFloat(), h, z + 1f), grass)
                val neighbors = arrayOf(
                    Triple(x - 1, z, arrayOf(floatArrayOf(x.toFloat(), 0f, z.toFloat()), floatArrayOf(x.toFloat(), 0f, z + 1f), floatArrayOf(x.toFloat(), h, z + 1f), floatArrayOf(x.toFloat(), h, z.toFloat()))),
                    Triple(x + 1, z, arrayOf(floatArrayOf(x + 1f, 0f, z + 1f), floatArrayOf(x + 1f, 0f, z.toFloat()), floatArrayOf(x + 1f, h, z.toFloat()), floatArrayOf(x + 1f, h, z + 1f))),
                    Triple(x, z - 1, arrayOf(floatArrayOf(x + 1f, 0f, z.toFloat()), floatArrayOf(x.toFloat(), 0f, z.toFloat()), floatArrayOf(x.toFloat(), h, z.toFloat()), floatArrayOf(x + 1f, h, z.toFloat()))),
                    Triple(x, z + 1, arrayOf(floatArrayOf(x.toFloat(), 0f, z + 1f), floatArrayOf(x + 1f, 0f, z + 1f), floatArrayOf(x + 1f, h, z + 1f), floatArrayOf(x.toFloat(), h, z + 1f)))
                )
                for ((nx, nz, face) in neighbors) {
                    val nh = if (nx in 0 until 24 && nz in 0 until 24) terrainHeight(nx, nz) else 0f
                    if (nh < h) {
                        val bottom = max(nh, 0f)
                        val adjusted = arrayOf(face[0].copyOf(), face[1].copyOf(), face[2].copyOf(), face[3].copyOf())
                        adjusted[0][1] = bottom
                        adjusted[1][1] = bottom
                        val shade = if (h - nh > 2f) stone else dirt
                        quad(adjusted[0], adjusted[1], adjusted[2], adjusted[3], shade)
                    }
                }
            }
        }
        return data.toFloatArray()
    }
}
