use inc::Module::Install;
name 'Plack-Middleware-APIRateLimit';
all_from 'lib/Plack/Middleware/APIRateLimit.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
