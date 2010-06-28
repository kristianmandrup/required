# Required

Handle load and require ruby files using a nice DSL.

## Install

<code>gem install required</code>

## Usage

<code>require 'required'</code>

## Using the DSL

<pre>
# lib/project/report/basic.rb

ruby_files('lib', __FILE__)
==> ['project/report/basic.rb']
</pre>

An extra file 'except_me.rb' is added to the folder:
<pre>
# lib/project/report/basic.rb

ruby_files('lib', __FILE__).except('except_me')
==> 'project/report/basic.rb'
</pre>

An extra file 'except_also_me.rb' is added to the folder:
<pre>
# lib/project/report/basic.rb

ruby_files('lib', __FILE__).except('except_me', 'except_also_me')
==> 'project/report/basic.rb'
</pre>

An extra file 'except_also_me.rb' is added to the folder:
<pre>
# lib/project/report/basic.rb

ruby_files('lib', __FILE__).except('except_me', 'except_also_me').require_files.require! :get
==> 'project/report/basic'

ruby_files('lib', __FILE__).except('except_me', 'except_also_me').require_files.require! :display
==> PRINTS 'project/report/basic' to STDOUT

ruby_files('lib', __FILE__).except('except_me', 'except_also_me').require_files.require! :require
==> 'project/report/basic' loaded into ruby kernel if not loaded (using require statement)
</pre>

## TODO

Much more to come... planning to port some functionality from require-me while improving code and syntax in a BDD fashion!

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Kristian Mandrup. See LICENSE for details.
