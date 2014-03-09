require 'helper'

class QueueTest < Test::Unit::TestCase
  def setup
  end

  def test_queue_operations
    q = UniqCount::Queue.new
    assert_equal 0, q.size

    q.push([[1, 'foo', 1]])
    assert_equal 1, q.size

    q.push([[1, 'bar', 1], [2, 'bar', 2]])
    assert_equal 3, q.size

    q.shift(1)
    assert_equal 3, q.size

    q.push([[1, 'foo', 3], [3, 'foo', 2]])
    assert_equal 5, q.size

    q.shift(2)
    assert_equal 2, q.size

    q.shift(3)
    assert_equal 1, q.size

    q.shift(4)
    assert_equal 0, q.size
  end
end
