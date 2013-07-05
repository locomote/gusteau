require './spec/spec_helper'

describe Gusteau::Log do

  let(:fixed_time)   { Time.parse("2013-07-25 14:40:23 UTC") }

  let(:logger_class) { class Example; include Gusteau::Log; end }
  let(:logger)       { logger_class.new }

  before do
    Time.expects(:now).at_least_once.returns fixed_time
  end

  describe "#log" do
    it "should log start and end when block is given" do
      Inform.expects(:info).with('%{prompt}test', {:prompt => '[2013-07-25T14:40:23] GUSTEAU: '})
      Inform.expects(:info).with('%{prompt}DONE (in 0.00s)', {:prompt => '[2013-07-25T14:40:23] GUSTEAU: '})
      logger.log('test') { true }
    end

    it "should only log start when block isn't given" do
      Inform.expects(:info).with('%{prompt}hehe', {:prompt => '[2013-07-25T14:40:23] GUSTEAU: '})
      logger.log('hehe')
    end
  end

  describe "#log_error" do
    it "should output the prompt followed by a message" do
      Inform.expects(:error).with('%{prompt}error!', {:prompt => '[2013-07-25T14:40:23] GUSTEAU: '})
      logger.log_error('error!')
    end
  end

end
