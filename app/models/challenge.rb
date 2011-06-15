class Challenge
  @@challenges = %w(Yzxutm5TK5cotjy2
  Wkh2Ghvhuw2Ir.2zloo2pryh2632wdqnv2wr2Fdodlv2dw2gdzq
  JMl0kBp?20QixoivSc.2"vvmls8KOk"0jA,4kgt0OmUb,pm.).reduce({}) do |acc, solution|
    acc[acc.size + 1] = solution
    acc
  end

  class << self
    def correct? number, solution
      @@challenges[number] == solution
    end
    def next number
      number < @@challenges.size ? number.next : nil
    end
  end
end