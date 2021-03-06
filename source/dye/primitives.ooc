
use sdl2
import sdl2/[OpenGL]

use dye
import dye/[core, pass, math, shader, texture]
import dye/base/[vbo, vao]

/**
 * Plain, monochrome, non-textured rectangle
 */
Rectangle: class extends Drawable {

    size: Vec2
    oldSize := vec2(0, 0)

    EPSILON := 0.1

    color := Color green
    opacity := 1.0

    center := true
    filled := true
    lineWidth := 1.0

    width: Float { get { size x } }
    height: Float { get { size y } }

    program: ShaderProgram
    vao: VAO

    vbo: FloatVBO
    vertices: Float[]

    /* Uniforms */
    projLoc, modelLoc, colorLoc: Int

    init: func (width := 16.0f, height := 16.0f) {
        size = (width, height) as Vec2
        vbo = FloatVBO new()
        rebuild()
        setProgram(ShaderLoader load("dye/solid_2d"))
    }

    setProgram: func (.program) {
        if (this program) {
            this program detach()
        }
        this program = program
        program use()

        if (vao) {
            vao = null
        }

        vao = VAO new(program)
        vao add(vbo, "Position", 2, GL_FLOAT, false, 0, 0 as Pointer)

        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!visible) return

        mv := computeModelView(modelView)

        if (center) {
            mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
        }

        draw(pass, mv)
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        if (!size equals?(oldSize, EPSILON)) {
            rebuild()
        }

        program use()
        vao bind()

        glUniformMatrix4fv(projLoc, 1, false, (pass projectionMatrix&) as Pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView& as Pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        if (!filled) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
        }

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

        if (!filled) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
        }

        vao detach()
        program detach()

    }

    rebuild: func {
        vertices = [
            0.0, 0.0,
            size x, 0.0,
            0.0, size y,
            size x, size y
        ]
        oldSize = size

        vbo upload(vertices)
    }

}

/**
 * Plain, monochrome, non-textured convex polygon
 */
Poly: class extends Drawable {

    points: Vec2*
    count: Int

    EPSILON := 0.1

    color := Color green
    opacity := 1.0

    program: ShaderProgram
    vao: VAO

    vbo: FloatVBO
    vertices: Float[]

    /* Uniforms */
    projLoc, modelLoc, colorLoc: Int

    init: func (=points, =count) {
        vbo = FloatVBO new()
        rebuild()
        setProgram(ShaderLoader load("dye/solid_2d"))
    }

    setProgram: func (.program) {
        if (this program) {
            this program detach()
        }
        this program = program
        program use()

        if (vao) {
            vao = null
        }

        vao = VAO new(program)
        vao add(vbo, "Position", 2, GL_FLOAT, false, 0, 0 as Pointer)

        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!visible) return

        mv := computeModelView(modelView)
        draw(pass, mv)
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        program use()
        vao bind()

        glUniformMatrix4fv(projLoc, 1, false, (pass projectionMatrix&) as Pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView& as Pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)


        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        glDrawArrays(GL_TRIANGLES, 0, vertices length / 2)

        vao detach()
        program detach()

    }

    rebuild: func {
        numTris := count - 2
        numVerts := numTris * 3
        numFloats := numVerts * 2

        vertices = Float[numFloats] new()
        vi := 0

        p0 := points[0]
        for (i in 2..count) {
            p1 := points[i - 1]
            p2 := points[i]

            vertices[vi] = p0 x; vi += 1
            vertices[vi] = p0 y; vi += 1

            vertices[vi] = p1 x; vi += 1
            vertices[vi] = p1 y; vi += 1

            vertices[vi] = p2 x; vi += 1
            vertices[vi] = p2 y; vi += 1
        }

        vbo upload(vertices)
    }

}

