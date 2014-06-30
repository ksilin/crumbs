RSpec::Matchers.define :match_stdout do |check|

  @capture = nil

  match do |block|

    begin
      stdout_saved = $stdout
      $stdout = StringIO.new
      block.call
    ensure
      @capture = $stdout
      $stdout = stdout_saved
    end

    @capture.string.match check
  end

  failure_message_for_should do
    "expected to #{description}"
  end
  failure_message_for_should_not do
    "expected not to #{description}"
  end
  description do
    "match [#{check}] on stdout [#{@capture.string}]"
  end

end
