require "yinx_st/version"
require 'yinx'
require 'yinx_sql'
require 'time_seq'

require 'yinx_st/note_meta'
require 'yinx_st/batches'

require 'my_chartkick'

module YinxSt
  class << self

    attr_reader :chart

    def fetch *args
      Yinx::SQL.connect(*args)
      self
    end

    def last_n_days n
      batches = Batches.new(n + 1)
      duration = "最近#{n}日"

      time_line = batches.time_line

      all = batches.all_notes
      unwind_tags = batches.unwind_tags

      yesterday = all.select{|note| note.dump_id == batches.latest_id}
      yesterday_unwind_tags = unwind_tags.select{|note| note.dump_id == batches.latest_id}

      changed_content = all.select{|note| note.status != :remained}
      moved_book = all.select &:moved_book?
      changed_tags = all.select &:changed_tags?

      @chart = MyChartkick.bundle do |s|
        s.my_line_chart all,
          title: "#{duration}总数变化",
          x: :dump_day,
          min: batches.smallest_batch_size.floor(-1),
          asc: :key,
          last: n

        s.my_line_chart changed_content,
          title: "#{duration}新建/修改/删除",
          x: :dump_day, y: :status,
          keys: time_line,
          asc: :key,
          last: n

        s.my_line_chart moved_book,
          title: "#{duration}移动笔记本",
          x: :dump_day,
          keys: time_line,
          asc: :key,
          last: n

        s.my_line_chart changed_tags,
          title: "#{duration}更改标签",
          x: :dump_day,
          keys: time_line,
          asc: :key,
          last: n

        s.my_column_chart yesterday,
          title: "目前最大的10个笔记本",
          x: :stack_book,
          desc: :count,
          first: 10

        s.my_line_chart all,
          title: "#{duration}笔记本体积变化",
          x: :dump_day, y: :stack_book,
          asc: :key,
          height: '540px',
          last: n

        s.my_column_chart yesterday,
          title: "目前最大的10个笔记本组",
          x: :stack_name,
          desc: :count,
          first: 10

        s.my_line_chart all,
          title: "#{duration}笔记本组体积变化",
          x: :dump_day, y: :stack_name,
          asc: :key,
          last: n

        s.my_pie_chart yesterday_unwind_tags,
          title: "目前使用最多的15个标签",
          x: :tags,
          desc: :count,
          first: 15

        s.my_column_chart yesterday,
          title: "目前每篇笔记的标签数",
          x: :tags_count,
          asc: :key

        s.my_line_chart unwind_tags,
          title: "#{duration}标签数变化",
          x: :dump_day, y: :tags,
          asc: :key,
          height: '740px',
          last: n

      end

    end


  end
end
