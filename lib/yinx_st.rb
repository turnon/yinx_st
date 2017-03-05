require "yinx_st/version"
require 'yinx'
require 'yinx_sql'
require 'my_chart'
require 'time_seq'

require 'yinx_st/note_meta'
require 'yinx_st/batches'

module YinxSt
  class << self
    def fetch *args
      Yinx::SQL.connect(*args)
      self
    end

    def last_n_days n
      batches = Batches.new n
      duration = "最近#{n}日"

      @chart = MyChart.js do
        material batches.all_notes
        material batches.unwind_tags, name: :unwind_tags

        select :yesterday do |note|
          note.dump_id == batches.latest_id
        end

        select :yesterday, from: :unwind_tags do |note|
          note.dump_id == batches.latest_id
        end

        select :changed_content do |note|
          note.status == :created or note.status == :updated
        end

        select :moved_book do |note|
          note.moved_book?
        end

        select :changed_tags do |note|
          note.changed_tags?
        end

        group_by :stack_book do |note|
          stack = note.stack.nil? ? '' : "#{note.stack}/"
          "#{stack}#{note.book}"
        end

        group_by(:stack){|note| note.stack or 'NO_STACK'}

        group_by :number_of_tags do |note|
          note.tags.count
        end

        plainBar :dump_day, name: "#{duration}总数变化", w: 1000, h:240, asc: :key
        line :dump_day, :status, name: "#{duration}新建/修改", from: :changed_content, w: 1000, h:240, asc: :key, keys: batches.time_line
        line :dump_day, name: "#{duration}移动笔记本", from: :moved_book, w: 1000, h:240, asc: :key, keys: batches.time_line
        line :dump_day, name: "#{duration}更改标签", from: :changed_tags, w: 1000, h:240, asc: :key, keys: batches.time_line

        bar :stack_book, name: '目前最大的10个笔记本', from: :yesterday, w:1400 ,h: 540, desc: :count, first: 10
        line :dump_day, :stack_book, name: "#{duration}笔记本体积变化", w: 1200, h:540, asc: :key, keys: batches.time_line

        bar :stack, name: '目前最大的10个笔记本组', from: :yesterday, w:1400 ,h: 240, desc: :count, first: 10
        line :dump_day, :stack, name: "#{duration}笔记本组体积变化", w: 1000, h:340, asc: :key, keys: batches.time_line

        pie :tags, name: '目前使用最多的15个标签', from: :yesterday__from__unwind_tags, w:1400 ,h: 340, desc: :count, first: 15
        bar :number_of_tags, name: '目前每篇笔记的标签数', from: :yesterday, w: 800, h: 240, asc: :key
        line :dump_day, :tags, name: "#{duration}标签数变化", from: :unwind_tags, w: 1400, h:740, asc: :key, keys: batches.time_line

      end

      self
    end

    attr_reader :chart

    def generate_html(erb_file=File.expand_path('../yinx_st/chart.erb', __FILE__))
      template = File.read erb_file
      html = ERB.new(template).result(binding)
    end
  end
end
