name 'scponly'

run_list ['scponly']

named_run_list :test, ['scponly_test']

default_source :community

cookbook 'scponly', path: '.'
cookbook 'scponly_test', path: 'test/cookbooks/scponly_test'
