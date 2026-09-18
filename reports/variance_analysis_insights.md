# Variance Analysis Insights

## Analysis Period

January 2024 through December 2025.

## Variance Methodology

Actual monthly transaction performance was compared against a historical
three-month rolling baseline.

The baseline was calculated using the average transaction value,
transaction count, and active customer count from the previous three months.

## Key Findings

### Positive Transaction Value Variances

- June 2024 recorded the largest positive transaction-value variance at approximately 39.84% above the historical baseline.
- October 2024 recorded a positive variance of approximately 32.68%.
- December 2025 recorded a positive variance of approximately 18.31%.
- November 2025 recorded a positive variance of approximately 16.66%.
- November 2024 recorded a positive variance of approximately 16.21%.

### Negative Transaction Value Variances

- January 2025 recorded the largest negative variance at approximately -19.38%.
- May 2024 recorded a negative variance of approximately -18.99%.
- August 2024 recorded a negative variance of approximately -18.36%.
- September 2024 recorded a negative variance of approximately -17.70%.
- February 2025 recorded a negative variance of approximately -17.33%.

## Customer and Transaction Activity

Variance analysis was also performed for transaction count and active customers.

The analysis demonstrates that transaction-value variance does not always move
in the same direction as transaction-count variance.

For example, June 2024 recorded a 39.84% positive transaction-value variance
while transaction count was approximately 2.61% below its historical baseline.

This indicates that transaction value should be analyzed together with
transaction volume and average transaction value.

## Business Interpretation

The variance analysis identifies months where actual performance materially
deviated from historical expectations.

Positive variance indicates that actual transaction value exceeded the
historical three-month baseline.

Negative variance indicates that actual transaction value fell below the
historical three-month baseline.

The analysis identifies performance exceptions but does not attribute these
changes to specific business causes because the synthetic dataset does not
contain explanatory business-event fields.

Further investigation could examine:

- Average transaction value
- Transaction volume
- Customer activity
- Transaction type
- Merchant category
- Transaction channel
- Transaction status

These dimensions can be used to investigate the potential drivers of
significant positive or negative variances.

## Analyst Takeaway

Variance analysis provides a structured method for identifying performance
exceptions and prioritizing areas for deeper investigation.

The combination of SQL window functions and Python/Pandas enables the same
variance methodology to be calculated, validated, and visualized across the
analytics workflow.