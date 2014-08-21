fs = require 'fs'
path = require 'path'
through2 = require 'through2'
File = require 'vinyl'

# requires = ['html', 'info']

module.exports = (options = { dir: 'images' }) ->
    processFile = (file, enc, done) ->
        if file.isPost
            { $ } = file
            { dir } = options

            str = '^((ftp|http)s?:)?//'
            regexp = new RegExp str, 'i'

            isNotExternal = (i, img) ->
                $img = $ img
                url = $img.attr 'src'

                if not url.match regexp
                    $img.data 'path', url
                    return yes
                return no

            $('img').filter(isNotExternal).each (i, img) =>
                $img = $ img
                try
                    relative = path.join dir, $img.data 'path'
                    full = path.resolve (path.dirname file.path), relative
                    contents = fs.readFileSync full
                    imgFile = new File { path: relative, contents }
                    imgFile.isImage = yes
                    $img.attr 'src', relative
                    $img.parent('p').addClass 'media-container'
                    file.stats.images.push relative
                    @push imgFile
                catch e
                    @emit 'error', e

            file.contents = new Buffer $.html()

        done null, file

    through2.obj processFile