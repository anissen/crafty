package;

import kha.input.KeyCode;
import kha.Assets;
import kha.System;

enum TextAlign {
    Left;
    Center;
    Right;
}
enum TextVAlign {
    Top;
    Middle;
    Bottom;
}

class Game {
    public var backbuffer: kha.Image;
    var compiler: cosy.Compiler;
    var statements: Array<cosy.Stmt> = [];
    var fileName = '';
    var script = '';
    var errors: Array<String> = [];

    var time: Float;
    var textAlign = Center;
    var textVAlign = Middle;
    var mouseClicked = false;

    public function new(backbuffer: kha.Image) {
        compiler = cosy.Cosy.createCompiler();
        this.backbuffer = backbuffer;

        #if sys
        final programDir = haxe.io.Path.directory(Sys.programPath());
        final workingDir = haxe.io.Path.join([programDir, '../../..']);
        final gamesDir = haxe.io.Path.join([workingDir, 'games']);
        trace('gamesDir: $gamesDir');
        final games = sys.FileSystem.readDirectory(gamesDir).map(file -> {
            if (sys.FileSystem.isDirectory(haxe.io.Path.join([gamesDir, file]))) {
                return file;
            }
            return null;
        }).filter(file -> file != null);
        compiler.setVariable('games', games);
        #else
        compiler.setVariable('games', ['dummy game 1', 'dummy game 2']);
        #end

        compiler.setVariable('time', System.time);
        compiler.setVariable('mouse_clicked', false);
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
            final text = (args[0]: String);
            var x = (args[1]: Float);
            var y = (args[2]: Float);
            switch textAlign {
                case Left: 
                case Center: x -= backbuffer.g2.font.width(backbuffer.g2.fontSize, text) / 2;
                case Right:  x -= backbuffer.g2.font.width(backbuffer.g2.fontSize, text);
            }
            switch textVAlign {
                case Top:    
                case Middle: y -= backbuffer.g2.font.height(backbuffer.g2.fontSize) / 2;
                case Bottom: y -= backbuffer.g2.font.height(backbuffer.g2.fontSize);
            }
            backbuffer.g2.drawString(text, x, y);
            return 0;
        });
        compiler.setFunction('text_align', (args) -> { 
            textAlign = switch (args[0]: String) {
                case 'left': Left;
                case 'center': Center;
                case 'right': Right;
                case _: Center;
            };
            return 0;
        });
        compiler.setFunction('text_valign', (args) -> { 
            textVAlign = switch (args[0]: String) {
                case 'top': Top;
                case 'middle': Middle;
                case 'bottom': Bottom;
                case _: Middle;
            };
            return 0;
        });
        compiler.setFunction('text_width', (args) -> { 
            final text = (args[0]: String);
            return backbuffer.g2.font.width(backbuffer.g2.fontSize, text);
        });
        compiler.setFunction('text_height', (args) -> { 
            return backbuffer.g2.font.height(backbuffer.g2.fontSize);
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
        compiler.setFunction('play_sound', (args) -> { 
            final name = (args[0]: String);
            kha.audio1.Audio.play(Assets.sounds.get(name));
            return 0;
        });
        // compiler.setFunction('push_translation', (args) -> { 
        //     var x = (args[0]: Float);
        //     var y = (args[1]: Float);
        //     backbuffer.g2.pushTranslation(x, y);
        //     return 0;
        // });
        // compiler.setFunction('pop_translation', (args) -> { 
        //     backbuffer.g2.popTransformation();
        //     return 0;
        // });
        // compiler.setFunction('translate', (args) -> { 
        //     var x = (args[0]: Float);
        //     var y = (args[1]: Float);
        //     backbuffer.g2.translate(x, y);
        //     return 0;
        // });
        // compiler.setFunction('screen_shake', (args) -> { 
        //     var x = (args[0]: Float);
        //     var y = (args[1]: Float);
        //     backbuffer.g2.translate(x, y);
        //     return 0;
        // });

        time = System.time;
    }

    public function mouseMove(x: Float, y: Float, moveX: Float, moveY: Float): Void {
        compiler.setVariable('mouse_x', x);
        compiler.setVariable('mouse_y', y);
    }
    
    public function mouseDown(button: Int, x: Int, y: Int): Void {
        // mouseX = Scaler.transformX(x, y, backbuffer, ScreenCanvas.the, System.screenRotation);
		// mouseY = Scaler.transformY(x, y, backbuffer, ScreenCanvas.the, System.screenRotation);
        mouseClicked = true;
    }
    
    public function mouseUp(button: Int, x: Int, y: Int): Void {
        
    }
    
	public function keyDown(key:KeyCode) {
        // compiler.setVariable('key_' + key.toString(), true);
        if (errors.length > 0) {
            switch key {
                case KeyCode.Up | KeyCode.Left: error_id--;
                case KeyCode.Right | KeyCode.Down: error_id++;
                case _:
            }
        }
    }
    
    function isScriptValid() {
        errors = compiler.logger.log.map(error -> cosy.Logging.getReport(fileName, script, error));
        return compiler.logger.hadError || compiler.logger.hadRuntimeError || statements != null;
    }

    public function reloadScript(fileName: String, script: String, hotReload = false) {
        this.fileName = fileName;
        this.script = script;
        statements = compiler.parse(script);
        if (!isScriptValid()) return;
        
        // TODO: Register a callback for runtime errors
        
        compiler.runStatements(statements, hotReload);
        if (!isScriptValid()) return;
        if (!hotReload) compiler.runFunction('restart');
        if (!isScriptValid()) return;
    }

    public function restart() {
        compiler.runStatements(statements);
        compiler.runFunction('restart');
    }
        
    public function update(): Void {
        // ...
    }

    var error_id = 0;
    public function render(): Void {
        var g2 = backbuffer.g2;
        g2.begin(false);

        g2.font = Assets.fonts.brass_mono_regular;
        g2.fontSize = 48;
        compiler.setVariable('time', System.time);
        compiler.setVariable('mouse_clicked', mouseClicked);
        mouseClicked = false;
        final dt = System.time - time;
        time = System.time;
        if (errors.length == 0) {
            compiler.runFunction('_update', dt); // the underscore is a hack to avoid flagging the function as unused
            isScriptValid();
        }
        if (errors.length > 0) {
            if (error_id < 0) error_id = 0;
            else if (error_id > errors.length - 1) error_id = errors.length - 1;

            g2.clear(kha.Color.White);
            // g2.color = kha.Color.Black;
            // g2.fillRect(0, 0, backbuffer.width, error_scroll);
            
            g2.color = kha.Color.Orange;
            g2.fillRect(0, 0, backbuffer.width, 100);

            g2.color = kha.Color.White;
            g2.font = Assets.fonts.brass_mono_regular;
            g2.fontSize = 48;
            g2.drawString('${error_id + 1}/${errors.length} errors in ${fileName}', 30, 30);
            
            g2.color = kha.Color.Black;
            g2.fontSize = 24;
            var y = 150.0;
            for (line in errors[error_id].split('\n')) {
                g2.drawString(line, 20, y);
                y += g2.font.height(backbuffer.g2.fontSize) + 5;
            }
        }

        g2.end();
    }
}
