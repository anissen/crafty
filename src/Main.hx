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
    static var backbuffer: kha.Image;
    static var script: String;

	static function update(): Void {
	}

	static function render(frames: Array<Framebuffer>): Void {
        var g2 = backbuffer.g2;
		g2.begin(true, kha.Color.Black);
		// Offset all following drawing operations from the top-left a bit
		g2.pushTranslation(32, 32);
		// Fill the following rects with blue
        // g2.color = Color.Blue;
        // for (x in 0...12) {
        //     for (y in 0...8) {
        //         g2.fillRect(x * 80, y * 80, 75, 75);
        //     }
        // }

        // g2.color = Color.Green;
        // g2.drawString('rect', 200, 200);
        
        g2.color = kha.Color.Green;
        g2.font = Assets.fonts.kenpixel_mini_square;        
        g2.fontSize = 48;
        Cosy.setVariable('time', System.time);
        Cosy.run(script);

        g2.popTransformation();
		g2.end();

		final fb = frames[0];
        final g2scaled = fb.g2;
        g2scaled.begin();
        Scaler.scale(backbuffer, fb, System.screenRotation);
        g2scaled.end();
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
        Cosy.setFunction('sin', (args) -> return Math.sin(args[0]));
        Cosy.setFunction('color', (args) -> backbuffer.g2.color = kha.Color.fromString((args[0]: String)));
        Cosy.setFunction('rect', (args) -> {
            final x = (args[0]: Float);
            final y = (args[1]: Float);
            final width = (args[2]: Float);
            final height = (args[3]: Float);
            backbuffer.g2.fillRect(x, y, width, height);
            return 0;
        });
        Cosy.setFunction('image', (args) -> { 
            var img = Assets.images.get((args[0]: String));
            backbuffer.g2.drawImage(img, (args[1]: kha.FastFloat), (args[2]: kha.FastFloat));
            return 0;
        });
        
        Cosy.setFunction('text', (args) -> { 
            var text = (args[0]: String);
            var x = (args[1]: Float);
            var y = (args[2]: Float);
            backbuffer.g2.drawString(text, x, y);
            return 0;
        });

        function move(x, y, moveX, moveY) {
            // trace(x);
        }

        setFullWindowCanvas();

		System.start({title: "Project", width: screenWidth, height: screenHeight}, function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
                script = Assets.blobs.get('breakout_cosy').toString();
                Cosy.setVariable('time', System.time);
                if (!Cosy.validate(script)) {
                    trace('Script errors!');
                    return;
                }

				// Avoid passing update/render directly, so replacing them via code injection works
                backbuffer = kha.Image.createRenderTarget(screenWidth, screenHeight);

				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
                System.notifyOnFrames(function (frames) { render(frames); });
                Mouse.get().notify(null, null, move, null, null);
			});
        });
	}
}
