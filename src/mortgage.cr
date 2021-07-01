# Provides mortgage payments information based on the mortgage *loan*,
# annual interest *rate* and *term* length.
class Mortgage
  property loan : Float64, rate : Float64, term : Int32
  getter monthly_rate : Float64

  class InvalidRateException < Exception
    def message
      "Mortage interest rate must be a positive value"
    end
  end

  class InvalidMonthException < Exception
    def message
      "Given month is outside the mortgage term"
    end
  end

  # Holds the information for an especific month payment.
  # *number*: Payment number out of the total number of payments for the mortgage term.
  # *amount*: Amount to pay.
  # *principal*: Cuantity of the payment to reduce from the mortgage loan principal.
  # *interest*: Cuantity of the payment corresponding to the mortgage interest.
  # *outstanding*: Outstanding mortgage loan debt after the payment.
  struct Payment
    getter number, amount, principal, interest, outstanding

    def initialize(@number : Int32, @amount : Float64, @principal : Float64, @interest : Float64, @outstanding : Float64)
    end
  end

  # Initializes a mortgage object.
  # *loan*: Loan amount taken for the mortgage.
  # *rate*: Annual fixed interest rate in percent.
  # *term*: Number of months the morgage will last.
  def initialize(@loan : Float64, @rate : Float64, @term : Int32)
    raise InvalidRateException.new if rate <= 0.0

    @monthly_rate = @rate / 100 / 12
  end

  # Payment information for the given *month*
  def payment_at(month : Int32) : Payment
    raise InvalidMonthException.new unless valid_month?(month)

    Payment.new(
      month,
      monthly_payment,
      principal_payment_at(month),
      interest_payment_at(month),
      outstanding_loan_at(month)
    )
  end

  # Array containing the information for each one of the payments during the full
  # mortgage term.
  def payments : Array(Payment)
    payments = [] of Payment
    1.upto(term) { |n| payments << payment_at(n) }
    payments
  end

  # Monthly payment for the mortgage loan.
  def monthly_payment : Float64
    (loan * monthly_rate * ((1 + monthly_rate) ** term) /
      ((1 + monthly_rate) ** term - 1)).round(2)
  end

  # Outstanding loan after the payment for the *month*.
  def outstanding_loan_at(month : Int32) : Float64
    raise InvalidMonthException.new unless valid_month?(month)

    (loan * ((1 + monthly_rate) ** term - (1 + monthly_rate) ** month) /
      ((1 + monthly_rate) ** term - 1)).round(2)
  end

  # Amount of the payment for the given *month* that goes against the mortage interest.
  def interest_payment_at(month : Int32) : Float64
    raise InvalidMonthException.new unless valid_month?(month)

    outstanding = month > 1 ? outstanding_loan_at(month - 1) : loan
    (outstanding * monthly_rate).round(2)
  end

  # Amount of the payment for the given *month* that goes against the mortage principal.
  def principal_payment_at(month : Int32) : Float64
    raise InvalidMonthException.new unless valid_month?(month)

    (monthly_payment - interest_payment_at(month)).round(2)
  end

  # Total amount that will be paid over the lifetime of the mortgage
  def total_payment : Float64
    (monthly_payment * term).round(2)
  end

  # Total amount of interest that will be paid over the lifetime of the mortgage
  def total_interest : Float64
    (total_payment - loan).round(2)
  end

  # Indicates if the given *month* belongs to the mortgage term.
  private def valid_month?(month : Int32) : Bool
    month >= 1 && month <= term
  end
end
