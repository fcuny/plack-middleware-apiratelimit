use inc::Module::Install;
name 'Plack-Middleware-APIRateLimit';
all_from 'lib/Plack/Middleware/APIRateLimit.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

author 'Franck Cuny';
license 'perl';
readme_from 'lib/Plack/Middleware/APIRateLimit.pm';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
