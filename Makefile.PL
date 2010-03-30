use inc::Module::Install;
name 'Plack-Middleware-APIRateLimit';
all_from 'lib/Plack/Middleware/APIRateLimit.pm';
readme_from 'lib/Plack/Middleware/APIRateLimit.pm';

requires 'AnyEvent::Redis';

tests 't/*.t';

author 'Franck Cuny';
license 'perl';

build_requires 'Test::More';
use_test_base;
auto_include;
author_tests 'xt';
auto_set_repository;
WriteAll;
