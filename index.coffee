fs = require 'fs'
path = require 'path'
through2 = require 'through2'
# @TODO: replace with Vinyl
{ File } = require('gulp-util')

# requires = ['html']

module.exports = (options = { dir: 'images' }) ->
    processFile = (file, enc, done) ->
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
                imgFile = new File { relative, contents }
                @emit 'data', imgFile
            catch e
                @emit 'error', e

        done null, file

    through2.obj processFile