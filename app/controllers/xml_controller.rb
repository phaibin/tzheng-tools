class XmlController < ApplicationController

  def check
    uploaded_io = params[:file]
    if (uploaded_io)
      @check_file = uploaded_io.original_filename
      str = uploaded_io.read
      str.force_encoding('utf-8')
      # str = File.read(File.expand_path('~/Google Drive/temp//LibraryMessages_en.xlf.xml'), :encoding => 'utf-8')
      pattern = /(<.*?>)/mu
      matches = str.to_enum(:scan, pattern).map { Regexp.last_match }

      begin_tags = []

      matches.each do |match|
        if match.to_s =~ /<(\?|!).*?>/mu or match.to_s =~ /<.*?\/>/mu
          next
        end
        tag = find_tag(match.to_s)
        if tag
          if tag[:is_begin] # begin tag
            begin_tags << {match: match, tag: tag[:tag]}
          else # end tag
            begin_tag = begin_tags.pop
            if begin_tag[:tag] == tag[:tag]
              next
            else
              @error_line = str[0..begin_tag[:match].begin(0)].count("\n")+1
              @begin_tag = begin_tag[:tag]
              @begin_text = str[begin_tag[:match].begin(0), 100]
              @end_tag = tag[:tag]
              @end_text = str[match.begin(0), 100]
              break
            end
          end
        end
      end
    end
  end

  private

  def find_tag(str)
    if str =~ /<\/(.*?)>/mu
      return {is_begin: false, tag: $~.captures.first}
    end
    if str =~ /<(.*?)( |>)/mu
      return {is_begin: true, tag: $~.captures.first}
    end
  end
end

