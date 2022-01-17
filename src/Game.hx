package;

import kha.Assets;
import kha.System;

class Game {
    public var backbuffer: kha.Image;
    var compiler: cosy.Compiler;
    var statements: Array<cosy.Stmt> = [];
    var errors: Array<String> = [];

    var needsToRunSetup = false;

    var time: Float;

    public function new(backbuffer: kha.Image) {
        compiler = cosy.Cosy.createCompiler();
        this.backbuffer = backbuffer;

        compiler.setVariable('time', System.time);
        compiler.setVariable('mouse_x', 0);
        compiler.setVariable('mouse_y', 0);
        compiler.setFunction('sin', (args) -> Math.sin(args[0]));
        // compiler.setFunction('background', (args) -> {
        //     backbuffer.g2.clear(kha.Color.fromString((args[0]: String)));
        //     return 0;
        // });
        compiler.setFunction('clear', (args) -> {
            backbuffer.g2.clear(backbuffer.g2.color);
            return 0;
        });
        compiler.setFunction('color', (args) -> backbuffer.g2.color = kha.Color.fromString((args[0]: String)));
        compiler.setFunction('color_rgb', (args) -> backbuffer.g2.color = kha.Color.fromFloats(args[0], args[1], args[2]));
        compiler.setFunction('fill_rect', (args) -> {
            final x = (args[0]: Float);
            final y = (args[1]: Float);
            final width = (args[2]: Float);
            final height = (args[3]: Float);
            backbuffer.g2.fillRect(x, y, width, height);
            return 0;
        });
        compiler.setFunction('image', (args) -> { 
            var img = Assets.images.get((args[0]: String));
            backbuffer.g2.drawImage(img, (args[1]: kha.FastFloat), (args[2]: kha.FastFloat));
            return 0;
        });
        
        compiler.setFunction('text', (args) -> { 
            var text = (args[0]: String);
            var x = (args[1]: Float);
            var y = (args[2]: Float);
            backbuffer.g2.drawString(text, x, y);
            return 0;
        });
        compiler.setFunction('line', (args) -> { 
            var x1 = (args[0]: Float);
            var y1 = (args[1]: Float);
            var x2 = (args[2]: Float);
            var y2 = (args[3]: Float);
            backbuffer.g2.drawLine(x1, y1, x2, y2, 5.0);
            return 0;
        });
        compiler.setFunction('circle', (args) -> { 
            var x      = (args[0]: Float);
            var y      = (args[1]: Float);
            var radius = (args[2]: Float);
            var segments = Std.int(6 + Math.sqrt(radius) * 2);
            // trace(segments);
            var angle_per_segment = (Math.PI * 2) / segments;
            for (i in 0...segments) {
                var x1 = x + radius * Math.cos(angle_per_segment * i);
                var y1 = y + radius * Math.sin(angle_per_segment * i);
                var x2 = x + radius * Math.cos(angle_per_segment * (i + 1));
                var y2 = y + radius * Math.sin(angle_per_segment * (i + 1));
                backbuffer.g2.drawLine(x1, y1, x2, y2, 2.0);
            }
            return 0;
        });
        compiler.setFunction('fill_circle', (args) -> { 
            var x      = (args[0]: Float);
            var y      = (args[1]: Float);
            var radius = (args[2]: Float);
            var segments = Std.int(6 + Math.sqrt(radius) * 2);
            // trace(segments);
            var angle_per_segment = (Math.PI * 2) / segments;
            for (i in 0...segments) {
                var x1 = x + radius * Math.cos(angle_per_segment * i);
                var y1 = y + radius * Math.sin(angle_per_segment * i);
                var x2 = x + radius * Math.cos(angle_per_segment * (i + 1));
                var y2 = y + radius * Math.sin(angle_per_segment * (i + 1));
                backbuffer.g2.fillTriangle(x, y, x1, y1, x2, y2);
            }
            return 0;
        });

        reloadScript();

        time = System.time;
    }

    public function mouseMove(x: Float, y: Float, moveX: Float, moveY: Float): Void {
        compiler.setVariable('mouse_x', x);
        compiler.setVariable('mouse_y', y);
    }

    function isScriptValid() {
        return statements != null;
    }

    public function reloadScript() {
        final script = Assets.blobs.breakout_cosy.toString();
        // final script = Assets.blobs.follow_cosy.toString();
        statements = compiler.parse(script);
        errors = (isScriptValid() ? [] : ['Script error(s)']);
        
        needsToRunSetup = true;
    }
        
    public function update(): Void {
        // ...
    }

    public function render(): Void {
        var g2 = backbuffer.g2;
        g2.begin(false);

        g2.font = Assets.fonts.brass_mono_regular;
        g2.fontSize = 48;
        compiler.setVariable('time', System.time);
        if (needsToRunSetup) {
            compiler.runStatements(statements);
            needsToRunSetup = false;
        }
        final dt = System.time - time;
        time = System.time;
        compiler.runFunction('_update', dt); // the underscore is a hack to avoid flagging the function as unused

        if (errors.length > 0) {
            g2.color = kha.Color.Black;
            g2.fillRect(0, 0, backbuffer.width, backbuffer.height / 2);

            g2.color = kha.Color.Red;
            g2.fontSize = 24;
            g2.drawString(errors.join('\n'), 10, 10);
        }

        g2.end();
    }
}
