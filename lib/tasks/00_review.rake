# Original work Copyright (c) 2006-2020 Minero Aoki, Kenshi Muto, Masayoshi Takahashi, Masanori Kado.
# Modified work Copyright (c) 2025 Naoki Hanakawa(@hanasuke)
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
require 'rake/clean'
require 'date'
require 'pathname'
require 'psych'

def load_review_config(config_file_path)
  config_file_path = Pathname(config_file_path)
  review_config = Psych.safe_load(File.read(config_file_path), permitted_classes: [Date])
  if review_config.has_key?("inherit")
    review_config["inherit"].each do |inherit|
      review_config.merge!(Psych.safe_load(File.read(config_file_path.parent + inherit), permitted_classes: [Date]))
    end
  end

  review_config
end

ARTICLE_DIR = Pathname('article')
OUTPUT_DIR = Pathname('output')
CONFIG_FILE = ENV['REVIEW_CONFIG_FILE'] || 'article/config.yml'
CATALOG_FILE = ENV['REVIEW_CATALOG_FILE'] || 'article/catalog.yml'

review_config = load_review_config(CONFIG_FILE)

BOOK = ENV['REVIEW_BOOK'] || review_config['bookname'] ||'book'
OUTPUT_PDF = BOOK + ".pdf"
BOOK_PDF = BOOK + ".#{DateTime.now.strftime("%Y%m%d%H%M%S")}.pdf"
OUTPUT_EPUB = BOOK + ".epub"
BOOK_EPUB = BOOK + ".#{DateTime.now.strftime("%Y%m%d%H%M%S")}.epub"
WEBROOT = ENV['REVIEW_WEBROOT'] || 'webroot'
TEXTROOT = BOOK + '-text'
TOPROOT = BOOK + '-text'
IDGXMLROOT = BOOK + '-idgxml'
PDF_OPTIONS = ENV['REVIEW_PDF_OPTIONS'] || ''
EPUB_OPTIONS = ENV['REVIEW_EPUB_OPTIONS'] || ''
WEB_OPTIONS = ENV['REVIEW_WEB_OPTIONS'] || ''
IDGXML_OPTIONS = ENV['REVIEW_IDGXML_OPTIONS'] || ''
TEXT_OPTIONS = ENV['REVIEW_TEXT_OPTIONS'] || ''

def build(mode, chapter)
  sh("review-compile --target=#{mode} --footnotetext --stylesheet=style.css #{chapter} > tmp")
  mode_ext = { 'html' => 'html', 'latex' => 'tex', 'idgxml' => 'xml', 'top' => 'txt', 'plaintext' => 'txt' }
  FileUtils.mv('tmp', chapter.gsub(/re\z/, mode_ext[mode]))
end

def build_all(mode)
  sh("review-compile --target=#{mode} --footnotetext --stylesheet=style.css")
end

task default: :html_all

desc 'build html (Usage: rake build re=target.re)'
task :html do
  if ENV['re'].nil?
    puts 'Usage: rake build re=target.re'
    exit
  end
  build('html', ENV['re'])
end

desc 'build all html'
task :html_all do
  build_all('html')
end

desc 'preproc all'
task :preproc do
  Dir.glob('*.re').each do |file|
    sh "review-preproc --replace #{file}"
  end
end

desc 'generate PDF and EPUB file'
task all: %i[pdf epub]

desc 'generate PDF file'
task pdf: BOOK_PDF

desc 'generate static HTML file for web'
task web: WEBROOT

desc 'generate text file (without decoration)'
task plaintext: TEXTROOT do
  sh "review-textmaker #{TEXT_OPTIONS} -n #{CONFIG_FILE}"
end

desc 'generate (decorated) text file'
task text: TOPROOT do
  sh "review-textmaker #{TEXT_OPTIONS} #{CONFIG_FILE}"
end

desc 'generate IDGXML file'
task idgxml: IDGXMLROOT do
  sh "review-idgxmlmaker #{IDGXML_OPTIONS} #{CONFIG_FILE}"
end

desc 'generate EPUB file'
task epub: BOOK_EPUB

IMAGES = FileList['images/**/*']
OTHERS = ENV['REVIEW_DEPS'] || []
SRC = FileList['./**/*.re', '*.rb'] + [CONFIG_FILE, CATALOG_FILE] + IMAGES + FileList[OTHERS]
SRC_EPUB = FileList['*.css']
SRC_PDF = FileList['layouts/*.erb', 'sty/**/*.sty']

file BOOK_PDF => SRC + SRC_PDF do
  FileUtils.rm_rf([BOOK_PDF, BOOK, BOOK + '-pdf'])
  sh "review-pdfmaker #{PDF_OPTIONS} #{CONFIG_FILE} 2>&1"

  FileUtils.move(ARTICLE_DIR+OUTPUT_PDF, OUTPUT_DIR+BOOK_PDF)
end

file BOOK_EPUB => SRC + SRC_EPUB do
  FileUtils.rm_rf([BOOK_EPUB, BOOK, BOOK + '-epub'])
  sh "review-epubmaker #{EPUB_OPTIONS} #{CONFIG_FILE}"

  FileUtils.move(ARTICLE_DIR+BOOK_EPUB, OUTPUT_DIR)
end

CLEAN.include([BOOK, BOOK_PDF, BOOK_EPUB, BOOK + '-pdf', BOOK + '-epub', WEBROOT, 'images/_review_math', 'images/_review_math_text', TEXTROOT, IDGXMLROOT])
