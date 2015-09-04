require_relative '../../spec_helper'
require_relative '../../../lib/reek/examiner'
require_relative '../../../lib/reek/report/report'
require_relative '../../../lib/reek/report/formatter'

require 'json'
require 'stringio'

RSpec.describe Reek::Report::JSONReport do
  let(:options) { {} }
  let(:instance) { Reek::Report::JSONReport.new(options) }
  let(:examiner) { Reek::Examiner.new(source) }

  before do
    instance.add_examiner examiner
  end

  context 'with empty source' do
    let(:source) { '' }

    it 'prints empty json' do
      expect { instance.show }.to output(/^\[\]$/).to_stdout
    end
  end

  context 'with smelly source' do
    let(:source) { 'def simple(a) a[3] end' }

    it 'prints smells as json' do
      out = StringIO.new
      instance.show(out)
      out.rewind
      result = JSON.parse(out.read)
      expected = JSON.parse <<-EOS
        [
          {
            "context":        "simple",
            "lines":          [1],
            "message":        "doesn't depend on instance state",
            "smell_category": "LowCohesion",
            "smell_type":     "UtilityFunction",
            "source":         "string",
            "name":           "simple"
          },
          {
            "context":        "simple",
            "lines":          [1],
            "message":        "has the parameter name 'a'",
            "smell_category": "UncommunicativeName",
            "smell_type":     "UncommunicativeParameterName",
            "source":         "string",
            "name":           "a"
          }
        ]
      EOS

      expect(result).to eq expected
    end

    context 'with link formatter' do
      let(:options) { { warning_formatter: Reek::Report::WikiLinkWarningFormatter.new } }

      it 'prints documentation links' do
        out = StringIO.new
        instance.show(out)
        out.rewind
        result = JSON.parse(out.read)
        expected = JSON.parse <<-EOS
          [
            {
              "context":        "simple",
              "lines":          [1],
              "message":        "doesn't depend on instance state",
              "smell_category": "LowCohesion",
              "smell_type":     "UtilityFunction",
              "source":         "string",
              "name":           "simple",
              "wiki_link":      "https://github.com/troessner/reek/blob/master/docs/Utility-Function.md"
            },
            {
              "context":        "simple",
              "lines":          [1],
              "message":        "has the parameter name 'a'",
              "smell_category": "UncommunicativeName",
              "smell_type":     "UncommunicativeParameterName",
              "source":         "string",
              "name":           "a",
              "wiki_link":      "https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md"
            }
          ]
        EOS

        expect(result).to eq expected
      end
    end
  end
end
