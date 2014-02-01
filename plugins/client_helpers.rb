# encoding: utf-8

require 'digest/md5'
require 'qipowl/core/monkeypatches'

module Ruhoh::Resources::Pages
  class Client
    Help_Owl = [
      {
        "command" => "owl <title>",
        "desc" => "Create a new post with OWL markup."
      }
    ]

    def owl
      create_template(* filename_and_title(@args[2]))
    end

  private
    def debug_mode?
      true
    end

    def filename_and_title(s=nil,opts={})
      begin
        file = s || "untitled"
        ext = @collection.config["ext"] || '.owl'

        # filepath vs title
        name =  file.include?('/') ?
                File.join(File.dirname(file), File.basename(file, ext).to_filename) :
                file.to_filename

        name = "#{name}-#{@iterator}" unless @iterator.zero?
        filename = opts[:draft] ?
          File.join(@ruhoh.paths.base, @collection.resource_name, "drafts", "#{name}#{ext}") :
          File.join(@ruhoh.paths.base, @collection.resource_name, "#{name}#{ext}")
        @iterator += 1
      end while File.exist?(filename)
      [filename, file.gsub(/.*?\//, '')]
    end    

    def create_template filename, title
      FileUtils.mkdir_p File.dirname(filename)
      # ---
      # title: 'Слухи ширятся'
      # date: '2013-12-13 08:58:54'
      # description:
      # tags: []
      # ---

      output = %Q(---
title: '#{title}'
date:  '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}'
description: '#{title}'
categories: []
tags:
  - jic
---

) 

      File.open(filename, 'w:UTF-8') { |f| f.puts output }
      res = @collection.resource_name
      Ruhoh::Friend.say { green "New #{res} ⇒ “#{filename}”" }
    end


  end
end
