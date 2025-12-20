# Copyright (c) 2020 Kenshi Muto
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'fileutils'
require 'yaml'
require 'pathname'

def make_mdre(ch, p2r, md_dir, re_dir)
  md_file = md_dir.join(ch.sub(/\.re\Z/, '.md'))
  system("#{p2r} #{md_file} > #{re_dir.join(ch)}")
end

desc 'run pandoc2review'
task :pandoc2review do
  md_dir = Pathname('article')
  re_dir = Pathname('_refiles')
  p2r = 'pandoc2review'

  unless File.exist?(re_dir)
    Dir.mkdir(re_dir)
    File.write("#{re_path}/THIS_FOLDER_IS_TEMPORARY", '')
  end

  p Dir.pwd
  catalog = YAML.load_file(md_dir.join('catalog.yml'))
  %w(PREDEF CHAPS APPENDIX POSTDEF).each do |block|
    if catalog[block].kind_of?(Array)
      catalog[block].each do |ch|
        make_mdre(ch, p2r, md_dir, re_dir)
      end
    end
  end
end

CLEAN.include('_refiles')
Rake::Task[BOOK_PDF].enhance([:pandoc2review])
Rake::Task[BOOK_EPUB].enhance([:pandoc2review])
Rake::Task[WEBROOT].enhance([:pandoc2review])
Rake::Task[TEXTROOT].enhance([:pandoc2review])
Rake::Task[TOPROOT].enhance([:pandoc2review])
Rake::Task[IDGXMLROOT].enhance([:pandoc2review])
