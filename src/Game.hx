package;

import kha.Assets;
import kha.System;

class Game {
    public var backbuffer: kha.Image;
    public var script: String;
    var statements: Array<cosy.Stmt>;
    var compiler: cosy.Compiler;

    final screen = haxe.ui.core.Screen.instance;
    final ui = haxe.ui.macros.ComponentMacros.buildComponent("ui.xml");
    // final ui = haxe.ui.macros.ComponentMacros.buildComponentFromString(Assets.blobs.get('ui_xml').toString());

    public function new(script: String, backbuffer: kha.Image) {
        this.script = script;
        compiler = cosy.Cosy.createCompiler();
        this.backbuffer = backbuffer;

        ui.show();
        // haxe.Timer.delay(ui.hide, 5000);
        screen.addComponent(ui);

        // for (comp in ui.namedComponents.filter((comp) -> comp.id == 'script')) {
        //     comp.text = script;
        // }
        var scriptArea = ui.findComponent("script");
        if (scriptArea != null) {
            scriptArea.text = script;
        }

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

    public function isScriptValid() {
        return statements != null;
    }

    public function update(): Void {
        // ...
    }

    public function render(): Void {
        var g2 = backbuffer.g2;
        g2.begin(true, kha.Color.White);

        g2.color = kha.Color.Green;
        g2.font = Assets.fonts.DroidSans;
        g2.fontSize = 48;
        compiler.setVariable('time', System.time);
        compiler.runStatements(statements);

        // haxe.ui.Toolkit.scaleX = (backbuffer.width / Main.screenWidth);
        // haxe.ui.Toolkit.scaleY = (backbuffer.height / Main.screenHeight);
        g2.color = kha.Color.White;
        screen.renderTo(g2);

        g2.end();
    }
}
