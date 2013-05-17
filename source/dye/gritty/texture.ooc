
// our stuff
import dye/[core, math, anim]
import dye/gritty/[io]

// third-party stuff
import sdl2/[OpenGL]

use stb-image

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/HashMap

TextureFilter: enum {
    NEAREST
    LINEAR
}

/**
 * This class represents an RGBA OpenGL texture
 */
Texture: class {

    id: Int
    width, height: Int
    path: String

    filter: TextureFilter

    init: func (=width, =height, =path, filter := TextureFilter LINEAR) {
        glGenTextures(1, id&)
        bind()

        this filter = filter
        setup()
    }

    setup: func {
        filterValue := match filter {
            case TextureFilter LINEAR =>
                GL_LINEAR
            case =>
                GL_NEAREST
        }

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterValue)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filterValue)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_CLAMP_TO_EDGE)
    }

    upload: func (data: UInt8*) {
        internalFormat := GL_RGBA

        version (!android) {
            internalFormat = GL_RGBA8
        }

        glTexImage2D(GL_TEXTURE_2D,
                    0,
                    internalFormat,
                    width,
                    height,
                    0,
                    GL_RGBA,
                    GL_UNSIGNED_BYTE,
                    data
        )
    }

    update: func (data: UInt8*, xOffset := 0, yOffset := 0, updateWidth := 0, updateHeight := 0) {
        bind()
        internalFormat := GL_RGBA

        version (!android) {
            internalFormat = GL_RGBA8
        }

        if (updateWidth == 0) {
            updateWidth = width
        }

        if (updateHeight == 0) {
            updateHeight = height
        }

        glTexSubImage2D(GL_TEXTURE_2D, // target
                    0,                  // level
                    xOffset,            // xoffset
                    yOffset,            // yoffset
                    updateWidth,        // width
                    updateHeight,       // height
                    GL_RGBA,            // format
                    GL_UNSIGNED_BYTE,   // type
                    data                // data
        )
    }

    bind: func {
        glBindTexture(GL_TEXTURE_2D, id)
    }

    detach: func {
        glBindTexture(GL_TEXTURE_2D, 0)
    }

}

/**
 * This is a texture loader with built-in cache
 */
TextureLoader: class {

    cache := static HashMap<String, Texture> new()
    logger := static Log getLogger(This name)

    _placeholder: static Texture

    load: static func (path: String) -> Texture {
        if (cache contains?(path)) {
            return cache get(path)
        }

        width, height, channels: Int

        reader := RWopsReader new(path)
        cb := StbIo callbacks()

        data := StbImage fromCb(cb&, reader, width&, height&, channels&, 4)
        reader close()

        if (width == 0 || height == 0 || channels == 0) {
            logger warn("Failed to load %s!" format(path))
            return _getPlaceholder()
        }

        logger debug("Loading %s, size %dx%d, %d bpp" format(path, width, height, channels))

        // we used to detect the number of channels here, but
        // as it turns out stb_image does the right thing and converts
        // from RGB or Grayscale to RGBA for us, since we requested 4 channels.
        // Which is great!

        texture := Texture new(width, height, path)

        _flip(data, width, height)
        _premultiply(data, width, height)
        texture upload(data)

        cache put(path, texture)

        texture
    }

    _getPlaceholder: static func -> Texture {
        if (!_placeholder) {
            _placeholder = Texture new(0, 0, "<missing>")
        }
        _placeholder
    }

    _premultiply: static func (data: UInt8*, width: Int, height: Int) {
        factor := 1.0 / 255.0
        for (i in 0..(width * height)) {
            b     := data[i * 4 + 0] as Float
            g     := data[i * 4 + 1] as Float
            r     := data[i * 4 + 2] as Float
            alpha := factor * data[i * 4 + 3]

            data[i * 4 + 0] = (b * alpha)
            data[i * 4 + 1] = (g * alpha)
            data[i * 4 + 2] = (r * alpha)
        }

    }

    _flip: static func (data: UInt8*, width: Int, height: Int) {
        pixels := data as UInt32*

        for (y in 0..(height / 2)) {
          y2 := height - 1 - y
          for (x in 0..width) {
            i1 := y  * width + x
            i2 := y2 * width + x

            // flip it!
            tmp := pixels[i1]
            pixels[i1] = pixels[i2]
            pixels[i2] = tmp
          }
        }
    }

}

