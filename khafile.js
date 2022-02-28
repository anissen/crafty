let project = new Project('Crafty');

console.log(`building for ${platform}`);

// project.addParameter('-dce full');
if (platform === 'html5') {
    project.addParameter('-dce full');
} else { // macOS builds fail on full DCE
    project.addParameter('-dce std');
}

project.localLibraryPath = 'libs';

// project.addParameter('--times'); // (DK) show haxe compiler durations
// project.addDefine('macro-times');
// project.addParameter('-dce full');
// project.addDefine('dump=pretty');
project.addDefine('analyzer_optimize');

project.addAssets('assets/**');
project.addSources('src');
// project.addLibrary('cosy/src');
project.addLibrary('cosy-dev/src');
// project.addLibrary('cosy'); // without /src requires a haxelib.json file with classPath set to "src"

resolve(project);