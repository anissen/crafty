package;

import kha.input.Mouse;
import kha.Assets;
import kha.Color;
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

    static function mouseMove(x, y, moveX, moveY) {
        // trace(x);
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

	public static function main() {
        setFullWindowCanvas();

		System.start({title: "Cosy Breakout", width: screenWidth, height: screenHeight}, function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
                // Avoid passing update/render directly, so replacing them via code injection works
                backbuffer = kha.Image.createRenderTarget(screenWidth, screenHeight);

                game = new Game();
                game.backbuffer = backbuffer;
                game.script = Assets.blobs.get('breakout_cosy').toString();

                if (!Cosy.validate(game.script)) {
                    trace('Script errors!');
                    return;
                }

				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
                System.notifyOnFrames(function (frames) { render(frames); });
                Mouse.get().notify(null, null, mouseMove, null, null);
			});
        });
	}
}
