package;

import kha.input.Keyboard;
import kha.input.Mouse;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Scaler;

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
    
    static function keyDown(key: kha.input.KeyCode) {
        if (key == kha.input.KeyCode.Escape) {
            System.stop();
        }
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

    static function watchFile() {
        #if sys
        final file = haxe.io.Path.join([Sys.getCwd(), 'assets/cosy/breakout.cosy']);
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
                
                final script = sys.io.File.getContent('assets/cosy/breakout.cosy');
                game.reloadScript(script);
            }
        }
        var timer = new haxe.Timer(100);
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

                game = new Game(backbuffer);
                final script = Assets.blobs.get('breakout_cosy').toString();
                game.reloadScript(script);

                Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
                System.notifyOnFrames(function (frames) { render(frames); });
                Mouse.get().notify(game.mouseDown, null, game.mouseMove, null, null);
                Keyboard.get().notify(keyDown);
            });
        });
    }
}
