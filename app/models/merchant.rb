class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  enum status: { enabled: 0, disabled: 1 }

  def top_five_customers
    Customer.joins(invoices: :items)
            .where('merchant_id = ?', self.id)
            .joins(invoices: :transactions)
            .where('result = ?', "success")
            .select("customers.*, count('transactions.result') as successful_transactions")
            .group('customers.id')
            .order(successful_transactions: :desc)
            .limit(5)
  end

  def items_not_shipped
    Invoice.joins(:items)
           .where('merchant_id = ?', self.id)
           .joins(:invoice_items)
           .where('invoice_items.status != ?', 2)
           .select("items.name, invoices.id, invoices.created_at")
           .order("invoices.created_at")
  end

  def enabled?
    status == 'enabled'
  end

  def disabled?
    status == 'disabled'
  end

  def self.display_enabled
    where(status: 0)
  end

  def self.display_disabled
    where(status: 1)
  end
end
