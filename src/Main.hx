package;

import kha.input.Keyboard;
import kha.input.Mouse;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Scaler;

#if kha_html5
import kha.Macros;
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end

import cosy.Cosy;

class Main {
    public static inline var screenWidth = 800;
    public static inline var screenHeight = 600;
    public static var backbuffer: kha.Image;
    static var game: Game;

    static function render(frames: Array<Framebuffer>): Void {
        game.render();

        // Scale to hi-DPI screens if required
        final fb = frames[0];
        final g2scaled = fb.g2;
        g2scaled.begin();
        Scaler.scale(backbuffer, fb, System.screenRotation);
        g2scaled.end();
    }
    
    static function update(): Void {
        game.update();
    }

    static function mouseMove(x: Float, y: Float, moveX: Float, moveY: Float): Void {
        // trace(x);
    }
    
    static function keyDown(key: kha.input.KeyCode) {
        if (key == kha.input.KeyCode.Escape) {
            System.stop();
        }
    }

    static function setFullWindowCanvas():Void {
        #if kha_html5
        //make html5 canvas resizable
        document.documentElement.style.padding = "0";
        document.documentElement.style.margin = "0";
        document.body.style.padding = "0";
        document.body.style.margin = "0";
        var canvas:CanvasElement = cast document.getElementById(Macros.canvasId());
        canvas.style.display = "block";

        var resize = function() {
            canvas.width = Std.int(window.innerWidth * window.devicePixelRatio);
            canvas.height = Std.int(window.innerHeight * window.devicePixelRatio);
            canvas.style.width = document.documentElement.clientWidth + "px";
            canvas.style.height = document.documentElement.clientHeight + "px";
        }
        window.onresize = resize;
        resize();
        #end
    }

    static function watchFile() {
        #if sys
        final file = haxe.io.Path.join([Sys.getCwd(), 'test.cosy']);
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
                // compiler.runFile(file);
                
                game.reloadScript();
            }
        }
        var timer = new haxe.Timer(1000);
        timer.run = watch_file;
        #end
    }

    public static function main() {
        setFullWindowCanvas();

        System.start({title: "Cosy Breakout", width: screenWidth, height: screenHeight}, function (_) {
            // Just loading everything is ok for small projects
            Assets.loadEverything(function () {
                watchFile(); 

                // Avoid passing update/render directly, so replacing them via code injection works
                backbuffer = kha.Image.createRenderTarget(screenWidth, screenHeight);

                final script = Assets.blobs.breakout_cosy.toString();
                
                game = new Game(backbuffer);
                // if (!game.isScriptValid()) {
                //     trace('Script errors!');
                //     return;
                // }

                Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
                System.notifyOnFrames(function (frames) { render(frames); });
                Mouse.get().notify(null, null, mouseMove, null, null);
                Keyboard.get().notify(keyDown);
            });
        });
    }
}
