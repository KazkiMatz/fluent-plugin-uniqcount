require 'helper'

class UniqCountOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    list2_label foo
    list2_time at
    list2_key1 uri
    list2_key2 remote_ip
    list4_span 60
    list2_offset 3
    list2_out_tag output1
    list2_out_num 5

    list4_label bar
    list4_time at
    list4_key1 uri
    list4_key2 remote_ip
    list4_span 3600
    list4_offset 3
    list4_out_tag output2
    list4_out_num 5

    list5_label zoo
    list5_time at
    list5_key1 uri
    list5_key2 remote_ip
    list5_span 1
    list5_offset 3
    list5_out_tag output3
    list5_out_num 5
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::UniqCountOutput).configure(conf)
  end

  def test_configure
    d = create_driver
    list_configs = d.instance.list_configs
    assert_equal 3, list_configs.size
    assert_equal 'foo', list_configs[0]['label']
    assert_equal 1, list_configs[0]['out_interval']
    assert_equal 5, list_configs[0]['out_num']
    assert_equal 'bar', list_configs[1]['label']
    assert_equal 3600, list_configs[1]['span']
  end

  def test_emit
    uris = (1..1000).inject([]){|arr, i|
      arr.concat(Array.new(i, "http://foo.bar.com/#{i}"))
    }.shuffle
    remote_ips = (1..50000).map{rand(0...2**32)}

    d = create_driver
    d.run do
      100.times do
        1000.times do
          jitter = [0,1,2].sample
          record = {
            'at' => Time.now.to_i - jitter,
            'uri' => uris.sample,
            'remote_ip' => remote_ips.sample,
          }
          d.emit(record)
        end
        d.instance.lists.each do |list_con|
          list_con.flush(Time.now.to_i)
          output = list_con.get
          tag = output[0]
          data = output[1]
          counts = data['ranks'].map{|r|r['key2_uniq_count']}

          assert ['output1','output2','output3'].include?(tag)
          assert ['foo','bar','zoo'].include?(data['label'])
          assert_equal counts.sort.reverse, counts
        end
        print '*'
      end
    end
  end
end
