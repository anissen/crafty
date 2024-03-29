package;

import haxe.io.Path;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Scaler;

using StringTools;

class Main {
    public static inline var screenWidth = 800;
    public static inline var screenHeight = 600;
    static var game: Game;

    static function render(framebuffers: Array<Framebuffer>): Void {
        final backbuffer = game.image;
        final g = backbuffer.g2;
        g.begin();
		g.color = kha.Color.White;
        game.render(g);
        g.end();
        
        // Scale to hi-DPI screens if required
        final framebuffer = framebuffers[0];
        final g2scaled = framebuffer.g2;
        g2scaled.begin();
        Scaler.scale(backbuffer, framebuffer, System.screenRotation);
        g2scaled.end();
    }
    
    static function update(): Void {
        game.update();
    } 
    
    static function keyDown(key: kha.input.KeyCode) {
        if (key == kha.input.KeyCode.Escape) {
            System.stop();
        } else if (key == kha.input.KeyCode.R) {
            game.restart();
        } else {
            game.keyDown(key);
        }
    }

    static function keyUp(key: kha.input.KeyCode) {
        game.keyUp(key);
    }

    static function keyPress(char: String) {

    }

    static function setFullWindowCanvas(): Void {
        #if kha_html5
        //make html5 canvas resizable
        js.Browser.document.documentElement.style.padding = "0";
        js.Browser.document.documentElement.style.margin = "0";
        js.Browser.document.body.style.padding = "0";
        js.Browser.document.body.style.margin = "0";
        var canvas: js.html.CanvasElement = cast js.Browser.document.getElementById(kha.Macros.canvasId());
        canvas.style.display = "block";

        var resize = function() {
            canvas.width = Std.int(js.Browser.window.innerWidth * js.Browser.window.devicePixelRatio);
            canvas.height = Std.int(js.Browser.window.innerHeight * js.Browser.window.devicePixelRatio);
            canvas.style.width = js.Browser.document.documentElement.clientWidth + "px";
            canvas.style.height = js.Browser.document.documentElement.clientHeight + "px";
        }
        js.Browser.window.onresize = resize;
        resize();
        #end
    }

    #if sys
    static function watchFile(file: String) {
        // trace('working directory is: ' + Sys.getCwd());
        trace('Watching $file');
        var stat = sys.FileSystem.stat(file);
        function has_file_changed(): Bool {
            if (stat == null) return false;
            var new_stat = sys.FileSystem.stat(file);
            if (new_stat == null) return false;
            var has_changed = (new_stat.mtime.getTime() != stat.mtime.getTime());
            stat = new_stat;
            return has_changed;
        }
        function watch_file() {
            if (has_file_changed()) {
                var time = Date.now();
                var text = '> "$file" changed at $time';
                Sys.println('\033[1;34m$text\033[0m');
                
                final fileName = haxe.io.Path.withoutDirectory(file);
                final script = sys.io.File.getContent(file);
                game.reloadScript(fileName, script, true);
            }
        }
        var timer = new haxe.Timer(100);
        timer.run = watch_file;
    }
    #end

    static function main() {
        final fileName = 'snake.cosy';
        
        #if sys
        function findFileRecursively(dir: String, fileName: String): String {
            for (entry in sys.FileSystem.readDirectory(dir)) {
                if (entry == fileName) return haxe.io.Path.join([dir, fileName]);
                if (sys.FileSystem.isDirectory(entry)) {
                    final res = findFileRecursively(Path.join([dir, entry]), fileName);
                    if (res != null) return res;
                }
            }
            return null;
        }

        final programDir = haxe.io.Path.directory(Sys.programPath());
        final relativeFilePath = (Sys.args().length > 0) ? Sys.args()[0] : findFileRecursively('assets', fileName);
        final file = haxe.io.Path.join([programDir, '../../../..', relativeFilePath]);
        trace('Running $file');
        #end

        setFullWindowCanvas(); 
                
        System.start({title: "Crafty", width: screenWidth, height: screenHeight }, function (_) {
            // Just loading everything is ok for small projects
            Assets.loadEverything(function () {
                #if sys
                watchFile(file);
                #end

                game = new Game();
                game.setupGraphics(screenWidth, screenHeight);
                #if sys
                final script = sys.io.File.getContent(file);
                #else
                final name = fileName.replace('.', '_').replace('-', '_');
                final script = Assets.blobs.get(name).toString();
                #end
                game.reloadScript(fileName, script);

                Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
                System.notifyOnFrames(function (frames) { render(frames); });
                Mouse.get().notify(game.mouseDown, null, game.mouseMove, null, null);
                Keyboard.get().notify(keyDown, keyUp, keyPress);
            });
        });
    }
}
