#!/usr/bin/env ruby

counter = 0
curr = 0
`rm -rf results/*`

Dir['*'].each { |f|
  next unless '.owl' == File.extname(f)

  puts "[#{curr+=1}] Processing #{f}..."

  s = File.read f

  re_title = /---.*?title:\s*'(.*?)'/m
  re_date = /---.*?date:\s*'(.*?)'/m
  re_text = /---.*?---(.*)/m

  date = (s =~ re_date) ? $1 : "#{counter+=1}"
  date = "#{date}-00-00-00" if date.length == 10

  # debug
  # next unless date =~ /2013-11-02-10-53-18/

  text = "#{$1 if s =~ re_title}#{$1 if s =~ re_text}".strip

  # quotations
  text.gsub!(/^[〉>](.*?‒\s+.*?,\s+\S*)/mx) { |_|
    $1.strip
      .gsub(/^/mx, '    ')
      .gsub(/‒\s+(.*?),\s+(.*)/mx, '    ✍ \1, \2')
  }
  # quotations
  text.gsub!(/^[〉>](.*?)(?=\Z|\R{2,})/mx) { |_|
    $1.strip
      .gsub(/^/mx, '    ')
      .gsub(/‒\s+(.*?),\s+(.*)/mx, '    ✍ \1, \2')
  }
  # code: 6nbsp
  text.gsub!(/Λ(.*?)Λ/mx) { |_|
    $1
      .gsub(/^/mx, '      ')
      .gsub(/\s*⏎[  ]*/mx, '')
  }
  text = text
    .gsub(/\p{Blank}*┇[  ]*/, "\n") # table rows
    .gsub(/\p{Blank}*┆[  ]*/, "\t\t") # table cells
    .gsub(/\p{Blank}*⏎[  ]*/, '  ') # CRLF
    .gsub(/\s*¹(\S+)/, ' (\1) ') # anchors
    .gsub(/[≡≈λ*_`]/mx, '≡'=>'*', '≈'=>'_', 'λ'=>'`', '*'=>'*', '_'=>'_', '`'=>'`') # inlines
    .gsub(/<\/?strong>/, '*')
    .gsub(/<\/?em>/, '_')
    .gsub(/✿_p_epigraph/, '          ') # ✿_p_epigraph 10nbsp
    .gsub(/✿\S*\s*/, '') # crap

  # cleanup
  text.gsub! /http:\/\/img-css.friends.yandex.net\/favicon.ico\s+(\S+)\s+\(\S+\)/, '✎ya \1'

  fname = "results/#{date.gsub /[ :]/, '-'}"
  fname.gsub!(/(..)$/) {|m|
    sprintf "%02d", Integer(m.gsub /^0/, '') + 1
  } while File.exist? fname

  File.write(fname, "#{text}")
  puts "Writtten: #{fname}"
}
