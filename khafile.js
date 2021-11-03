let project = new Project('Cosy Breakout');

console.log(`building for ${platform}`);

project.localLibraryPath = 'libs';

// project.addParameter('--times'); // (DK) show haxe compiler durations
// project.addDefine('macro-times');
// project.addParameter('-dce full');
// project.addDefine('dump=pretty');
project.addParameter('-dce std');
project.addDefine('analyzer_optimize');

project.addAssets('assets/**');
project.addSources('src');
// project.addLibrary('cosy/src');
project.addLibrary('cosy-dev/src');
// project.addLibrary('cosy'); // without /src requires a haxelib.json file with classPath set to "src"

project.addLibrary('haxeui-core');
project.addLibrary('haxeui-kha');
project.addLibrary('haxeui-theme-kenney');

resolve(project);