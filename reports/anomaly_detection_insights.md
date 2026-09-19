# Anomaly Detection Insights

## Objective

The objective of this analysis is to identify potentially unusual transaction amounts using statistical anomaly detection. The analysis focuses on completed transactions and uses the Interquartile Range (IQR) method.

## Methodology

The analysis calculated the first quartile (Q1), median, third quartile (Q3), and interquartile range (IQR) for completed transaction amounts.

- Q1: $27.91
- Median: $55.21
- Q3: $109.25
- IQR: $81.34
- Lower Bound: -$94.10
- Upper Bound: $231.26

Transactions above the upper bound or below the lower bound were classified as potential transaction amount anomalies.

## Overall Results

The dataset contained 66,683 completed transactions.

- Normal transactions: 61,142
- Potential high-amount anomalies: 5,541
- Potential low-amount anomalies: 0
- Overall potential anomaly rate: 8.31%

Because transaction amounts were positive and the lower IQR bound was negative, no low-amount anomalies were identified.

## Largest Potential Anomalies

The largest potential transaction amount was approximately $49,924.20.

Several other transactions were also substantially higher than the calculated IQR threshold of $231.26.

These transactions should be investigated using additional business context such as customer history, transaction frequency, timing, account behavior, merchant information, and available operational attributes.

## Channel Analysis

Potential anomaly rates across transaction channels were relatively close:

- Branch: 8.57%
- ATM: 8.37%
- Mobile: 8.32%
- Phone: 8.18%
- Online: 8.11%

The relatively narrow range indicates that potential anomalies were distributed across channels rather than being concentrated in one channel.

## Transaction Type Analysis

Potential anomaly rates across transaction types were also relatively similar:

- Transfer: 8.54%
- Payment: 8.51%
- Purchase: 8.18%
- Withdrawal: 8.16%
- Deposit: 8.16%

This analysis identifies unusual transaction amounts but does not establish that any transaction type causes anomalies.

## Merchant Category Analysis

Potential anomaly rates by merchant category ranged from approximately 7.80% to 8.67%.

The highest observed rate was Entertainment at approximately 8.67%, followed by Dining at approximately 8.54%.

Retail had the lowest observed rate at approximately 7.80%.

The relatively narrow range suggests that potential amount anomalies were present across merchant categories rather than being isolated to one category.

## Business Interpretation

The IQR analysis provides a statistical screening mechanism for identifying transactions with unusually large amounts.

The results can help prioritize transactions for further investigation. However, a statistical anomaly is not equivalent to fraud, suspicious activity, or an invalid transaction.

Additional analysis would be required before drawing conclusions about transaction risk. Useful dimensions for future investigation include customer-level transaction history, transaction frequency, timing patterns, account balances, merchant behavior, channel behavior, and other available operational attributes.

## Conclusion

The analysis identified 5,541 potential transaction amount anomalies among 66,683 completed transactions, representing an anomaly rate of 8.31%.

The results demonstrate how statistical anomaly detection can be incorporated into financial transaction analytics to identify unusual activity for further review.
EOF