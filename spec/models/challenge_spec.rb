require 'spec_helper'
require 'models/challenge'

describe Challenge do
  describe ".correct?" do
    %w(Yzxutm5TK5cotjy2
    Wkh2Ghvhuw2Ir.2zloo2pryh2632wdqnv2wr2Fdodlv2dw2gdzq
    JMl0kBp?20QixoivSc.2"vvmls8KOk"0jA,4kgt0OmUb,pm.).reduce([]) {|acc, solution| acc << [acc.size+1, solution]}.each do |number, solution|
      it "returns true when solution is #{solution} for #{number}" do
        assert {Challenge.correct? number, solution}
      end
    end
  end
  describe ".next number" do
    [[1, 2], [2, 3], [3, nil]].each do |number, successor|
      it "respond #{successor} for #{number}" do
        assert {Challenge.next(number) == successor}
      end
    end
  end
end