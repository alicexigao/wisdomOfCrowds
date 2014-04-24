Package.describe({
    summary: "Wisdom of crowds server & common code"
});

Package.on_use(function (api) {
    // Client & Server deps
    api.use([
        'underscore',
        'coffeescript'
    ]);

    // Non-core packages
    api.use('user-status');
    api.use('turkserver');

    // Shared files
    api.add_files([
        'common/data.coffee',
        'common/data_methods.coffee'
    ]);

    // Server files
    api.add_files([
        'server/data_init.coffee',
        'server/data_publications.coffee'
    ], 'server');

    api.export(['Timers']);
});

Package.on_test(function (api) {
    api.use('turkserver');
    api.use('woc-server');

    api.use([
        'coffeescript',
        'tinytest',
        'test-helpers'
    ]);

    api.add_files("tests/round_tests.coffee", "server");
});
