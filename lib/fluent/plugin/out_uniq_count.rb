# -*- coding: utf-8 -*-

require_relative '../../uniq_count/list_container'

module Fluent
  class UniqCountOutput < Output
    Fluent::Plugin.register_output('uniq_count', self)

    LIST_PARAMS = [
      {name: 'label', type: :string},
      {name: 'time', type: :string, default: false},
      {name: 'key1', type: :string},
      {name: 'key2', type: :string},
      {name: 'out_tag', type: :string},
      {name: 'span', type: :integer, default: 60},
      {name: 'offset', type: :integer, default: 0},
      {name: 'out_num', type: :integer, default: 10},
      {name: 'out_interval', type: :integer, default: 1},
    ]
    LIST_MAX_NUM = 10

    (1..LIST_MAX_NUM).each do |i|
      LIST_PARAMS.each do |p|
        config_param "list#{i}_#{p[:name]}".to_sym, p[:type], default: p[:default]
      end
    end

    attr_reader :list_configs, :lists

    def configure(conf)
      super
      list_nums = conf.keys.inject([]) {|nums, k|
        k =~ /^list(\d+)_(\w+)$/ ? nums << $1.to_i : nums
      }.uniq
      @list_configs = list_nums.map {|i|
        Hash[*LIST_PARAMS.map {|p|
          valname = "list#{i}_#{p[:name]}"
          val = instance_variable_get("@#{valname}")
          unless val || p.has_key?(:default)
            raise Fluent::ConfigError, "'#{valname}' parameter is required"
          end
          [p[:name], val]
        }.flatten]
      }
    end

    def start
      super

      @lists = @list_configs.map {|config|
        UniqCount::ListContainer.new(config)
      }
      start_observer
    end

    def shutdown
      super
      if @observer
        @observer.terminate
        @observer.join
      end
    end

    def start_observer
      @observer = Thread.new(&method(:observe))
    end

    def observe
      loop {
        sleep 0.1
        now = Time.now.to_i
        @lists.each do |list_con|
          next unless list_con.need_flush?(now)
          list_con.flush(now)
          output = list_con.get
          Fluent::Engine.emit(output[0], Fluent::Engine.now, output[1])
        end
      }
    end

    def emit(tag, es, chain)
      @lists.each do |list_con|
        list_con.insert(es)
      end
      chain.next
    end
  end
end
