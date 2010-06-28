# Required

Handle load and require ruby files using a nice DSL.

## Install

<code>gem install require-dsl</code>

## Usage

<code>require 'require-dsl'</code>

## Using the DSL

Imagine we are using the DSL inside a file basic.rb in <code>lib/project/report</code>

Passing 'spec' and the current file, lets Required determine that it should create require statements relative to 'spec' as the root folder.
The method 'ruby_files' is evaluated in the context of the file it is used in, i.e File.dirname(__FILE___) which could alternatively be passed as the second argument.

### Recursive option

By default the files are evaluated non-recursively, that is within the current folder and not any subfolders. You can explicitly set it with the <code>:recursive => :none</code> option

<pre>
# lib/project/report/basic.rb

ruby_files('spec', __FILE__) # OR ruby_files('spec', __FILE__, :recursive => :none)
==> ['lib/project/report/basic.rb']
</pre>

To evaluate all files within the current folder and recursively one level below, use the <code>:recursive => :single</code> option. 

<pre>
# lib/project/report/basic.rb

ruby_files('spec', __FILE__, :recursive => :single)
==> ['lib/project/report/basic.rb', 'lib/project/report/subfolder/in_the_sub.rb']
</pre>

To evaluate all files within the current folder and recursively traversing the complete hierarchy of subfolders, use the <code>:recursive => :full</code> option. 

<pre>
# lib/project/report/basic.rb

ruby_files('spec', __FILE__, :recursive => :full)
==> ['lib/project/report/basic.rb', 'lib/project/report/subfolder/in_the_sub.rb', 
'lib/project/report/subfolder/sub_sub/in_the_sub_of_the_sub.rb']
</pre>

### Except conditions

You can chain except_file(s) and except_folder(s) conditions on the filelist returned by ruby_files to filter out specific files and folders.

#### Condition: except_file(s)

<pre>
# Context: An extra file 'except_me.rb' has been added to the project/report folder:

ruby_files('lib', __FILE__).except_file('except_me')
==> 'project/report/basic.rb'

# Context: An extra file 'except_also_me.rb' has been added to the folder:

ruby_files('lib', __FILE__).except_files('except_me', 'except_also_me')
==> 'project/report/basic.rb'

ruby_files('lib', __FILE__).except_file('except_me').except_files('except_also_me')
==> 'project/report/basic.rb'
</pre>

#### Condition: except_folder(s)

<pre>
# Context: Extra folders 'not_me_folder' and 'me_folder' has been added to the project/report folder:

ruby_files('lib', __FILE__).except_folder('not_me_folder')
==> 'project/report/basic.rb', 'project/report/me_folder/yes_me.rb'

ruby_files('lib', __FILE__).except_folders('not_me_folder', 'me_folder')
==> 'project/report/basic.rb'

ruby_files('lib', __FILE__).except_folder('not_me_folder').except_folders('me_folder')
==> 'project/report/basic.rb'
</pre>

### Only conditions

You can chain only_file(s) and only_folder(s) conditions on the filelist returned by ruby_files to filter out specific files and folders.

Note: It rarely makes sense to chain multiple only conditions.

#### Condition: only_file(s)

<pre>
# Context: An extra file 'only_me.rb' has been added to the project/report folder:

ruby_files('lib', __FILE__).only_file('only_me')
==> 'project/report/only_me.rb'

# Context: An extra file 'also_only_me.rb' has been added to the folder:

ruby_files('lib', __FILE__).only_files('only_me', 'also_only_me')
==> 'project/report/only_me.rb', 'project/report/also_only_me.rb'
</pre>

#### Condition: only_folder(s)

<pre>
# Context: Extra folders 'only_me_folder' and 'me_folder' has been added to the project/report folder:

ruby_files('lib', __FILE__).only_folder('only_me_folder')
==> 'project/report/basic.rb', 'project/report/only_me_folder/yes_me.rb'

ruby_files('lib', __FILE__).only_folders('only_me_folder', 'me_folder')
==> 'project/report/basic.rb', 'project/report/only_me_folder/yes_me.rb', 'project/report/me_folder/me.rb'
</pre>


## strip_file_ext

Chaining a call to strip_file_ext, ensures that the file list is stripped of the .rb ending and thus usable for fx require statements. 

<pre>
# lib/project/report/basic.rb

ruby_files('lib', __FILE__).strip_file_ext
==> 'project/report/basic'
</pre>

The method *strip_file_ext* can take an argument to indicate a built-in action to perform on this file liust, fx load the files into ruby kernel (:load or :require), display them for debugging (:display)

<pre>
# lib/project/report/basic.rb

ruby_files('lib', __FILE__).except('except_me', 'except_also_me').strip_file_ext :display => 'require'
==> PRINTS "require 'project/report/basic'\n" to STDOUT

ruby_files('lib', __FILE__).except('except_me', 'except_also_me').strip_file_ext :require
==> 'project/report/basic' loaded into Ruby and executed if not previously loaded (using Ruby Kernel 'require' statement)

ruby_files('lib', __FILE__).except('except_me', 'except_also_me').strip_file_ext :load
==> 'project/report/basic' loaded into Ruby and executed (using Ruby Kernel 'load' statement)
</pre>

## output to StringIO

<pre>
out = StringIO.new  
ruby_files('lib', __FILE__, :stdout => out).strip_file_ext :display => :load
out.rewind
puts out.read
==> PRINTS "load 'project/report/basic'\n" to STDOUT

</pre>

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
