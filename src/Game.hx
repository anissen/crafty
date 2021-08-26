package;

import kha.Assets;
import kha.System;

import cosy.Cosy;

class Game {
    public var backbuffer: kha.Image;
    public var script: String;

    public function new() {
        Cosy.setVariable('time', System.time);
        Cosy.setFunction('sin', (args) -> return Math.sin(args[0]));
        Cosy.setFunction('color', (args) -> backbuffer.g2.color = kha.Color.fromString((args[0]: String)));
        Cosy.setFunction('fill_rect', (args) -> {
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
        Cosy.setVariable('time', System.time);
        Cosy.run(script);

		g2.end();
	}
}
