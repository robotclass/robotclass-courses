#
# Standalone script for textile to pdf generation
#
# 
# Use RedCloth for textile to html.
# Use PrinceXML or wkhtmltopdf pdf engine for html to pdf.
#
# 1. gem install RedCloth
# 2. install pdf generation engine - price OR wkhtmltopdf
# 3 ./out - folder for outputs htmls
#
# this script placed in rusrails/pdf folder
#

# princexml - free for non-commerial 
# from http://www.princexml.com/download/
# for win32 Prince installations
# PATH_TO_PRINCE = "C:/Program Files/Prince/Engine/bin/prince.exe"

# wkhtmltopdf - free engine http://code.google.com/p/wkhtmltopdf/
#
# install binary engine, f.e. for windows
# http://wkhtmltopdf.googlecode.com/files/wkhtmltox-0.11.0_rc1-installer.exe
# full list: http://code.google.com/p/wkhtmltopdf/downloads/list
#
# then install ruby gem:
# gem install pdfkit
# 
# path to binary
PATH_TO_WKHTMLTOPDF = 'C:/Program Files/wkhtmltopdf/wkhtmltopdf.exe'

require "rubygems"
require 'redcloth'
require '../vendor/textile_extension'
RedCloth.include TextileExtensions

# Data Base
require 'textile-files'
##files = @@files

# -- local links BEGIN

# <a href="/path"> => <a href="#path">
def fix_local_links(files)
  local_links = []
  files.each do |f_path|
    local_links << path_to_link(f_path)
  end
  cnt = file_read(main_file_path)
  local_links.each do |link|
    anchor_name = link_to_anchor_href(link)
    cnt.gsub!('<a href="'+link+'"', '<a href="'+anchor_name+'"')
  end
  file_write(main_file_path, cnt)
end

def get_anchor(f_path)
  "<a name='#{path_to_anchor_name(f_path)}'></a>"
end

# '0-getting-started-with-rails/--getting-started-with-rails.textile' ->
# '/getting-started-with-rails'
#
# '0-getting-started-with-rails/0-this-guide-assumes.textile' ->
# '/getting-started-with-rails/this-guide-assumes'
# TODO refactoring
def path_to_link(path)
  return '/home' if path == 'home.textile'
  els = path.split('/')
  dir_name = els[0]
  file_name = els[1]
  dir_name = dir_name.split('-')[1..dir_name.split('-').size].join('-')

  els2 = file_name.split('-')
  if (els2[0] == els2[1]) && (els2[0] == '')
    return "/#{dir_name}"
  else
    file_name = els2[1..els2.size].join('-').split('.')[0]
    return "/#{dir_name}/#{file_name}"
  end
end

# '/getting-started-with-rails' -> 'getting-started-with-rails'
# '/getting-started-with-rails/this-guide-assumes' -> 'getting-started-with-rails_this-guide-assumes' ; _ -> ''
# a name=
def link_to_anchor_name(link)
  els = link.split('/')
  ret = els[1..els.size].join('')
  return ret
rescue
  return ''
end

# a href=
def link_to_anchor_href(link)
  p link

  els = link.split('/')
  ret = els[1..els.size].join('')
  file_name = @@names2file_name[els[1]]
  ret = "#{file_name}##{ret}"
  return ret
rescue 
  return ''
end

def path_to_anchor_name(f_path)
  link_to_anchor_name path_to_link(f_path)
end


def get_all_files_from_parts(parts)
  ret = []
  parts.each do |part|
    files = part[:files]
    ret += files
  end
  return ret
end

# -- local links END


# all htmls in one file will be stored here
# pdf generated from this file
def main_file_path
  #'./out/_all.html'
  "../out/_#{@@name}.html"
end


def file_read(file_path)
  File.read(file_path)
end

def file_write(file_path, cnt)
  File.open(file_path, 'wb') do |f|
    f << cnt
  end
end

def textile2html(files)
  p '  textile2html'
  files.each do |file_path|
    putc '.'
    file_path2 = file_path.tr('/', '_')

    source_path = "../courses/#{file_path}"
    dest_path = "../out/#{file_path2}.html"

    text = file_read(source_path)

    #html_content = RedCloth.new(text).to_html

    t = RedCloth.new(text)
    t.hard_breaks = false
    t.lite_mode = false # lite_mode
    t.sanitize_html = true # sanitize
    html_content = t.to_html(:notestuff, :plusplus, :code)

    file_write(dest_path, html_content)
    #`redcloth ../source/#{file_path} > ./out/#{file_path2}.html`
  end
  p '.'
end

def create_one_html_file(files, part)
  p '  create_one_html_file'
  all_cnt = ''
  files.each do |file_path|
    putc '.' 
    file_path2 = file_path.tr('/', '_')
    cnt = file_read("../out/#{file_path2}.html")
    
    # add anchor at beginning of file
    cnt = get_anchor(file_path) + cnt

    all_cnt += cnt
  end

  layout = """<html>
  <head>
    <title>RobotClass.ru</title>
    <META http-equiv=Content-Type content='text/html; charset=utf-8'>
  </head>
  <body>
  {CONTENT}
  </body>
  </html>
  """

  if part[:title]
    title = '<h1>'+part[:title]+'</h1>'
    all_cnt = title + all_cnt
  end

  all_pages = layout.gsub("{CONTENT}", all_cnt)
  file_write(main_file_path, all_pages)
  p '.'
end


# absolute file system path
def fix_image_path
  p '  fix_image_path'
  cnt = file_read(main_file_path)
  cnt.gsub!('<img src="/assets', '<img src="../courses/_assets')
  file_write(main_file_path, cnt)
end

def fix_move_h1
  p '  fix_move_h1'
  cnt = file_read(main_file_path)

  cnt.sub!('<h1>', '<h0>')
  cnt.sub!('</h1>', '</h0>')

  (1..10).to_a.reverse.each do |header_level|
    cnt.gsub!("<h#{header_level}>", "<h#{header_level+1}>")
    cnt.gsub!("<h#{header_level} ", "<h#{header_level+1} ") # <h3 id=...>
    cnt.gsub!("</h#{header_level}>", "</h#{header_level+1}>")
  end
  cnt.sub!('<h0>', '<h1>')
  cnt.sub!('</h0>', '</h1>')
  file_write(main_file_path, cnt)
end


def generate_pdf2(parts)
  p 'PDF generation'
  p 'based on wkhtmltopdf'
  parts.each do |part|
    #_parts << "../out/_#{part[:name]}.html"
    sources = "../out/_#{part[:name]}.html"
    pdf_file = "../pdfs/robotclass_#{part[:name]}.pdf"

    options = "--header-left [section] --header-center RobotClass --header-right [page] --header-font-size 8 --header-spacing 5 --header-line --print-media-type --footer-html ../out/_footer.html"
    `#{PATH_TO_WKHTMLTOPDF} #{options} #{sources} #{pdf_file}`

    p "PDF generated: #{pdf_file}"

  end
#  sources = _parts.join(' ')
end


def generate_footer
  version = Time.now.strftime('%Y-%m-%d')
  footer_cnt =<<END
  <head>
    <META http-equiv=Content-Type content='text/html; charset=utf-8'>
    <style>
      .footer-text{
      color: #c0c0c0; 
      font-size: 6pt
      }
    </style>
  </head>
  <body>
  <table width="100%">
  <tr>
    <td><a class="footer-text" href="http://groups.google.com/group/robotclassru">Обсуждение данного перевода</a></td>
    <td>
      <a class="footer-text" href="http://robotclass.ru/">on-line</a> 
      <span class="footer-text">
      |
      #{version}
      |
      </span>
      <a class="footer-text" href="..">github</a>
    </td>
    <td align="right"><a class="footer-text" href="http://groups.google.com/group/robotclassru">Вопросы по курсу</a></td>
  </tr>
  </table>
  </body>
  </html>
END

  file_write('../out/_footer.html', footer_cnt)

end


all_files = get_all_files_from_parts(@@parts)

@@parts.each do |part|
  @@name = part[:name]
  p @@name
  files = part[:files]
  textile2html(files)
  create_one_html_file(files, part)
  fix_image_path
  fix_local_links(all_files)
  # fix_move_h1
end
generate_footer
generate_pdf2(@@parts)