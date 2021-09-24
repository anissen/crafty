package;

import kha.Assets;
import kha.System;

class Game {
    public var backbuffer: kha.Image;
    public var script: String;
    var statements: Array<cosy.Stmt>;
    var compiler: cosy.Compiler;

    public function new(script: String, backbuffer: kha.Image) {
        this.script = script;
        compiler = cosy.Cosy.createCompiler();
        this.backbuffer = backbuffer;

        compiler.setVariable('time', System.time);
        compiler.setFunction('sin', (args) -> return Math.sin(args[0]));
        compiler.setFunction('color', (args) -> backbuffer.g2.color = kha.Color.fromString((args[0]: String)));
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

        statements = compiler.parse(script);
    }

    public function update(): Void {
        // ...
    }

    public function render(): Void {
        var g2 = backbuffer.g2;
        g2.begin(true, kha.Color.White);

        g2.color = kha.Color.Green;
        g2.font = Assets.fonts.kenpixel_mini_square;
        g2.fontSize = 48;
        compiler.setVariable('time', System.time);
        // compiler.run(script); // TODO: Should be AST or Program
        compiler.runStatements(statements);

        g2.end();
    }
}
