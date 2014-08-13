# Minimal Image Liguid Tag to integrate with the theme's CSS and JS
#
# Use like {% image src=ImageSRC | arg_1=arg_1_value | arg_2=... %}
#
# Parameters
# ----------
#     *    src (required)
#     *    no_lazy => disable lazy loading of the image and add .no-lazy class, no value needed
#     *    retina => defaults to src
#     *    zoom => defaults to retina
#     *    zoom-retina => defaults to no_zoom
#     *    no_zoom => disbale lightbox and add .no-zoom class, no value needed
#     *    size => huge, small or big defaults to big
#     *    caption => image caption

module Jekyll

    class Image < Liquid::Tag

        def initialize(tag_name, args, tokens)
            @args = parse_args(args)
            super
        end

        def render(context)

            if !@args.has_key?("src")
                throw "Missing src key on image"
            end

            main_class = "image-wrapper"

            classes = []
            size_class = (@args.has_key?("size") ? @args["size"] : "big")
            classes.push size_class

            if @args.has_key?("no_lazy")
                s = "<div class='#{main_class}'><img src='#{@args['src']}' no-lazy "
                classes.push "no-lazy"
            else
                s = "<div class='#{main_class}'><img src='' data-src='#{@args['src']}' "
            end

            retina = @args.has_key?("retina") ? @args["retina"] : @args["src"]
            s+= "data-src-retina='#{retina}' "

            if !@args.has_key?("no_zoom") and classes[0] != "huge"
                zoom = @args.has_key?("zoom") ? @args["zoom"] : retina
                s+= "data-zoom='#{zoom}' "

                zoom_retina = @args.has_key?("zoom_retina") ? @args["zoom_retina"] : zoom
                s+= "data-zoom-retina='#{zoom_retina}' "
            else
                s+= "no-zoom "
                classes.push "no-zoom"
            end

            class_string = "class='#{classes.join(' ')}'"
            s += class_string + "/>"

            # Backup in case javascript is disabled on device
            no_script = "<noscript><img src='#{@args['src']}' #{class_string}/></noscript>"
            s += no_script

            if @args.has_key?("caption")
                s += "<div class='image-caption #{size_class}'>#{@args['caption']}</div>"
            end

            s += "</div>"
            s
        end

        def parse_args(args)
            _h = {}
            array = args.split(" | ")
            for s in array
                kv = s.split("=")
                _h[kv[0]] = (kv[1] != nil ? kv[1] : true)
            end
            _h
        end

    end
end

Liquid::Template.register_tag('image', Jekyll::Image)
