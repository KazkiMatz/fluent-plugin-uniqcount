# -*- coding: utf-8 -*-

require_relative 'queue'
require_relative 'list'

module UniqCount
  class ListContainer
    def initialize(config)
      @config = config
      @queue = Queue.new
      @list = List.new
      @mutex = Mutex.new
      @flashed_at = 0
    end

    def need_flush?(now)
      now - @flashed_at >= @config['out_interval']
    end

    def insert(es)
      items = []
      es.each do |time, record|
        time = @config['time'] ? record[@config['time']] : time
        key1 = record[@config['key1']]
        key2 = record[@config['key2']]

        items << [time, key1, key2] if time && key1 && key2
      end

      items.sort_by!(&:first)
      @mutex.synchronize {
        @queue.push(items)
      }
    end

    # @param now [Integer] the unix timestamp,
    #  to which list and queue are synchronized
    def flush(now)
      @mutex.synchronize {
        @flashed_at = now
        till = now - @config['offset']
        items = @queue.fetch(till)
        @queue.shift(till)

        @list.add(items)
        @list.shift(till - @config['span'])
      }
    end

    def get
      @mutex.synchronize {
        [@config['out_tag'], {
          'label' => @config['label'],
          'ranks' => @list.get(@config['out_num']),
          'at' => @flashed_at,
        }]
      }
    end
  end
end
