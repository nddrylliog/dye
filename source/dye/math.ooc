
// libs deps
import math

EPSILON := 0.001f

/**
 * A 2-dimensional float point vector
 */
Vec2: cover {

    x, y: Float

    norm: func -> Float {
        sqrt(x * x + y * y)
    }

    neg: func -> This {
        (-x, -y) as This
    }

    squaredNorm: func -> Float {
        x * x + y * y
    }

    normalize: func -> This {
        n := sqrt(x * x + y * y)
        if (n == 0.0) return this
        (x / n, y / n) as This
    }

    dist: func (v: This) -> Float {
        diff := (v x - x, v y - y) as This
        sqrt(diff x * diff x + diff y * diff y)
    }

    /**
     * Unit vector that has a certain angle - in radians
     */
    fromAngle: static func (radians: Float) -> This {
        (cos(radians), sin(radians)) as This
    }

    /**
     * Angle this vector makes with (0, 1) - in radians
     */
    angle: func -> Float {
        angle := atan2(y, x) as Float
        if (angle < 0) {
            angle += 2 * PI
        }
        angle
    }

    mul: func (f: Float) -> This {
        (x * f, y * f) as This
    }

    mul: func ~vec (v: This) -> This {
        (x * v x, y * v y) as This
    }

    zero?: func -> Bool {
        x == 0.0 && y == 0.0
    }

    unit?: func -> Bool {
        x == 1.0 && y == 1.0
    }

    snap: func (size: Int) -> This {
        ix := ceil(- 0.5 + (x / size as Float)) * size
        iy := ceil(- 0.5 + (y / size as Float)) * size

        (ix, iy) as This
    }

    snap: func ~rect (size: This, gridSize: Int) -> This {
        halfSize := (size x * 0.5, - size y * 0.5) as This
        diff := (x - halfSize x, y - halfSize y) as This
        snapped := diff snap(gridSize)
        (snapped x + halfSize x, snapped y + halfSize y) as This
    }

    getColRow: func (gridSize: Int) -> Vec2i {
        col := ceil(- 0.5 + (x / gridSize as Float))
        row := ceil(- 0.5 + (y / gridSize as Float))
        (col, row) as Vec2i
    }

    round: func -> Vec2i {
        (x as Int, y as Int) as Vec2i
    }

    sub: func (v: This) -> This {
        (x - v x, y - v y) as This
    }

    sub: func ~floats (px, py: Float) -> This {
        (x - px, y - py) as This
    }

    add: func (v: This) -> This {
        (x + v x, y + v y) as This
    }

    add: func ~floats (px, py: Float) -> This {
        (x + px, y + py) as This
    }

    /// Returns a perpendicular vector. (90 degree rotation)
    perp: func -> This {
        (-y, x) as This
    }

    /// Returns a perpendicular vector. (-90 degree rotation)
    rperp: func -> This {
        (-y, x) as This
    }

    project: func (v: This) -> This {
        v = v normalize()
        d := dot(v)
        (v x * d, v y * d) as This
    }

    dot: func (v: This) -> Float {
        x * v x + y * v y
    }

    cross: func (v: This) -> Float {
        x * v y - y * v x
    }

    lerp: func (target: This, alpha: Float) -> Vec2 {
        (x * (1 - alpha) + target x * alpha,
         y * (1 - alpha) + target y * alpha) as This
    }

    lerpX: func (target: Float, alpha: Float) -> This {
        (x * (1 - alpha) + target * alpha, y) as This
    }

    lerpY: func (target: Float, alpha: Float) -> This {
        (x, y * (1 - alpha) + target * alpha) as This
    }

    clamp: func (bottomLeft, topRight: Vec2) -> This {
        (
            x clamp(bottomLeft x, topRight x),
            y clamp(bottomLeft y, topRight y)
        ) as This
    }

    inside?: func (bottomLeft, topRight: Vec2) -> Bool {
        x > bottomLeft x && \
        x < topRight x && \
        y > bottomLeft y && \
        y < topRight y
    }

    toString: func -> String {
        "(%.2f, %.2f)" format(x, y)
    }

    _: String { get { toString() } }

    equals?: func (v: This, epsilon: Float) -> Bool {
        dx := v x - x
        if (dx < -epsilon || dx > epsilon) return false

        dy := v y - y
        if (dy < -epsilon || dy > epsilon) return false

        true
    }

    /// Check if two vectors are equal. (Be careful when comparing floating point numbers!)
    equals?: func ~exact (v: This) -> Bool {
        x == v x && y == v y
    }

}

// shortcuts (performance penalty)
vec2: func (x, y: Float) -> Vec2 { (x, y) as Vec2 }
vec2: func ~square (xy: Float) -> Vec2 { (xy, xy) as Vec2 }

/**
 * A 3-dimensional float vector
 */
Vec3: cover {

    x, y, z: Float

    norm: func -> Float {
        sqrt(squaredNorm())
    }

    squaredNorm: func -> Float {
        x * x + y * y + z * z
    }

    lerp: func (target: This, alpha: Float) -> This {
        (x * (1 - alpha) + target x * alpha,
         y * (1 - alpha) + target y * alpha,
         z * (1 - alpha) + target z * alpha) as This
    }

    toString: func -> String {
        "(%.2f, %.2f, %.2f)" format(x, y, z)
    }

    _: String { get { toString() } }

    equals?: func (v: This, epsilon: Float) -> Bool {
        dx := v x - x
        if (dx < -epsilon || dx > epsilon) return false

        dy := v y - y
        if (dy < -epsilon || dy > epsilon) return false

        dz := v z - z
        if (dz < -epsilon || dz > epsilon) return false

        true
    }

}

// shortcuts (performance penalty)
vec3: func (x, y, z: Float) -> Vec3 { (x, y, z) as Vec3 }

Vec2i: cover {

    x, y: Int

    equals?: func (v: This) -> Bool {
        (x == v x && y == v y)
    }

    div: func (i: Int) -> This {
        (x / i, y / i) as This
    }

    add: func ~ints (x, y: Int) -> This {
        (this x + x, this y + y) as This
    }

    add: func ~vec2i (v: This) -> This {
        (this x + v x, this y + v y) as This
    }

    add: func ~vec2 (v: Vec2) -> Vec2 {
        (v x + x as Float, v y + y as Float) as Vec2
    }

    mul: func (f: Int) -> This {
        (x * f, y * f) as This
    }

    mul: func ~vec (v: This) -> This {
        (x * v x, y * v y) as This
    }

    toString: func -> String {
        "(%d, %d)" format(x, y)
    }

    toVec2: func -> Vec2 {
        (x as Float, y as Float) as Vec2
    }

    /**
     * @return the y / x ratio, as Float
     */
    ratio: func -> Float {
        y as Float / x as Float
    }

    clamp: func (bottomLeft, topRight: Vec2i) -> This {
        (
            x clamp(bottomLeft x, topRight x),
            y clamp(bottomLeft y, topRight y)
        ) as This
    }

    _: String { get { toString() } }

}

operator == (v1, v2: Vec2i) -> Bool {
    v1 equals?(v2)
}

// shortcuts (performance penalty)
vec2i: func ~ints (x, y: Int) -> Vec2i { (x, y) as Vec2i }
vec2i: func ~vec2i (v: Vec2i) -> Vec2i { (v x, v y) as Vec2i }

/**
 * Extend float with angle conversion routines, clamping/repetition, lerping
 */
extend Float {

    toRadians: func -> This {
        this * PI / 180.0
    }

    toDegrees: func -> This {
        this * 180.0 /  PI
    }

    repeat: func (min, max: This) -> This {
        if (max - min < 0) {
            raise("Float repeat(), invalid range: %.2f..%.2f" format(min, max))
        }

        number := this
        if (number < min) {
            number += (max - min)
        }

        if (number >= max) {
            number -= (max - min)
        }
        number
    }

    clamp: func (min, max: This) -> This {
        if (max - min < 0) {
            raise("Float clamp(), invalid range: %.2f..%.2f" format(min, max))
        }

        number := this
        if (number < min) {
            number = min
        }

        if (number > max) {
            number = max
        }
        number
    }

    lerp!: func@ (target, alpha: This) {
        this = this * (1.0 - alpha) + target * alpha
    }

    lerp: func (target, alpha: This) -> This {
        this * (1.0 - alpha) + target * alpha
    }

    lerpDegrees!: func@ (target, alpha: This) {
        a: Float = this
        b: Float = target repeat(0, 360)

        diff := a - b
        if (diff > 180.0 || diff < -180.0) {
            match {
                case (b > a) => a += 360.0
                case         => b += 360.0
            }
        }
        this = (a + ((b - a) as Float) * (alpha as Float)) repeat(0, 360)
    }


}

/**
 * Extend Int with repeat/clamp/next power of two
 */
extend Int {

    repeat: func (min, max: This) -> This {
        if (max - min < 0) {
            Exception new("Int repeat(), invalid range: %d..%d" format(min, max)) throw()
        }

        number := this
        if (number < min) {
            number += (max - min)
        }

        if (number >= max) {
            number -= (max - min)
        }
        number
    }

    repeat!: func@ (min, max: This) {
        this = repeat(min, max)
    }

    clamp: func (min, max: This) -> This {
        if (max - min < 0) {
            Exception new("Int clamp(), invalid range: %d..%d" format(min, max)) throw()
        }

        number := this
        if (number < min) {
            number = min
        }

        if (number > max) {
            number = max
        }
        number
    }

    clamp!: func@ (min, max: This) {
        this = clamp(min, max)
    }

    nextPowerOfTwo: func -> This {
        in := this - 1

        in |= in >> 16
        in |= in >> 8
        in |= in >> 4
        in |= in >> 2
        in |= in >> 1

        in + 1
    }

}


/**
 * A 4x4 matrix, mostly used for transformations
 */
Matrix4: cover {

    /** 16 floats, column-major format */

    a1, a2, a3, a4: Float
    b1, b2, b3, b4: Float
    c1, c2, c3, c4: Float
    d1, d2, d3, d4: Float

    transpose: func -> This {
        (
            a1, b1, c1, d1, 
            a2, b2, c2, d2, 
            a3, b3, c3, d3, 
            a4, b4, c4, d4
        ) as This
    }

    /**
     * The identity matrix
     */
    identity := static (
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    ) as This

    /**
     * Create a new translation matrix
     */
    newTranslate: static func (x, y, z: Float) -> This {
        (
            1.0f,   0.0f,   0.0f,   0.0f,
            0.0f,   1.0f,   0.0f,   0.0f,
            0.0f,   0.0f,   1.0f,   0.0f,
            x,      y,      z,      1.0f
        ) as This
    }

    /**
     * Create a new rotation matrix around axis (1.0, 0.0, 0.0)
     *
     * :param: a is the angle in radians
     */
    newRotateX: static func (a: Float) -> This {

        /*
         * Source: http://stackoverflow.com/questions/3982418
         *
         * Converted by hand to column-major
         */
        c := a cos()
        s := a sin()

        (
            1.0f,   0.0f,   0.0f,   0.0f,
            0.0f,   c,      s,      0.0f,
            0.0f,  -s,      c,      0.0f,
            0.0f,   0.0f,   0.0f,   1.0f
        ) as This
    }

    /**
     * Create a new rotation matrix around axis (0.0, 1.0, 0.0)
     *
     * :param: a is the angle in radians
     */
    newRotateY: static func (a: Float) -> This {

        /*
         * Source: http://stackoverflow.com/questions/3982418
         *
         * Converted by hand to column-major
         */
        c := a cos()
        s := a sin()

        (
            c,      0.0f,  -s,      0.0f,
            0.0f,   1.0f,   0.0f,   0.0f,
            s,      0.0f,   c,      0.0f,
            0.0f,   0.0f,   0.0f,   1.0f
        ) as This
    }

    /**
     * Create a new rotation matrix around axis (0.0, 0.0, 1.0)
     *
     * :param: a is the angle in radians
     */
    newRotateZ: static func (a: Float) -> This {

        /*
         * Source: http://stackoverflow.com/questions/3982418
         *
         * Converted by hand to column-major
         */
        c := a cos()
        s := a sin()

        (
             c,     s,      0.0f,   0.0f,
            -s,     c,      0.0f,   0.0f,
            0.0f,   0.0f,   1.0f,   0.0f,
            0.0f,   0.0f,   0.0f,   1.0f
        ) as This
    }

    /**
     * Create a new scaling matrix
     */
    newScale: static func (x, y, z: Float) -> This {
        /*
         * Source: http://en.wikipedia.org/wiki/Transformation_matrix#Scaling
         *
         * Beautiful, it's the same in row-major and column-major :D
         * ie. m transposed() == m
         */

        (
            x,    0.0f, 0.0f, 0.0f
            0.0f, y,    0.0f, 0.0f
            0.0f, 0.0f, z,    0.0f
            0.0f, 0.0f, 0.0f, 1.0f
        ) as This
    }

    /**
     * Create a new orthographic projection matrix
     *
     * Somehow similar to glOrtho
     */
    newOrtho: static func (left, right, bottom, top, _near, _far: Float) -> This {
        (l, r, b, t) := (left, right, bottom, top)
        (n, f) := (_near, _far)

        w := r - l // width
        h := t - b // height
        d := f - n // depth

        /*
         * Source: http://www.songho.ca/opengl/gl_projectionmatrix.html
         *
         * Converted by hand to column-major
         */
        (
            2.0f / w,       0.0f,            0.0f,          0.0f,
            0.0f,           2.0f / h,        0.0f,          0.0f,
            0.0f,           0.0f,           -2.0f / d,      0.0f,
            ((r + l) / -w), ((t + b) / -h), ((f + n) / -d), 1.0f
        ) as This
    }

    /**
     * Create a new perspective projection matrix
     *
     * Somehow similar to glOrtho
     */
    newPerspective: static func (left, right, bottom, top, _near, _far: Float) -> This {
        (l, r, b, t) := (left, right, bottom, top)
        (n, f) := (_near, _far)

        w := r - l
        h := t - b
        d := f - n // depth

        /*
         * Source: http://www.songho.ca/opengl/gl_projectionmatrix.html
         *
         * Converted by hand to column-major
         */
        (
            2 * n / w,     0.0f,                     0.0f,           0.0f,
            0.0f,          2 * n / h,                0.0f,           0.0f,
            (r + l) / w,   (t + b) / h,      (f + n) / -d,          -1.0f,
            0.0f,          0.0f,        -2.0f * f * n / d,           0.0f
        ) as This
    }

    /**
     * Multiply two matrices.
     *
     * This is a naive, unoptimized, O(n^3) function.
     */
    mul: final func (m2: This) -> This {
        result: This

        m1v := this& as Float*
        m2v := m2& as Float*
        rev := result& as Float*

        for (col in 0..4) {
            fourcol := col * 4
            for (row in 0..4) {
                rev[fourcol + row] = \
                    m1v[     row] * m2v[fourcol    ] + \
                    m1v[ 4 + row] * m2v[fourcol + 1] + \
                    m1v[ 8 + row] * m2v[fourcol + 2] + \
                    m1v[12 + row] * m2v[fourcol + 3]
            }
        }

        result
    }

    toString: func -> String {
        "[[#{a1}, #{a2}, #{a3}, #{a4}]\n" +
        " [#{b1}, #{b2}, #{b3}, #{b4}]\n" +
        " [#{c1}, #{c2}, #{c3}, #{c4}]\n" +
        " [#{d1}, #{d2}, #{d3}, #{d4}]]"
    }

    _: String {
        get { toString() }
    }

    round: func -> This {
        (
            a1,        a2,        a3,        a4,
            b1,        b2,        b3,        b4,
            c1,        c2,        c3,        c4,
            d1 as Int, d2 as Int, d3 as Int, d4
        ) as This
    }

    inverse: func -> This {
        inv: Float[16]

        inv[0] = b2 * c3 * d4 - 
                 b2 * c4 * d3 - 
                 c2 * b3 * d4 + 
                 c2 * b4 * d3 +
                 d2 * b3 * c4 - 
                 d2 * b4 * c3

        inv[4] = -b1 * c3 * d4 + 
                  b1 * c4 * d3 + 
                  c1 * b3 * d4 - 
                  c1 * b4 * d3 - 
                  d1 * b3 * c4 + 
                  d1 * b4 * c3

        inv[8] = b1 * c2 * d4 - 
                 b1 * c4 * d2 - 
                 c1 * b2 * d4 + 
                 c1 * b4 * d2 + 
                 d1 * b2 * c4 - 
                 d1 * b4 * c2

        inv[12] = -b1 * c2 * d3 + 
                   b1 * c3 * d2 +
                   c1 * b2 * d3 - 
                   c1 * b3 * d2 - 
                   d1 * b2 * c3 + 
                   d1 * b3 * c2

        inv[1] = -a2 * c3 * d4 + 
                  a2 * c4 * d3 + 
                  c2 * a3 * d4 - 
                  c2 * a4 * d3 - 
                  d2 * a3 * c4 + 
                  d2 * a4 * c3

        inv[5] = a1 * c3 * d4 - 
                 a1 * c4 * d3 - 
                 c1 * a3 * d4 + 
                 c1 * a4 * d3 + 
                 d1 * a3 * c4 - 
                 d1 * a4 * c3

        inv[9] = -a1 * c2 * d4 + 
                  a1 * c4 * d2 + 
                  c1 * a2 * d4 - 
                  c1 * a4 * d2 - 
                  d1 * a2 * c4 + 
                  d1 * a4 * c2

        inv[13] = a1 * c2 * d3 - 
                  a1 * c3 * d2 - 
                  c1 * a2 * d3 + 
                  c1 * a3 * d2 + 
                  d1 * a2 * c3 - 
                  d1 * a3 * c2

        inv[2] = a2 * b3 * d4 - 
                 a2 * b4 * d3 - 
                 b2 * a3 * d4 + 
                 b2 * a4 * d3 + 
                 d2 * a3 * b4 - 
                 d2 * a4 * b3

        inv[6] = -a1 * b3 * d4 + 
                  a1 * b4 * d3 + 
                  b1 * a3 * d4 - 
                  b1 * a4 * d3 - 
                  d1 * a3 * b4 + 
                  d1 * a4 * b3

        inv[10] = a1 * b2 * d4 - 
                  a1 * b4 * d2 - 
                  b1 * a2 * d4 + 
                  b1 * a4 * d2 + 
                  d1 * a2 * b4 - 
                  d1 * a4 * b2

        inv[14] = -a1 * b2 * d3 + 
                   a1 * b3 * d2 + 
                   b1 * a2 * d3 - 
                   b1 * a3 * d2 - 
                   d1 * a2 * b3 + 
                   d1 * a3 * b2

        inv[3] = -a2 * b3 * c4 + 
                  a2 * b4 * c3 + 
                  b2 * a3 * c4 - 
                  b2 * a4 * c3 - 
                  c2 * a3 * b4 + 
                  c2 * a4 * b3

        inv[7] = a1 * b3 * c4 - 
                 a1 * b4 * c3 - 
                 b1 * a3 * c4 + 
                 b1 * a4 * c3 + 
                 c1 * a3 * b4 - 
                 c1 * a4 * b3

        inv[11] = -a1 * b2 * c4 + 
                   a1 * b4 * c2 + 
                   b1 * a2 * c4 - 
                   b1 * a4 * c2 - 
                   c1 * a2 * b4 + 
                   c1 * a4 * b2

        inv[15] = a1 * b2 * c3 - 
                  a1 * b3 * c2 - 
                  b1 * a2 * c3 + 
                  b1 * a3 * c2 + 
                  c1 * a2 * b3 - 
                  c1 * a3 * b2

        det: Float = a1 * inv[0] + a2 * inv[4] + a3 * inv[8] + a4 * inv[12]

        if (det == 0.0f) {
            raise("Cannot invert matrix!")
        }

        det = 1.0f / det

        result: Matrix4

        result a1 = inv[0]  * det
        result a2 = inv[1]  * det
        result a3 = inv[2]  * det
        result a4 = inv[3]  * det

        result b1 = inv[4]  * det
        result b2 = inv[5]  * det
        result b3 = inv[6]  * det
        result b4 = inv[7]  * det

        result c1 = inv[8]  * det
        result c2 = inv[9]  * det
        result c3 = inv[10] * det
        result c4 = inv[11] * det

        result d1 = inv[12] * det
        result d2 = inv[13] * det
        result d3 = inv[14] * det
        result d4 = inv[15] * det

        result
    }

}

operator * (m1, m2: Matrix4) -> Matrix4 {
    m1 mul(m2)
}

MatrixException: class extends Exception {

    init: func (origin: String, msg: String) {
        super(origin, msg)
    }

}

/**
 * A 2D axis-aligned bounding box.
 */
AABB2: class {
    xMin, yMin, xMax, yMax: Float

    init: func

    init: func ~floats (=xMin, =yMin, =xMax, =yMax)

    init: func ~size (width, height: Float) {
        xMin = width * -0.5f
        xMax = width * 0.5f
        yMin = height * -0.5f
        yMax = height * 0.5f
    }

    set!: func ~aabb (other: This) {
        xMin = other xMin
        xMax = other xMax
        yMin = other yMin
        yMax = other yMax
    }

    set!: func ~floats (=xMin, =yMin, =xMax, =yMax)

    add!: func ~vector (v: Vec2) {
        xMin += v x
        yMin += v y
        xMax += v x
        yMax += v y
    }

    add: func ~vectorCopy (v: Vec2) -> This {
        new(
            xMin + v x,
            yMin + v y,
            xMax + v x,
            yMax + v y
        )
    }

    center: func -> Vec2 {
        vec2(xMin + (xMax - xMin) * 0.5f, yMin + (yMax - yMin) * 0.5f)
    }

    expand!: func ~aabb (other: This) {
        if (other xMin < xMin) {
            xMin = other xMin
        }

        if (other yMin < yMin) {
            yMin = other yMin
        }

        if (other xMax > xMax) {
            xMax = other xMax
        }

        if (other yMax > yMax) {
            yMax = other yMax
        }
    }

    expand!: func ~vec (other: Vec2) {
        if (other x < xMin) {
            xMin = other x
        }

        if (other y < yMin) {
            yMin = other y
        }

        if (other x > xMax) {
            xMax = other x
        }

        if (other y > yMax) {
            yMax = other y
        }
    }

    toString: func -> String {
        "[[%.2f, %.2f], [%.2f, %.2f]]" format(xMin, yMin,
            xMax, yMax)
    }

    _: String { get { toString() } }

    width:  Float { get { xMax - xMin } }
    height: Float { get { yMax - yMin } }

    size: Vec2 { get {
        vec2(width, height)
    } }
}

/**
 * A 2D axis-aligned bounding box - with integers
 */
AABB2i: class {
    xMin, yMin, xMax, yMax: Int

    init: func

    init: func ~values (=xMin, =yMin, =xMax, =yMax)

    set!: func ~aabb (other: This) {
        xMin = other xMin
        xMax = other xMax
        yMin = other yMin
        yMax = other yMax
    }

    add!: func ~vector (v: Vec2i) {
        xMin += v x
        yMin += v y
        xMax += v x
        yMax += v y
    }

    expand!: func ~aabb (other: This) {
        if (other xMin < xMin) {
            xMin = other xMin
        }

        if (other yMin < yMin) {
            yMin = other yMin
        }

        if (other xMax > xMax) {
            xMax = other xMax
        }

        if (other yMax > yMax) {
            yMax = other yMax
        }
    }

    expand!: func ~vec (other: Vec2i) {
        if (other x < xMin) {
            xMin = other x
        }

        if (other y < yMin) {
            yMin = other y
        }

        if (other x > xMax) {
            xMax = other x
        }

        if (other y > yMax) {
            yMax = other y
        }
    }

    toString: func -> String {
        "[[%d, %d], [%d, %d]]" format(xMin, yMin, xMax, yMax)
    }

    _: String { get { toString() } }

    width:  Int { get { xMax - xMin } }
    height: Int { get { yMax - yMin } }
}

/**
 * An RGB color
 */
Color: cover {

    /* r, g, b = [0, 255] UInt8 */
    r, g, b: UInt8

    /* R, G, B = [0.0, 1.0] Float */
    R: Float { get { r / 255.0f } }
    G: Float { get { g / 255.0f } }
    B: Float { get { b / 255.0f } }

    black := static (0, 0, 0) as This
    white := static (255, 255, 255) as This
    red := static (255, 0, 0) as This
    green := static (0, 255, 0) as This
    blue := static (0, 0, 255) as This
    taupe := static (72, 60, 50) as This

    toString: func -> String {
        "(%d, %d, %d)" format(r, g, b)
    }

    _: String { get { toString() } }

    lighten: func (factor: Float) -> This {
        (r as Float / factor, g as Float / factor, b as Float / factor) as This
    }

    mul: func (factor: Float) -> This {
        (r * factor, g * factor, b * factor) as This
    }

}

/**
 * Convex polygon utilities: make sure it has the correct winding
 */
PolyUtils: class {

    sanitize: static func (vecs: Vec2*, count: Int) {
        valid := true

        for (i in 0..count) {
            a := vecs[i]
            b := vecs[(i + 1) % count]
            c := vecs[(i + 2) % count]

            if (b sub(a) cross(c sub(a)) > 0.0f) {
                valid = false
                break
            }
        }

        if (!valid) {
            // reveeeeeeeeerse o/
            bytes := Vec2 size * count
            copy := gc_malloc(bytes) as Vec2*
            memcpy(copy, vecs, bytes)

            for (i in 0..count) {
                j := count - 1 - i
                vecs[i] = copy[j]
            }
        }
    }

}

