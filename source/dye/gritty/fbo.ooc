
// third-party stuff
use deadlogger
import deadlogger/Log

import sdl2/[OpenGL]

// our stuff
use dye
import dye/[core, math, sprite]
import dye/gritty/[texture]

/*
 * Frame buffer object support
 */
Fbo: class {

    dye: DyeContext

    size: Vec2i
    texture: Texture
    rboId: Int
    fboId: Int

    logger := static Log getLogger(This name)

    init: func (=dye, =size) {
        // create a texture object
        texture = Texture new(size x, size y, "<fbo %p>" format(this))
        texture upload(null)

        // create a renderbuffer object to store depth info
        if (!glGenRenderbuffers) {
            raise("your graphics card doesn't support FBOs. Get a better one!")
        }

        glGenRenderbuffers(1, rboId&)
        glBindRenderbuffer(GL_RENDERBUFFER, rboId)
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, size x, size y)
        glBindRenderbuffer(GL_RENDERBUFFER, 0)

        // create a framebuffer object
        glGenFramebuffers(1, fboId&)
        bind()

        // attach the texture to FBO color attachment point
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture id, 0)

        // attach the renderbuffer to depth attachment point
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboId)

        // check FBO status
        status := glCheckFramebufferStatus(GL_FRAMEBUFFER)
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            logger warn("FBO status = %d" format(status as Int))
            logger error("FBO (Frame Buffer Objects) not supported, cannot continue")
            raise("fbo problem")
        }

        // switch back to window-system-provided framebuffer
        unbind()
    }

    bind: func {
        glBindFramebuffer(GL_FRAMEBUFFER, fboId)
    }

    unbind: func {
        glBindFramebuffer(GL_FRAMEBUFFER, 0)
    }

}

