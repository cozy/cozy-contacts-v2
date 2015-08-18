fs          = require 'fs'
path        = require 'path'
glob        = require 'glob'
prependFile = require 'prepend-file'

{exec} = require 'child_process'
logger = require('printit')
    date: false
    prefix: 'cake'


option '-f' , '--file [FILE*]' , 'test file to run'
option ''   , '--dir [DIR*]'   , 'directory where to grab test files'
option '-j' , '--use-js', 'If enabled, tests will run with the built files'

# defaults, will be overwritten by command line options
options =
    file: no
    dir:  no


dsc = 'run server tests, ./test is parsed by default, otherwise use -f or --dir'
task 'test', dsc, (opts) ->
    options   = opts
    testFiles = if options.dir
        fileLists = (glob.sync "#{dir}/**/*.coffee" for dir in options.dir)
        Array.prototype.concat.apply [], fileLists
    else if options.file
        [].concat options.file
    else
        glob.sync 'test/**/*.coffee'

    runTests testFiles


runTests = (fileList) ->
    env  = "NODE_ENV=test"
    env += " USE_JS=true" if options['use-js']? and options['use-js']

    command = """#{env} mocha #{fileList.join ' '} \
        --globals setImmediate,clearImmediate \
        --reporter spec \
        --compilers coffee:coffee-script/register \
        --colors
    """
    exec command, (err, stdout, stderr) ->
        logger.info stdout if stdout? and stdout.length > 0
        if err?
            logger.error """Running mocha caught exception:
                #{err}
                #{stderr}
            """
            setTimeout (-> process.exit 1), 100
        else
            logger.info "Tests succeeded!"
            setTimeout (-> process.exit 0), 100


dsc = 'Build CoffeeScript to Javascript'
task 'build', dsc, ->
    logger.options.prefix = 'cake:build'
    logger.info "Start compilation..."

    command = """
        rm -rf build
        coffee -cb --output build/server server
        coffee -cb --output build/ server.coffee
        ./node_modules/.bin/jade -cPDH -o build/server/views server/views
        cd client
            #{path.resolve 'node_modules', '.bin', 'bower'} install
            brunch build --production
    """
    exec command, (err, stdout, stderr) ->
        if err
            logger.error """
                An error has occurred while compiling:
                #{err}
            """
            process.exit 1
        else
            data = """var jade = require('jade/runtime');
                      module.exports = """
            for file in glob.sync './build/server/views/**/*.js'
                prependFile.sync file, data
            logger.info "Compilation succeeded."
            process.exit 0
