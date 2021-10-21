package;

import kha.Assets;
import kha.System;
import zui.*;

class Game {
    public var backbuffer: kha.Image;
    public var script: String;
    var statements: Array<cosy.Stmt>;
    var compiler: cosy.Compiler;
    var ui = new Zui({font: Assets.fonts.DroidSans, scaleFactor: 2.0 });

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
        g2.font = Assets.fonts.kenpixel_mini_square;
        g2.fontSize = 48;
        compiler.setVariable('time', System.time);
        compiler.runStatements(statements);

        g2.end();

        ui.begin(g2);
		if (ui.window(Id.handle(), 0, 0, backbuffer.width, backbuffer.height, false)) {
			if (ui.panel(Id.handle({selected: true}), "Panel")) {
				ui.indent();
				ui.text("Text");
				ui.textInput(Id.handle({text: "Hello"}), "Input");
				ui.button("Button");
				if (ui.isHovered) ui.tooltip("Tooltip Bubble!\nWith multi-line support!\nWoo!");

                // Ext.textArea(ui, Id.handle({text: "Text\nArea!"}));
                Ext.textArea(ui, Id.handle({text: script}));

				ui.check(Id.handle(), "Check Box");
				var hradio = Id.handle();
				ui.radio(hradio, 0, "Radio 1");
				ui.radio(hradio, 1, "Radio 2");
				ui.radio(hradio, 2, "Radio 3");
				Ext.inlineRadio(ui, Id.handle(), ["High", "Medium", "Low"]);
				ui.combo(Id.handle(), ["Item 1", "Item 2", "Item 3"], "Combo", true);
				if (ui.panel(Id.handle({selected: false}), "Nested Panel")) {
					ui.indent();
					ui.text("Row");
					ui.row([2/5, 2/5, 1/5]);
					ui.button("A");
					ui.button("B");
					ui.check(Id.handle(), "C");
					ui.unindent();
				}
				Ext.floatInput(ui, Id.handle({value: 42.0}), "Float Input");
				ui.slider(Id.handle({value: 0.2}), "Slider", 0, 1);
				if (ui.isHovered) ui.tooltip("Slider tooltip");
				ui.slider(Id.handle({value: 0.4}), "Slider 2", 0, 1.2, true);
				ui.separator();
				ui.unindent();
			}
		}
		ui.end();
    }
}
