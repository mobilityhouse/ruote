
#
# Testing Ruote (OpenWFEru)
#
# Wed May 20 17:08:17 JST 2009
#

require File.join(File.dirname(__FILE__), 'base')


class EftSubprocessTest < Test::Unit::TestCase
  include FunctionalBase

  def test_subprocess_ref

    pdef = Ruote.process_definition do
      subprocess :ref => 'sub0'
      define :sub0 do
        echo 'a'
      end
    end

    #noisy

    assert_trace pdef, 'a'
  end

  def test_subprocess_att_text

    pdef = Ruote.process_definition do
      subprocess 'sub0'
      define :sub0 do
        echo 'a'
      end
    end

    #noisy

    assert_trace pdef, 'a'
  end

  def test_subprocess_exp_name

    pdef = Ruote.process_definition do
      sub0
      define :sub0 do
        echo 'a'
      end
    end

    #noisy

    assert_trace pdef, 'a'
  end

  def test_subprocess_if

    pdef = Ruote.process_definition do
      define :sub0 do
        echo 'a'
      end
      sequence do
        subprocess :ref => 'sub0'
        subprocess :ref => 'sub0', :if => 'true == false'
        subprocess :ref => 'sub0'
      end
    end

    #noisy

    assert_trace pdef, %w[ a a ]
  end

  def test_subprocess_atts_to_vars

    pdef = Ruote.process_definition do
      subprocess 'sub0', :a => 'A', :b => 'B'
      define :sub0 do
        echo '${v:a}:${v:b}'
      end
    end

    #noisy

    assert_trace pdef, 'A:B'
  end

  def test_subprocess_passing_tree

    pdef = Ruote.process_definition do
      subprocess 'sub0' do
        noop
      end
      define :sub0 do
        alpha
      end
    end

    tree = nil

    @engine.register_participant :alpha do |workitem, fexp|
      tree = fexp.lookup_variable('tree')
    end

    #noisy

    assert_trace pdef, ''

    assert_equal ["noop", {}, []], tree
  end

  def test_subprocess_uri

    pdef = Ruote.process_definition do
      sequence do
        echo 'in'
        subprocess :ref => File.join(File.dirname(__FILE__), '..', 'pdef.xml')
        echo 'out.'
      end
    end

    #noisy

    assert_trace pdef, %w[ in a b out. ]
  end

  def test_missing_uri

    pdef = Ruote.process_definition do
      sequence do
        echo 'in'
        subprocess :ref => 'nada'
        echo 'out.'
      end
    end

    #noisy

    wfid = @engine.launch(pdef)

    wait_for(wfid)

    assert_equal(
      "no subprocess named 'nada' found",
      @engine.process(wfid).errors.first.error_message)
  end
end

