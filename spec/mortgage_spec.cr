require "./spec_helper"

private def mortgage
  Mortgage.new(loan: 100_000, rate: 6.0, term: 180)
end

describe Mortgage do
  describe "#initialize" do
    it "builds a mortgage object with the given attributes" do
      m = Mortgage.new(loan: 100_000.00, rate: 6.00, term: 10)
      m.loan.should eq 100_000.00
      m.rate.should eq 6.00
      m.term.should eq 10
    end

    it "sets the monthly rate for the mortgage" do
      m = Mortgage.new(loan: 100_000.00, rate: 6.00, term: 10)
      m.monthly_rate.should eq 0.005
    end

    it "raises an error when the given interest rate is 0" do
      expect_raises(Mortgage::InvalidRateException, "Mortage interest rate must be a positive value") do
        Mortgage.new(loan: 100_000.00, rate: 0.00, term: 10)
      end
    end

    it "raises an error when the given interest rate is negative" do
      expect_raises(Mortgage::InvalidRateException, "Mortage interest rate must be a positive value") do
        Mortgage.new(loan: 100_000.00, rate: -1.00, term: 10)
      end
    end
  end

  describe "#monthly_payment" do
    it "calculates the mortgage monthly payment" do
      mortgage.monthly_payment.should eq 843.86
    end
  end

  describe "#outstanding_loan_at" do
    it "calculates the amount left from the original loan after paying the given number of months" do
      mortgage.outstanding_loan_at(1).should eq 99_656.14
    end

    it "decreases between months" do
      mortgage.outstanding_loan_at(1).should be > mortgage.outstanding_loan_at(2)
    end

    it "raises an error when the given month is not positive" do
      expect_raises(Mortgage::InvalidMonthException, "Given month is outside the mortgage term") do
        mortgage.outstanding_loan_at(0)
      end
    end

    it "raises an error when the given month exceeds the mortgage term" do
      expect_raises(Mortgage::InvalidMonthException, "Given month is outside the mortgage term") do
        mortgage.outstanding_loan_at(181)
      end
    end

    it "at the last month payment there is no outstanding loan" do
      mortgage.outstanding_loan_at(180).should eq 0.00
    end
  end

  describe "#interest_payment_at" do
    it "calculates the interest part of the first month payment" do
      mortgage.interest_payment_at(1).should eq 500
    end

    it "raises an error when the given month is not positive" do
      expect_raises(Mortgage::InvalidMonthException, "Given month is outside the mortgage term") do
        mortgage.interest_payment_at(0)
      end
    end

    it "raises an error when the given month exceeds the mortgage term" do
      expect_raises(Mortgage::InvalidMonthException, "Given month is outside the mortgage term") do
        mortgage.interest_payment_at(181)
      end
    end

    it "decreases between months" do
      mortgage.interest_payment_at(1).should be > mortgage.interest_payment_at(2)
    end
  end

  describe "#principal_payment_at" do
    it "calculates the principal part of the first month payment" do
      mortgage.principal_payment_at(1).should eq 343.86
    end

    it "raises an error when the given month is not positive" do
      expect_raises(Mortgage::InvalidMonthException, "Given month is outside the mortgage term") do
        mortgage.principal_payment_at(0)
      end
    end

    it "raises an error when the given month exceeds the mortgage term" do
      expect_raises(Mortgage::InvalidMonthException, "Given month is outside the mortgage term") do
        mortgage.principal_payment_at(181)
      end
    end

    it "increases between months" do
      mortgage.principal_payment_at(1).should be < mortgage.principal_payment_at(2)
    end
  end

  describe "#total_payment" do
    it "calculates the total amount paid during the mortgage lifetime" do
      mortgage.total_payment.should eq 151_894.80
    end
  end

  describe "#total_interest" do
    it "calculates the interest amount paid during the mortgage lifetime" do
      mortgage.total_interest.should eq 51_894.80
    end
  end

  describe "#payment_at" do
    it "returned payment corresponds to the given payment number" do
      mortgage.payment_at(5).number.should eq 5
    end

    it "contains the payment amount for the given month" do
      mortgage.payment_at(1).amount.should eq 843.86
    end

    it "contains the principal amount for the given month" do
      mortgage.payment_at(1).principal.should eq 343.86
    end

    it "contains the interest amount for the given month" do
      mortgage.payment_at(1).interest.should eq 500
    end

    it "contains the outstanding mortgage amount for the given month" do
      mortgage.payment_at(1).outstanding.should eq 99_656.14
    end
  end

  describe "#payments" do
    it "is an array of mortgage payments" do
      typeof(mortgage.payments).should eq Array(Mortgage::Payment)
    end

    it "contains an element for each monthly payment during the full mortgage term" do
      mortgage.payments.size.should eq 180
    end

    it "payments elements order matches the mortgage payment months" do
      mortgage.payments.first.number.should eq 1
      mortgage.payments[1].number.should eq 2
      mortgage.payments.last.number.should eq 180
    end
  end
end
