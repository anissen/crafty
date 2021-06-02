let project = new Project('Cosy Breakout');

console.log(`building for ${platform}`);

project.localLibraryPath = 'libs';

// project.addParameter('--times'); // (DK) show haxe compiler durations
// project.addDefine('macro-times');
project.addParameter('-dce full');
project.addDefine('analyzer_optimize');

project.addAssets('assets/**');
project.addSources('src');
project.addLibrary('cosy/src');
// project.addLibrary('cosy'); // without /src requires a haxelib.json file with classPath set to "src"

resolve(project);
